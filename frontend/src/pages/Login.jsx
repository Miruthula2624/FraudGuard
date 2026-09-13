import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import axios from '../api/axios';
import { motion } from 'framer-motion';
import { Box, Card, CardContent, TextField, Button, Typography, Alert, CircularProgress, InputAdornment, Divider } from '@mui/material';
import SecurityIcon from '@mui/icons-material/Security';
import EmailIcon from '@mui/icons-material/Email';
import LockIcon from '@mui/icons-material/Lock';
import LoginIcon from '@mui/icons-material/Login';

export default function Login({ setUser }) {
    const [formData, setFormData] = useState({ email: '', password: '' });
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();

    const handleSubmit = async (e) => {
        e.preventDefault(); setLoading(true); setError('');
        try { const res = await axios.post('/auth/login', formData); setUser(res.data.user); navigate('/dashboard'); }
        catch (err) { setError(err.response?.data?.message || 'Login failed. Check your credentials.'); }
        finally { setLoading(false); }
    };

    return (
        <Box sx={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', p: 2, background: '#f5f5f5', position: 'relative' }}>
            <Box sx={{ position: 'absolute', top: '15%', right: '15%', width: 350, height: 350, background: 'radial-gradient(circle, rgba(124,58,237,0.07) 0%, transparent 70%)', borderRadius: '50%', pointerEvents: 'none' }} />
            <Box sx={{ position: 'absolute', bottom: '15%', left: '15%', width: 300, height: 300, background: 'radial-gradient(circle, rgba(249,115,22,0.07) 0%, transparent 70%)', borderRadius: '50%', pointerEvents: 'none' }} />

            <motion.div initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.55 }} style={{ width: '100%', maxWidth: 440, zIndex: 1 }}>
                <Card sx={{ background: 'rgba(255,255,255,0.85)', backdropFilter: 'blur(20px)', border: '1px solid rgba(0,0,0,0.09)', borderRadius: 4, overflow: 'hidden', boxShadow: '0 8px 40px rgba(0,0,0,0.1)' }}>
                    <Box sx={{ height: 4, background: 'linear-gradient(90deg, #7c3aed, #f97316)' }} />
                    <CardContent sx={{ p: 5 }}>
                        <Box sx={{ textAlign: 'center', mb: 4 }}>
                            <Box sx={{ width: 60, height: 60, background: 'rgba(124,58,237,0.09)', border: '1px solid rgba(124,58,237,0.2)', borderRadius: 3, display: 'flex', alignItems: 'center', justifyContent: 'center', mx: 'auto', mb: 2.5 }}>
                                <SecurityIcon sx={{ fontSize: 30, color: '#7c3aed' }} />
                            </Box>
                            <Typography variant="h5" sx={{ fontWeight: 900, fontFamily: 'Outfit, sans-serif', mb: 0.5, color: '#111111' }}>Welcome Back</Typography>
                            <Typography sx={{ color: '#888888', fontSize: '0.9rem' }}>
                                Sign in to <Box component="span" sx={{ color: '#7c3aed', fontWeight: 700 }}>TrustShield AI</Box>
                            </Typography>
                        </Box>

                        <Box component="form" onSubmit={handleSubmit} sx={{ display: 'flex', flexDirection: 'column', gap: 2.5 }}>
                            <TextField label="Email Address" type="email" required fullWidth value={formData.email}
                                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                InputProps={{ startAdornment: <InputAdornment position="start"><EmailIcon sx={{ color: '#bbbbbb', fontSize: 20 }} /></InputAdornment> }} />
                            <TextField label="Password" type="password" required fullWidth value={formData.password}
                                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                                InputProps={{ startAdornment: <InputAdornment position="start"><LockIcon sx={{ color: '#bbbbbb', fontSize: 20 }} /></InputAdornment> }} />
                            {error && <Alert severity="error" sx={{ borderRadius: 2 }}>{error}</Alert>}
                            <Button type="submit" variant="contained" fullWidth disabled={loading} size="large"
                                startIcon={loading ? <CircularProgress size={18} color="inherit" /> : <LoginIcon />}
                                sx={{ py: 1.5, mt: 0.5, fontSize: '1rem', boxShadow: '0 4px 20px rgba(124,58,237,0.28)' }}>
                                {loading ? 'Authenticating...' : 'Login'}
                            </Button>
                        </Box>

                        <Divider sx={{ my: 3 }} />
                        <Typography sx={{ textAlign: 'center', color: '#888888', fontSize: '0.9rem' }}>
                            New here?{' '}
                            <Box component={Link} to="/register" sx={{ color: '#7c3aed', fontWeight: 700, textDecoration: 'none', '&:hover': { textDecoration: 'underline' } }}>Create Account</Box>
                        </Typography>
                    </CardContent>
                </Card>
            </motion.div>
        </Box>
    );
}
