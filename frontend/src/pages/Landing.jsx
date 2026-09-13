import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import {
    Box, AppBar, Toolbar, Typography, Button, Container,
    Grid, Card, CardContent, Chip, Stack, Divider
} from '@mui/material';
import SecurityIcon from '@mui/icons-material/Security';
import FlashOnIcon from '@mui/icons-material/FlashOn';
import LockIcon from '@mui/icons-material/Lock';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';

export default function Landing({ user }) {
    return (
        <Box sx={{ minHeight: '100vh', background: '#f5f5f5', color: '#111111' }}>

            {/* Navbar */}
            <AppBar position="sticky" elevation={0}>
                <Toolbar sx={{ maxWidth: 1200, mx: 'auto', width: '100%', px: { xs: 2, md: 4 }, py: 1 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, flexGrow: 1 }}>
                        <Box sx={{
                            width: 38, height: 38,
                            background: 'linear-gradient(135deg, #7c3aed, #f97316)',
                            borderRadius: 2,
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            boxShadow: '0 4px 14px rgba(124,58,237,0.35)',
                        }}>
                            <SecurityIcon sx={{ color: 'white', fontSize: 20 }} />
                        </Box>
                        <Typography variant="h6" sx={{ fontWeight: 900, letterSpacing: '-0.02em', fontFamily: 'Outfit, sans-serif', color: '#111111' }}>
                            Trust<span style={{ color: '#7c3aed' }}>Shield</span>{' '}
                            <span style={{ color: '#f97316' }}>AI</span>
                        </Typography>
                    </Box>
                    <Stack direction="row" spacing={2} alignItems="center">
                        {user ? (
                            <Button component={Link} to="/dashboard" variant="contained" color="primary">Go to Dashboard</Button>
                        ) : (
                            <>
                                <Button component={Link} to="/login" sx={{ color: '#555555', fontWeight: 600 }}>Login</Button>
                                <Button component={Link} to="/register" variant="contained" color="primary">Get Started</Button>
                            </>
                        )}
                    </Stack>
                </Toolbar>
            </AppBar>

            {/* Hero */}
            <Box sx={{ pt: { xs: 10, md: 14 }, pb: { xs: 10, md: 16 }, position: 'relative', overflow: 'hidden' }}>
                {/* Decorative blobs */}
                <Box sx={{ position: 'absolute', top: -80, right: -80, width: 500, height: 500, background: 'radial-gradient(circle, rgba(124,58,237,0.09) 0%, transparent 70%)', borderRadius: '50%', pointerEvents: 'none' }} />
                <Box sx={{ position: 'absolute', bottom: -60, left: -60, width: 400, height: 400, background: 'radial-gradient(circle, rgba(249,115,22,0.08) 0%, transparent 70%)', borderRadius: '50%', pointerEvents: 'none' }} />

                <Container maxWidth="lg" sx={{ textAlign: 'center', position: 'relative' }}>
                    <motion.div initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7 }}>
                        <Chip
                            label="🛡️ AI-Powered Security for Job Seekers"
                            sx={{
                                mb: 4, px: 2,
                                background: 'rgba(124,58,237,0.08)',
                                border: '1px solid rgba(124,58,237,0.2)',
                                color: '#7c3aed', fontWeight: 700, fontSize: '0.82rem',
                            }}
                        />
                        <Typography variant="h1" sx={{
                            fontSize: { xs: '2.6rem', md: '4.5rem', lg: '5.5rem' },
                            fontWeight: 900, lineHeight: 1.08, mb: 3,
                            fontFamily: 'Outfit, sans-serif', color: '#111111',
                        }}>
                            Don't Let{' '}
                            <Box component="span" sx={{ color: '#7c3aed' }}>Fake Jobs</Box>
                            <br />
                            Shatter Your{' '}
                            <Box component="span" sx={{ color: '#f97316' }}>Dreams.</Box>
                        </Typography>
                    </motion.div>

                    <motion.div initial={{ opacity: 0, y: 15 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7, delay: 0.2 }}>
                        <Typography variant="h6" sx={{ color: '#666666', maxWidth: 640, mx: 'auto', mb: 6, lineHeight: 1.75, fontWeight: 400 }}>
                            Protect yourself from sophisticated employment scams. Our AI detects fraudulent patterns in job postings, emails, and messages in milliseconds.
                        </Typography>
                    </motion.div>

                    <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: 0.5, delay: 0.35 }}>
                        <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} justifyContent="center">
                            <Button
                                component={Link} to={user ? '/dashboard/scan' : '/register'}
                                variant="contained" color="primary" size="large"
                                startIcon={<SecurityIcon />}
                                sx={{ py: 1.8, px: 5, fontSize: '1.05rem', boxShadow: '0 4px 20px rgba(124,58,237,0.3)' }}
                            >
                                Verify a Job Now
                            </Button>
                            <Button
                                href="#how-it-works" variant="outlined" size="large"
                                sx={{ py: 1.8, px: 5, fontSize: '1.05rem', borderColor: 'rgba(0,0,0,0.15)', color: '#444444', '&:hover': { borderColor: '#7c3aed', background: 'rgba(124,58,237,0.04)' } }}
                            >
                                How it Works
                            </Button>
                        </Stack>
                    </motion.div>
                </Container>
            </Box>

            {/* Stats */}
            <Box sx={{ py: 5, background: 'rgba(255,255,255,0.7)', backdropFilter: 'blur(10px)', borderTop: '1px solid rgba(0,0,0,0.06)', borderBottom: '1px solid rgba(0,0,0,0.06)' }}>
                <Container maxWidth="lg">
                    <Grid container spacing={2} justifyContent="center">
                        {[
                            { value: '500K+', label: 'Scans Completed' },
                            { value: '98.7%', label: 'Detection Accuracy' },
                            { value: '12K+', label: 'Scams Blocked Daily' },
                            { value: '<1s', label: 'Analysis Time' },
                        ].map((stat, i) => (
                            <Grid item xs={6} md={3} key={i} sx={{ textAlign: 'center', py: 2 }}>
                                <Typography variant="h4" sx={{ fontWeight: 900, fontFamily: 'Outfit, sans-serif', color: i % 2 === 0 ? '#7c3aed' : '#f97316' }}>{stat.value}</Typography>
                                <Typography sx={{ color: '#999999', fontSize: '0.85rem', mt: 0.5 }}>{stat.label}</Typography>
                            </Grid>
                        ))}
                    </Grid>
                </Container>
            </Box>

            {/* Features */}
            <Box id="how-it-works" sx={{ py: { xs: 8, md: 12 }, background: '#f5f5f5' }}>
                <Container maxWidth="lg">
                    <Box sx={{ textAlign: 'center', mb: 8 }}>
                        <Typography variant="h3" sx={{ fontWeight: 800, mb: 2, fontFamily: 'Outfit, sans-serif', color: '#111111' }}>Advanced Threat Detection</Typography>
                        <Typography sx={{ color: '#888888', fontSize: '1.05rem' }}>Sophisticated analysis tools at your fingertips</Typography>
                    </Box>
                    <Grid container spacing={4}>
                        {[
                            { icon: <FlashOnIcon sx={{ fontSize: 36, color: '#f59e0b' }} />, title: 'Instant OCR Scan', desc: 'Upload screenshots of emails or WhatsApp messages. We extract and analyze text automatically using advanced optical character recognition.', accent: '#f59e0b' },
                            { icon: <LockIcon sx={{ fontSize: 36, color: '#7c3aed' }} />, title: 'Pattern Recognition', desc: 'Our NLP engine detects urgent language, requests for money, suspicious domain mismatches, and unrealistic salary offers.', accent: '#7c3aed' },
                            { icon: <WarningAmberIcon sx={{ fontSize: 36, color: '#ef4444' }} />, title: 'Global Threat Intel', desc: 'Cross-reference with our massive database of known recruiter scams and blacklisted fake company directories updated hourly.', accent: '#ef4444' },
                        ].map((feat, i) => (
                            <Grid item xs={12} md={4} key={i}>
                                <motion.div initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }} transition={{ delay: i * 0.12 }}>
                                    <Card sx={{
                                        height: '100%',
                                        background: 'rgba(255,255,255,0.8)',
                                        backdropFilter: 'blur(12px)',
                                        border: '1px solid rgba(0,0,0,0.07)',
                                        boxShadow: '0 2px 20px rgba(0,0,0,0.06)',
                                        transition: 'transform 0.3s, box-shadow 0.3s',
                                        '&:hover': { transform: 'translateY(-5px)', boxShadow: `0 12px 40px rgba(0,0,0,0.1)` },
                                    }}>
                                        <CardContent sx={{ p: 4 }}>
                                            <Box sx={{ width: 60, height: 60, borderRadius: 3, background: `${feat.accent}14`, border: `1px solid ${feat.accent}30`, display: 'flex', alignItems: 'center', justifyContent: 'center', mb: 2.5 }}>
                                                {feat.icon}
                                            </Box>
                                            <Typography variant="h6" sx={{ fontWeight: 800, mb: 1.5, color: '#111111' }}>{feat.title}</Typography>
                                            <Typography sx={{ color: '#777777', lineHeight: 1.7, fontSize: '0.92rem' }}>{feat.desc}</Typography>
                                        </CardContent>
                                    </Card>
                                </motion.div>
                            </Grid>
                        ))}
                    </Grid>
                </Container>
            </Box>

            {/* Footer */}
            <Box component="footer" sx={{ py: 5, textAlign: 'center', background: 'rgba(255,255,255,0.8)', borderTop: '1px solid rgba(0,0,0,0.07)' }}>
                <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 1, mb: 1 }}>
                    <SecurityIcon sx={{ color: '#7c3aed', fontSize: 18 }} />
                    <Typography sx={{ fontWeight: 800, fontFamily: 'Outfit, sans-serif', color: '#111111' }}>
                        Trust<span style={{ color: '#7c3aed' }}>Shield</span>{' '}
                        <span style={{ color: '#f97316' }}>AI</span>
                    </Typography>
                </Box>
                <Typography sx={{ color: '#aaaaaa', fontSize: '0.85rem' }}>© 2026 TrustShield AI. Secure Your Career.</Typography>
            </Box>
        </Box>
    );
}
