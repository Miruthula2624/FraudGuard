const express = require('express');
const router = express.Router();
const multer = require('multer');
const Tesseract = require('tesseract.js');
const path = require('path');
const fs = require('fs');
const http = require('http');
const auth = require('../middleware/auth');
const db = require('../config/db');
const { analyzeScamContent } = require('../utils/analyzer');

// ─────────────────────────────────────────────
//  MULTER SETUP (memory storage — cloud safe)
// ─────────────────────────────────────────────
const upload = multer({
    storage: multer.memoryStorage(),
    fileFilter: (req, file, cb) => {
        const allowedTypes = ['.jpg', '.jpeg', '.png', '.webp', '.bmp', '.tiff', '.pdf'];
        const ext = path.extname(file.originalname).toLowerCase();
        const isImageOrPdfMime = file.mimetype && (file.mimetype.startsWith('image/') || file.mimetype === 'application/pdf');
        if (allowedTypes.includes(ext) || isImageOrPdfMime) {
            cb(null, true);
        } else {
            cb(new Error('Only images (JPG, PNG, WebP) and PDFs are allowed'));
        }
    }
});

// ─────────────────────────────────────────────
//  ML API CALLER (Flask on port 5001)
// ─────────────────────────────────────────────
const ML_API_URL = process.env.ML_API_URL || 'http://127.0.0.1:5001';
const _mlUrl = new URL('/predict', ML_API_URL);

function callMLApi(text) {
    return new Promise((resolve) => {
        const payload = JSON.stringify({ text });
        const options = {
            hostname: _mlUrl.hostname,
            port: _mlUrl.port || (_mlUrl.protocol === 'https:' ? 443 : 80),
            path: _mlUrl.pathname,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(payload)
            },
            timeout: 5000
        };

        const req = http.request(options, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try { resolve({ ok: true, data: JSON.parse(data) }); }
                catch (e) { resolve({ ok: false }); }
            });
        });

        req.on('error', () => resolve({ ok: false }));
        req.on('timeout', () => { req.destroy(); resolve({ ok: false }); });
        req.write(payload);
        req.end();
    });
}

