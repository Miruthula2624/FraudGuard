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
//  MULTER SETUP
// ─────────────────────────────────────────────
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadPath = path.join(__dirname, '../uploads');
        if (!fs.existsSync(uploadPath)) fs.mkdirSync(uploadPath);
        cb(null, uploadPath);
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + '-' + file.originalname);
    }
});

const upload = multer({
    storage,
    fileFilter: (req, file, cb) => {
        const allowedTypes = ['.jpg', '.jpeg', '.png', '.pdf'];
        const ext = path.extname(file.originalname).toLowerCase();
        if (allowedTypes.includes(ext)) cb(null, true);
        else cb(new Error('Only images and PDFs are allowed'));
    }
});

// ─────────────────────────────────────────────
//  ML API CALLER (Flask on port 5001)
// ─────────────────────────────────────────────
const ML_API_URL = 'http://127.0.0.1:5001/predict';

function callMLApi(text) {
    return new Promise((resolve) => {
        const payload = JSON.stringify({ text });
        const options = {
            hostname: '127.0.0.1',
            port: 5001,
            path: '/predict',
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

    const mlClassification = mlLabelMap[ml.label] || ml.display || ruleResult.classification;
    const mlConf = ml.confidence || 0;
    const ruleConf = ruleResult.confidenceScore || 0;

    // Weighted blend: 60% ML + 40% rule engine
    const blendedScore = Math.round(mlConf * 0.60 + ruleConf * 0.40);

    // Decision: if ML is highly confident (>= 75%), trust ML label
    // Otherwise fall back to rule-based classification
    const finalClassification = mlConf >= 65
        ? mlClassification
        : ruleResult.classification;

    // Merge content type
    const mlTypeMap = {
        genuine_job: 'job', fake_job: 'job', scam_email: 'email',
        legitimate_email: 'email', scam_message: 'message',
        legitimate_message: 'message', investment_scam: 'finance',
        romance_scam: 'romance', lottery_scam: 'lottery'
    };
    const finalType = ml.label ? (mlTypeMap[ml.label] || ruleResult.contentType) : ruleResult.contentType;

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
router.post('/file', auth, upload.single('file'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ message: 'File is required' });

        const filePath = req.file.path;
        let extractedText = '';

        if (req.file.mimetype.startsWith('image/')) {
            const { data: { text } } = await Tesseract.recognize(filePath, 'eng');
            extractedText = text;
        } else if (req.file.mimetype === 'application/pdf') {
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
                    req.file.filename
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
