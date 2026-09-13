import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Box, Grid, Card, CardContent, Typography, Button } from '@mui/material';
import DocumentScannerIcon from '@mui/icons-material/DocumentScanner';
import SecurityIcon from '@mui/icons-material/Security';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';
import SensorsIcon from '@mui/icons-material/Sensors';
import ArrowForwardIcon from '@mui/icons-material/ArrowForward';
import AttachMoneyIcon from '@mui/icons-material/AttachMoney';
import DomainVerificationIcon from '@mui/icons-material/DomainVerification';

function StatCard({ title, value, icon, trend, accent }) {
    return (
        <motion.div initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.45 }} style={{ height: '100%' }}>
            <Card sx={{
                height: '100%',
                background: 'rgba(255,255,255,0.85)',
                backdropFilter: 'blur(12px)',
                border: '1px solid rgba(0,0,0,0.07)',
                boxShadow: '0 2px 20px rgba(0,0,0,0.06)',
                borderTop: `3px solid ${accent}`,
                transition: 'transform 0.25s, box-shadow 0.25s',
                '&:hover': { transform: 'translateY(-4px)', boxShadow: '0 8px 32px rgba(0,0,0,0.1)' },
            }}>
                <CardContent sx={{ p: 3.5, display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 2 }}>
                    <Box>
                        <Typography sx={{ fontSize: '0.65rem', fontWeight: 800, letterSpacing: '0.15em', color: '#aaaaaa', textTransform: 'uppercase', mb: 1 }}>{title}</Typography>
                        <Typography variant="h3" sx={{ fontWeight: 900, fontFamily: 'Outfit, sans-serif', lineHeight: 1, mb: 0.5, color: '#111111' }}>{value}</Typography>
                        <Typography sx={{ fontSize: '0.72rem', color: '#bbbbbb', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.08em' }}>{trend}</Typography>
                    </Box>
                    <Box sx={{ width: 56, height: 56, borderRadius: 3, background: `${accent}12`, border: `1px solid ${accent}25`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                        {icon}
                    </Box>
                </CardContent>
            </Card>
        </motion.div>
    );
}

export default function DashboardHome() {
    const navigate = useNavigate();
    return (
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3.5 }}>
            <Grid container spacing={3}>
                <Grid item xs={12} md={4}>
                    <StatCard title="Threats Analyzed" value="12" icon={<SecurityIcon sx={{ color: '#7c3aed', fontSize: 26 }} />} trend="+2 in last scan" accent="#7c3aed" />
                </Grid>
                <Grid item xs={12} md={4}>
                    <StatCard title="Malicious Detected" value="4" icon={<WarningAmberIcon sx={{ color: '#dc2626', fontSize: 26 }} />} trend="Neutralized" accent="#dc2626" />
                </Grid>
                <Grid item xs={12} md={4}>
                    <StatCard title="Security Coverage" value="98%" icon={<SensorsIcon sx={{ color: '#059669', fontSize: 26 }} />} trend="Optimal" accent="#059669" />
                </Grid>
            </Grid>

            {/* CTA */}
            <motion.div initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.45, delay: 0.15 }}>
                <Card sx={{
                    background: 'rgba(255,255,255,0.9)',
                    backdropFilter: 'blur(12px)',
                    border: '1px solid rgba(0,0,0,0.07)',
                    boxShadow: '0 4px 32px rgba(124,58,237,0.1)',
                    textAlign: 'center', overflow: 'hidden', position: 'relative',
                }}>
                    <Box sx={{ position: 'absolute', top: -60, right: -60, width: 250, height: 250, background: 'radial-gradient(circle, rgba(124,58,237,0.06) 0%, transparent 70%)', borderRadius: '50%', pointerEvents: 'none' }} />
                    <Box sx={{ position: 'absolute', bottom: -50, left: -50, width: 200, height: 200, background: 'radial-gradient(circle, rgba(249,115,22,0.05) 0%, transparent 70%)', borderRadius: '50%', pointerEvents: 'none' }} />
                    <CardContent sx={{ py: 6, px: 4, position: 'relative' }}>
                        <Box sx={{ width: 80, height: 80, borderRadius: 4, background: 'rgba(124,58,237,0.08)', border: '1px solid rgba(124,58,237,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center', mx: 'auto', mb: 3 }}>
                            <DocumentScannerIcon sx={{ fontSize: 40, color: '#7c3aed' }} />
                        </Box>
                        <Typography variant="h4" sx={{ fontWeight: 900, fontFamily: 'Outfit, sans-serif', mb: 2, color: '#111111' }}>Initiate Security Sweep</Typography>
                        <Typography sx={{ color: '#888888', maxWidth: 500, mx: 'auto', mb: 4, lineHeight: 1.75, fontSize: '0.95rem' }}>
                            Protect your professional future from deceptive recruiters. Deploy AI scanners to audit job descriptions and communication artifacts instantly.
                        </Typography>
                        <Button variant="contained" size="large" onClick={() => navigate('scan')} endIcon={<ArrowForwardIcon />}
                            sx={{ py: 1.7, px: 6, fontSize: '1.05rem', boxShadow: '0 4px 22px rgba(124,58,237,0.28)' }}>
                            Deploy Scanner
                        </Button>
                    </CardContent>
                </Card>
            </motion.div>

            {/* Tips */}
            <Grid container spacing={3}>
                <Grid item xs={12} md={6}>
                    <Card sx={{ background: 'rgba(255,255,255,0.8)', backdropFilter: 'blur(12px)', border: '1px solid rgba(0,0,0,0.06)', borderLeft: '4px solid #d97706', '&:hover': { transform: 'translateY(-2px)', boxShadow: '0 6px 24px rgba(0,0,0,0.08)' }, transition: 'all 0.2s' }}>
                        <CardContent sx={{ p: 3.5 }}>
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, mb: 2 }}>
                                <AttachMoneyIcon sx={{ color: '#d97706', fontSize: 20 }} />
                                <Typography sx={{ fontSize: '0.68rem', fontWeight: 800, letterSpacing: '0.15em', color: '#d97706', textTransform: 'uppercase' }}>Financial Indicator</Typography>
                            </Box>
                            <Typography sx={{ color: '#555555', lineHeight: 1.75, fontSize: '0.9rem' }}>
                                Legitimate recruitment agencies will <strong style={{ color: '#111111' }}>NEVER</strong> solicit security deposits, equipment fees, or upfront training costs.
                            </Typography>
                        </CardContent>
                    </Card>
                </Grid>
                <Grid item xs={12} md={6}>
                    <Card sx={{ background: 'rgba(255,255,255,0.8)', backdropFilter: 'blur(12px)', border: '1px solid rgba(0,0,0,0.06)', borderLeft: '4px solid #7c3aed', '&:hover': { transform: 'translateY(-2px)', boxShadow: '0 6px 24px rgba(0,0,0,0.08)' }, transition: 'all 0.2s' }}>
                        <CardContent sx={{ p: 3.5 }}>
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, mb: 2 }}>
                                <DomainVerificationIcon sx={{ color: '#7c3aed', fontSize: 20 }} />
                                <Typography sx={{ fontSize: '0.68rem', fontWeight: 800, letterSpacing: '0.15em', color: '#7c3aed', textTransform: 'uppercase' }}>Domain Verification</Typography>
                            </Box>
                            <Typography sx={{ color: '#555555', lineHeight: 1.75, fontSize: '0.9rem' }}>
                                Verify recruitment correspondence originates from an authenticated enterprise domain, not <strong style={{ color: '#111111' }}>public webmail</strong>.
                            </Typography>
                        </CardContent>
                    </Card>
                </Grid>
            </Grid>
        </Box>
    );
}