// ─────────────────────────────────────────────
//  MERGE RULE-BASED + ML RESULTS
// ─────────────────────────────────────────────
function mergeResults(ruleResult, mlResult) {

    // If ML is unavailable, return rule-based only
    if (!mlResult || !mlResult.ok || !mlResult.data) {
        return { ...ruleResult, mlUsed: false, mlNote: 'ML model offline — rule-based analysis only.' };
    }

    const ml = mlResult.data;

    // ML says invalid input
    if (ml.label === 'invalid_input') {
        const invalidExp = ruleResult.explanation ? {
            ...ruleResult.explanation,
            mlAssessment: { label: 'invalid_input', confidence: 0 }
        } : ruleResult.explanation;
        return { ...ruleResult, mlUsed: true, mlLabel: 'invalid_input', mlConfidence: 0, explanation: invalidExp };
    }

    // ─── Map ML label to display classification ───
    const mlLabelMap = {
        genuine_job: '✅ Genuine Job',
        fake_job: '❌ Fake Job / Scam',
        scam_message: '❌ Scam Message',
        scam_email: '❌ Scam Mail',
        investment_scam: '❌ Investment Scam',
        romance_scam: '❌ Romance / Social Scam',
        lottery_scam: '❌ Lottery / Prize Scam',
        legitimate_email: '✅ Legitimate Email',
        legitimate_message: '✅ Legitimate Message',
    };

    const mlConf = ml.confidence || 0;
    const ruleConf = ruleResult.confidenceScore || 0;           // capped 0-100, used for display and blending

    const scamLabels = new Set([
        'fake_job', 'scam_message', 'scam_email',
        'investment_scam', 'romance_scam', 'lottery_scam'
    ]);
    const genuineLabels = new Set([
        'genuine_job', 'legitimate_email', 'legitimate_message'
    ]);

    // ─── Calculate ML scam risk ──────────────────────────────────────────────
    // When per-class probabilities are provided by the ML model, calculate the
    // actual scam risk by summing the probabilities of all scam classes.
    // This avoids treating the entire residual uncertainty of a genuine prediction
    // as an affirmative scam signal in a multiclass (9-class) model.
    let mlScamRisk;
    if (ml.probabilities && typeof ml.probabilities === 'object' && Object.keys(ml.probabilities).length > 0) {
        let scamProbSum = 0;
        let totalProbSum = 0;
        for (const [key, val] of Object.entries(ml.probabilities)) {
            const num = Number(val);
            if (!isNaN(num) && num >= 0) {
                totalProbSum += num;
                if (scamLabels.has(key)) {
                    scamProbSum += num;
                }
            }
        }
        if (totalProbSum > 0) {
            mlScamRisk = Math.round((scamProbSum / totalProbSum) * 100);
        }
    }

    // Safe fallback when per-class probabilities are missing or malformed:
    if (typeof mlScamRisk !== 'number') {
        if (scamLabels.has(ml.label)) {
            mlScamRisk = mlConf;
        } else if (genuineLabels.has(ml.label)) {
            // In the 9-class model, 6 of the 8 remaining non-predicted classes are scam.
            // Allocate the residual uncertainty proportionately rather than assuming 100%.
            mlScamRisk = Math.round((100 - mlConf) * (6 / 8));
        } else {
            mlScamRisk = mlConf;
        }
    }

    // Weighted blend: 60% ML scam-risk + 40% rule score (strictly capped to 0-100)
    // Both mlScamRisk (0-100) and ruleConf (0-100) are normalized so the rule
    // engine cannot contribute more than its allocated 40% weight.
    const blendedScore = Math.min(Math.round(mlScamRisk * 0.60 + ruleConf * 0.40), 100);

    // ─── Derive final classification from the BLENDED score ─────────────────
    // The blended score reflects the combined verdict of both engines.
    // Using the ML label alone when mlConf >= 65 caused contradictions:
    // e.g. ML says "Genuine Job" (70%) but rule engine scores 100 (full scam)
    // → blended = 82, which is clearly scam — the label must agree.
    // We use the same thresholds as the rule engine (>=60 scam, >=20 suspicious)
    // applied to the blended score, preserving the 60/40 hybrid intent.
    const finalType = ml.label ? (
        { genuine_job: 'job', fake_job: 'job', scam_email: 'email',
          legitimate_email: 'email', scam_message: 'message',
          legitimate_message: 'message', investment_scam: 'finance',
          romance_scam: 'romance', lottery_scam: 'lottery' }[ml.label]
        || ruleResult.contentType
    ) : ruleResult.contentType;

    let finalClassification;
    if (blendedScore >= 60) {
        if (finalType === 'email')        finalClassification = '❌ Scam Mail';
        else if (finalType === 'message') finalClassification = '❌ Scam Message';
        else if (finalType === 'finance') finalClassification = '❌ Investment Scam';
        else if (finalType === 'romance') finalClassification = '❌ Romance / Social Scam';
        else if (finalType === 'lottery') finalClassification = '❌ Lottery / Prize Scam';
        else                              finalClassification = '❌ Fake Job / Scam';
    } else if (blendedScore >= 20) {
        if (finalType === 'email')        finalClassification = '⚠️ Suspicious Email';
        else if (finalType === 'message') finalClassification = '⚠️ Suspicious Message';
        else                              finalClassification = '⚠️ Suspicious Job Post';
    } else {
        if (finalType === 'job')          finalClassification = '✅ Genuine Job';
        else if (finalType === 'email')   finalClassification = '✅ Legitimate Email';
        else if (finalType === 'message') finalClassification = '✅ Legitimate Message';
        else                              finalClassification = ruleResult.classification;
    }

    // Add ML analysis as an indicator
    const mlIndicator = `🤖 ML Model (${ml.label?.replace(/_/g, ' ')}): ${mlConf}% confidence`;
    const mergedIndicators = [...(ruleResult.indicators || []), mlIndicator];

    // Enrich explanation with ML assessment and align summary with final blended verdict
    let explanation = ruleResult.explanation;
    if (explanation) {
        let updatedSummary = explanation.summary;
        const lowerFinal = (finalClassification || '').toLowerCase();
        if (lowerFinal.includes('scam') || lowerFinal.includes('fake')) {
            updatedSummary = 'This content contains multiple indicators commonly associated with fraudulent activity. Review the evidence below before taking any action.';
        } else if (lowerFinal.includes('suspicious')) {
            updatedSummary = 'This content exhibits suspicious patterns that warrant caution. Review the identified indicators before proceeding.';
        } else if (!ruleResult.isInvalidInput) {
            updatedSummary = 'No major scam indicators were detected by the current detection system. Continue to verify important job offers through official company channels.';
        }

        explanation = {
            ...explanation,
            summary: updatedSummary,
            mlAssessment: ml.label ? {
                label: ml.label,
                confidence: mlConf
            } : null
        };
    }

    return {
        ...ruleResult,
        classification: finalClassification,
        contentType: finalType,
        confidenceScore: blendedScore,
        indicators: mergedIndicators,
        mlUsed: true,
        mlLabel: ml.label,
        mlDisplay: ml.display,
        mlConfidence: mlConf,
        mlProbabilities: ml.probabilities || {},
        ruleScore: ruleConf,
        blendedScore,
        explanation
    };
}

