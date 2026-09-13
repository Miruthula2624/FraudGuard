import { useState } from 'react';
import axios from '../api/axios';
import { motion, AnimatePresence } from 'framer-motion';
import {
    Box, Card, CardContent, Typography, Button, Tabs, Tab,
    TextField, CircularProgress, Chip, Paper, Grid, Alert
} from '@mui/material';
import SecurityIcon from '@mui/icons-material/Security';
import TextSnippetIcon from '@mui/icons-material/TextSnippet';
import ImageIcon from '@mui/icons-material/Image';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CancelIcon from '@mui/icons-material/Cancel';
import EmailIcon from '@mui/icons-material/Email';
import SmsIcon from '@mui/icons-material/Sms';
import WorkIcon from '@mui/icons-material/Work';
import HelpOutlineIcon from '@mui/icons-material/HelpOutline';
import BoltIcon from '@mui/icons-material/Bolt';

const getScheme = (cls) => {
    if (!cls) return 'green';
    const c = cls.toLowerCase();
    if (c.includes('scam') || c.includes('fake')) return 'red';
    if (c.includes('suspicious')) return 'amber';
    if (c.includes('invalid') || c.includes('unrecognized')) return 'violet';
    return 'green';
};

const schemes = {
    red: { color: '#dc2626', light: '#fef2f2', border: '#fecaca' },
    amber: { color: '#d97706', light: '#fffbeb', border: '#fde68a' },
    violet: { color: '#7c3aed', light: '#f5f3ff', border: '#ddd6fe' },
    green: { color: '#059669', light: '#ecfdf5', border: '#a7f3d0' },
};

const ContentTypeIcon = ({ contentType }) => {
    if (contentType === 'email') return <EmailIcon fontSize="small" />;
    if (contentType === 'message') return <SmsIcon fontSize="small" />;
    if (contentType === 'job') return <WorkIcon fontSize="small" />;
    return <HelpOutlineIcon fontSize="small" />;
};

const ClassificationIcon = ({ classification, size = 44 }) => {
    const c = (classification || '').toLowerCase();
    if (c.includes('invalid') || c.includes('unrecognized')) return <CancelIcon sx={{ fontSize: size }} />;
    if (c.includes('scam') || c.includes('fake') || c.includes('suspicious')) return <WarningAmberIcon sx={{ fontSize: size }} />;
    return <CheckCircleIcon sx={{ fontSize: size }} />;
};

const getDetailMessage = (classification) => {
    const c = (classification || '').toLowerCase();
    if (c.includes('invalid')) return { title: '⚠️ Invalid Input', body: 'The text appears too short or random. Please enter a real job description, email, or message.', tip: 'Try pasting an actual job posting, email, or suspicious message.' };
    if (c.includes('unrecognized')) return { title: '⚠️ Could Not Be Classified', body: "Doesn't match any known pattern. No major scam indicators found.", tip: 'Provide more context or a longer piece of text.' };
    if (c.includes('scam mail')) return { title: '🚨 Scam Email Detected', body: 'Matches known scam email patterns. Often impersonates banks or offers fake rewards.', tip: 'Do NOT click links or share personal details. Delete immediately.' };
    if (c.includes('scam message')) return { title: '🚨 Scam Message Detected', body: 'Fraudulent SMS/WhatsApp used to steal OTPs or bank details.', tip: 'Never share your OTP. Block and report the sender.' };
    if (c.includes('fake job') || c.includes('scam')) return { title: '🚨 Fake Job Detected', body: 'Multiple red flags. Scammers use fake jobs to collect fees or personal data.', tip: 'Never pay a fee to apply. Verify on official platforms.' };
    if (c.includes('suspicious')) return { title: '⚠️ Suspicious Content', body: 'Some warning signs present but not conclusively a scam.', tip: 'Research thoroughly. Avoid sharing financial info.' };
    if (c.includes('legitimate')) return { title: '✅ Legitimate Content', body: 'No significant scam indicators detected.', tip: 'Always stay vigilant — sophisticated phishing can look legitimate.' };
    return { title: '✅ Genuine Job Posting', body: 'No significant red flags detected.', tip: 'Always verify the company independently.' };
};