// ─────────────────────────────────────────────
//  SCAN TEXT
// ─────────────────────────────────────────────
router.post('/text', auth, async (req, res) => {
    try {
        const { content } = req.body;
        if (!content) return res.status(400).json({ message: 'Content is required' });

        // Run rule-based + ML in parallel
        const [ruleResult, mlResult] = await Promise.all([
            Promise.resolve(analyzeScamContent(content)),
            callMLApi(content)
        ]);

        const analysis = mergeResults(ruleResult, mlResult);

        // Save to DB if connection is available
        try {
            await db.execute(
                'INSERT INTO job_history (user_id, original_content, extracted_text, classification, scam_indicators, confidence_score) VALUES (?, ?, ?, ?, ?, ?)',
                [
                    req.session.userId,
                    content,
                    content,
                    analysis.classification,
                    JSON.stringify(indicatorsToText(analysis.indicators)),
                    analysis.confidenceScore
                ]
            );
        } catch (dbErr) {
            console.warn('⚠️ Warning: Could not persist scan to database (DB offline):', dbErr.code || dbErr.message);
        }

        res.json(analysis);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Error processing text' });
    }
});

// ─────────────────────────────────────────────
//  SCAN FILE (Image/PDF)
// ─────────────────────────────────────────────
router.post('/file', auth, (req, res, next) => {
    upload.single('file')(req, res, (err) => {
        if (err) {
            if (err instanceof multer.MulterError) {
                return res.status(400).json({ message: `File upload error: ${err.message}` });
            }
            return res.status(400).json({ message: err.message || 'Invalid file uploaded' });
        }
        next();
    });
}, async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ message: 'File is required' });

        let extractedText = '';

        const ext = path.extname(req.file.originalname).toLowerCase();
        const isImage = (req.file.mimetype && req.file.mimetype.startsWith('image/')) ||
            ['.jpg', '.jpeg', '.png', '.webp', '.bmp', '.tiff'].includes(ext);

        if (isImage) {
            const { data: { text } } = await Tesseract.recognize(req.file.buffer, 'eng');
            extractedText = text;
        } else if (req.file.mimetype === 'application/pdf' || ext === '.pdf') {
            extractedText = 'PDF Content extraction not fully implemented. Please paste text for PDF analysis.';
        }

        const normalizedText = extractedText
            .replace(/\r?\n|\r/g, ' ')
            .replace(/\s+/g, ' ')
            .trim();

        const [ruleResult, mlResult] = await Promise.all([
            Promise.resolve(analyzeScamContent(normalizedText)),
            callMLApi(normalizedText)
        ]);

        const analysis = mergeResults(ruleResult, mlResult);

        // Save to DB if connection is available
        try {
            await db.execute(
                'INSERT INTO job_history (user_id, original_content, extracted_text, classification, scam_indicators, confidence_score, file_path) VALUES (?, ?, ?, ?, ?, ?, ?)',
                [
                    req.session.userId,
                    'File Uploaded: ' + req.file.originalname,
                    extractedText,
                    analysis.classification,
                    JSON.stringify(indicatorsToText(analysis.indicators)),
                    analysis.confidenceScore,
                    req.file.originalname  // store original filename; no disk path in cloud
                ]
            );
        } catch (dbErr) {
            console.warn('⚠️ Warning: Could not persist scan to database (DB offline):', dbErr.code || dbErr.message);
        }

        res.json({ ...analysis, extractedText });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Error processing file' });
    }
});

// ─────────────────────────────────────────────
//  ML STATUS CHECK
// ─────────────────────────────────────────────
router.get('/ml-status', auth, async (req, res) => {
    try {
        const result = await callMLApi('test');
        res.json({ mlOnline: result.ok });
    } catch {
        res.json({ mlOnline: false });
    }
});

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
function indicatorsToText(indicators) {
    return indicators && indicators.length > 0
        ? indicators
        : ['No clear indicators found.'];
}

module.exports = router;