export default function ScanPage() {
    const [activeTab, setActiveTab] = useState(0);
    const [content, setContent] = useState('');
    const [file, setFile] = useState(null);
    const [loading, setLoading] = useState(false);
    const [result, setResult] = useState(null);
    const [error, setError] = useState('');

    const handleTextScan = async () => {
        if (!content.trim()) return setError('Please paste some content to analyze.');
        setLoading(true); setError(''); setResult(null);
        try { const res = await axios.post('/scan/text', { content }); setResult(res.data); }
        catch { setError('Analysis failed. Please try again.'); }
        finally { setLoading(false); }
    };

    const handleFileScan = async () => {
        if (!file) return setError('Please select a file');
        setLoading(true); setError(''); setResult(null);
        const fd = new FormData(); fd.append('file', file);
        try { const res = await axios.post('/scan/file', fd); setResult(res.data); }
        catch { setError("File processing failed."); }
        finally { setLoading(false); }
    };

    const s = result ? schemes[getScheme(result.classification)] : schemes.green;
    const detail = result ? getDetailMessage(result.classification) : null;

    return (
        <Box sx={{ maxWidth: 900, mx: 'auto', display: 'flex', flexDirection: 'column', gap: 3 }}>

            {/* Tab switcher */}
            <Box sx={{ display: 'flex', justifyContent: 'center' }}>
                <Paper sx={{ background: 'rgba(255,255,255,0.85)', backdropFilter: 'blur(12px)', border: '1px solid rgba(0,0,0,0.08)', borderRadius: 3, p: 0.5, display: 'inline-flex', boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
                    <Tabs value={activeTab} onChange={(_, v) => { setActiveTab(v); setResult(null); setError(''); }} TabIndicatorProps={{ style: { display: 'none' } }} sx={{ minHeight: 'unset' }}>
                        {[{ label: 'Paste Text', icon: <TextSnippetIcon fontSize="small" /> }, { label: 'Upload File', icon: <ImageIcon fontSize="small" /> }].map((tab, i) => (
                            <Tab key={i} icon={tab.icon} iconPosition="start" label={tab.label} sx={{
                                minHeight: 40, py: 1, px: 2.5, borderRadius: 2.5,
                                fontSize: '0.85rem', fontWeight: 700,
                                color: activeTab === i ? 'white' : '#888888',
                                background: activeTab === i ? 'linear-gradient(135deg, #7c3aed, #5b21b6)' : 'transparent',
                                boxShadow: activeTab === i ? '0 4px 14px rgba(124,58,237,0.3)' : 'none',
                                transition: 'all 0.2s',
                                '&.Mui-selected': { color: 'white' },
                            }} />
                        ))}
                    </Tabs>
                </Paper>
            </Box>

            {/* Input Card */}
            <Card sx={{ background: 'rgba(255,255,255,0.85)', backdropFilter: 'blur(12px)', border: '1px solid rgba(0,0,0,0.07)', boxShadow: '0 4px 24px rgba(0,0,0,0.07)' }}>
                <CardContent sx={{ p: 4 }}>
                    {activeTab === 0 ? (
                        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2.5 }}>
                            <TextField
                                label="Job Description / Message Content"
                                multiline rows={10} fullWidth
                                value={content} onChange={(e) => setContent(e.target.value)}
                                placeholder="Paste the suspicious job description, email, or message here..."
                                sx={{ '& .MuiOutlinedInput-root': { fontSize: '0.95rem', lineHeight: 1.7, background: '#fafafa' } }}
                            />
                            {content.trim() && (
                                <Typography sx={{ fontSize: '0.75rem', color: '#cccccc' }}>
                                    {content.trim().split(/\s+/).filter(Boolean).length} words · {content.length} chars
                                </Typography>
                            )}
                            <Button variant="contained" fullWidth disabled={loading} onClick={handleTextScan} size="large"
                                startIcon={loading ? <CircularProgress size={18} color="inherit" /> : <SecurityIcon />}
                                sx={{ py: 1.7, fontSize: '1rem', boxShadow: '0 4px 22px rgba(124,58,237,0.28)' }}>
                                {loading ? 'Performing Deep AI Scan...' : 'Run Security Scan'}
                            </Button>
                        </Box>
                    ) : (
                        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2.5 }}>
                            <Box component="label" htmlFor="file-upload" sx={{
                                border: '2px dashed rgba(0,0,0,0.12)', borderRadius: 4, p: 8,
                                display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', cursor: 'pointer',
                                background: '#fafafa', transition: 'all 0.2s',
                                '&:hover': { borderColor: 'rgba(124,58,237,0.4)', background: 'rgba(124,58,237,0.03)' },
                            }}>
                                <input id="file-upload" type="file" style={{ display: 'none' }} onChange={(e) => setFile(e.target.files[0])} accept=".jpg,.jpeg,.png,.pdf" />
                                <Box sx={{ width: 68, height: 68, borderRadius: '50%', background: 'rgba(124,58,237,0.08)', border: '1px solid rgba(124,58,237,0.18)', display: 'flex', alignItems: 'center', justifyContent: 'center', mb: 2.5 }}>
                                    <CloudUploadIcon sx={{ fontSize: 34, color: '#7c3aed' }} />
                                </Box>
                                <Typography variant="h6" sx={{ fontWeight: 800, mb: 0.5, color: '#111111' }}>{file ? file.name : 'Drop your document here'}</Typography>
                                <Typography sx={{ color: '#aaaaaa', maxWidth: 300, mb: 2, fontSize: '0.9rem' }}>{file ? 'File selected and ready for extraction' : 'Select a screenshot or PDF of the job posting'}</Typography>
                                {!file && <Chip label="Browse Files" sx={{ background: 'rgba(124,58,237,0.08)', color: '#7c3aed', border: '1px solid rgba(124,58,237,0.18)', fontWeight: 700 }} />}
                                <Typography sx={{ mt: 2, fontSize: '0.68rem', color: '#cccccc', letterSpacing: '0.15em', textTransform: 'uppercase' }}>Max 5MB · JPG, PNG, PDF</Typography>
                            </Box>
                            <Button variant="contained" fullWidth disabled={loading || !file} onClick={handleFileScan} size="large"
                                startIcon={loading ? <CircularProgress size={18} color="inherit" /> : <SecurityIcon />}
                                sx={{ py: 1.7, fontSize: '1rem', boxShadow: '0 4px 22px rgba(124,58,237,0.28)', '&.Mui-disabled': { opacity: 0.35 } }}>
                                {loading ? 'Extracting & Analyzing...' : 'Analyze Document'}
                            </Button>
                        </Box>
                    )}
                    {error && <Alert severity="error" sx={{ mt: 2.5, borderRadius: 2 }}>{error}</Alert>}
                </CardContent>
            </Card>

            {/* Results */}
            <AnimatePresence>
                {result && (
                    <motion.div initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }} transition={{ duration: 0.4 }}>
                        <Card sx={{ background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(12px)', border: `1px solid ${s.border}`, boxShadow: `0 4px 30px rgba(0,0,0,0.08)`, overflow: 'hidden' }}>
                            <Box sx={{ height: 4, background: s.color }} />
                            <CardContent sx={{ p: { xs: 3, md: 4 } }}>
                                <Grid container spacing={4}>
                                    <Grid item xs={12} lg={8}>
                                        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                                            {result.contentTypeLabel && !result.isInvalidInput && (
                                                <Chip icon={<ContentTypeIcon contentType={result.contentType} />} label={result.contentTypeLabel}
                                                    sx={{ alignSelf: 'flex-start', background: s.light, color: s.color, border: `1px solid ${s.border}`, fontWeight: 700 }} />
                                            )}
                                            <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2 }}>
                                                <Box sx={{ p: 1.5, borderRadius: 3, background: s.light, color: s.color, flexShrink: 0, border: `1px solid ${s.border}` }}>
                                                    <ClassificationIcon classification={result.classification} size={40} />
                                                </Box>
                                                <Box>
                                                    <Typography variant="h5" sx={{ fontWeight: 900, fontFamily: 'Outfit, sans-serif', mb: 0.5, color: '#111111', textTransform: 'uppercase' }}>{result.classification}</Typography>
                                                    <Typography sx={{ color: '#888888', fontSize: '0.9rem' }}>AI analysis complete.</Typography>
                                                </Box>
                                            </Box>

                                            {detail && (
                                                <Paper sx={{ p: 3, background: s.light, border: `1px solid ${s.border}`, borderRadius: 3, boxShadow: 'none' }}>
                                                    <Typography sx={{ fontWeight: 800, fontSize: '1rem', mb: 1, color: s.color }}>{detail.title}</Typography>
                                                    <Typography sx={{ color: '#444444', fontSize: '0.9rem', lineHeight: 1.75, mb: 2 }}>{detail.body}</Typography>
                                                    <Box sx={{ pt: 2, borderTop: '1px solid rgba(0,0,0,0.07)', display: 'flex', gap: 1.5 }}>
                                                        <Typography>💡</Typography>
                                                        <Typography sx={{ color: '#777777', fontSize: '0.85rem', fontStyle: 'italic' }}>{detail.tip}</Typography>
                                                    </Box>
                                                </Paper>
                                            )}

                                            {!result.isInvalidInput && result.classification.toLowerCase().includes('genuine') && (
                                                <Grid container spacing={2}>
                                                    <Grid item xs={12} sm={6}>
                                                        <Paper sx={{ p: 2.5, background: s.light, border: `1px solid ${s.border}`, borderRadius: 3, boxShadow: 'none' }}>
                                                            <Typography sx={{ fontSize: '0.65rem', color: '#aaaaaa', fontWeight: 800, textTransform: 'uppercase', letterSpacing: '0.15em', mb: 1 }}>Identified Entity</Typography>
                                                            <Typography variant="h6" sx={{ fontWeight: 900, color: '#111111' }}>{result.companyName}</Typography>
                                                        </Paper>
                                                    </Grid>
                                                    <Grid item xs={12} sm={6}>
                                                        <Paper sx={{ p: 2.5, background: s.light, border: `1px solid ${s.border}`, borderRadius: 3, boxShadow: 'none' }}>
                                                            <Typography sx={{ fontSize: '0.65rem', color: '#aaaaaa', fontWeight: 800, textTransform: 'uppercase', letterSpacing: '0.15em', mb: 1 }}>Official Portal</Typography>
                                                            <Box component="a" href={result.appLink?.startsWith('http') ? result.appLink : '#'} target="_blank" rel="noreferrer"
                                                                sx={{ color: '#7c3aed', fontWeight: 700, display: 'flex', alignItems: 'center', gap: 0.5, textDecoration: 'none', '&:hover': { textDecoration: 'underline' } }}>
                                                                Visit Website <BoltIcon sx={{ fontSize: 14 }} />
                                                            </Box>
                                                        </Paper>
                                                    </Grid>
                                                </Grid>
                                            )}

                                            {result.indicators?.length > 0 && (
                                                <Box>
                                                    <Typography sx={{ fontSize: '0.65rem', fontWeight: 800, letterSpacing: '0.18em', color: '#bbbbbb', textTransform: 'uppercase', mb: 2 }}>
                                                        {result.isInvalidInput ? 'Analysis Notes' : 'Risk Indicators'}
                                                    </Typography>
                                                    <Grid container spacing={1.5}>
                                                        {result.indicators.map((ind, i) => (
                                                            <Grid item xs={12} sm={6} key={i}>
                                                                <Paper sx={{ p: 2, background: '#fafafa', border: '1px solid rgba(0,0,0,0.07)', borderRadius: 2, display: 'flex', gap: 1.5, alignItems: 'flex-start', boxShadow: 'none', '&:hover': { borderColor: s.border }, transition: 'border-color 0.18s' }}>
                                                                    <Box sx={{ width: 7, height: 7, borderRadius: '50%', background: s.color, mt: 0.7, flexShrink: 0 }} />
                                                                    <Typography sx={{ fontSize: '0.85rem', color: '#555555', lineHeight: 1.6 }}>{ind}</Typography>
                                                                </Paper>
                                                            </Grid>
                                                        ))}
                                                    </Grid>
                                                </Box>
                                            )}
                                        </Box>
                                    </Grid>

                                    {/* Score ring */}
                                    <Grid item xs={12} lg={4}>
                                        <Paper sx={{ p: 4, background: '#fafafa', border: '1px solid rgba(0,0,0,0.07)', borderRadius: 4, display: 'flex', flexDirection: 'column', alignItems: 'center', height: '100%', justifyContent: 'center', boxShadow: 'none' }}>
                                            <Typography sx={{ fontSize: '0.65rem', fontWeight: 800, letterSpacing: '0.18em', color: '#cccccc', textTransform: 'uppercase', mb: 3 }}>
                                                {result.isInvalidInput ? 'Validity Score' : 'Threat Score'}
                                            </Typography>
                                            <Box sx={{ position: 'relative', width: 150, height: 150, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                                <svg width="150" height="150" style={{ transform: 'rotate(-90deg)', position: 'absolute' }}>
                                                    <circle cx="75" cy="75" r="62" stroke="rgba(0,0,0,0.07)" strokeWidth="9" fill="none" />
                                                    <motion.circle cx="75" cy="75" r="62" stroke={s.color} strokeWidth="10" fill="none" strokeDasharray={390}
                                                        initial={{ strokeDashoffset: 390 }}
                                                        animate={{ strokeDashoffset: 390 - (390 * result.confidenceScore) / 100 }}
                                                        transition={{ duration: 1.4, ease: 'easeOut' }}
                                                        strokeLinecap="round" />
                                                </svg>
                                                <Typography variant="h3" sx={{ fontWeight: 900, fontFamily: 'Outfit, sans-serif', color: s.color }}>{result.confidenceScore}%</Typography>
                                            </Box>
                                            {!result.isInvalidInput && result.contentTypeLabel && (
                                                <Chip icon={<ContentTypeIcon contentType={result.contentType} />} label={result.contentTypeLabel} size="small"
                                                    sx={{ mt: 2.5, background: s.light, color: s.color, border: `1px solid ${s.border}`, fontWeight: 700 }} />
                                            )}
                                            <Typography sx={{ fontSize: '0.65rem', textAlign: 'center', mt: 2.5, color: '#cccccc', fontWeight: 800, letterSpacing: '0.12em', textTransform: 'uppercase' }}>
                                                Neural Confidence Rating
                                            </Typography>
                                        </Paper>
                                    </Grid>
                                </Grid>
                            </CardContent>
                        </Card>
                    </motion.div>
                )}
            </AnimatePresence>
        </Box>
    );
}
