import { useState, useEffect } from 'react';
import axios from '../api/axios';
import { motion } from 'framer-motion';
import { DateTime } from 'luxon';
import {
    Box, Card, CardContent, Typography, TextField, InputAdornment,
    Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
    IconButton, Tooltip, CircularProgress, LinearProgress, Chip, Paper
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import HistoryIcon from '@mui/icons-material/History';
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutline';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';

const getClassColor = (cls) => {
    if (!cls) return { color: '#059669', bg: '#ecfdf5', border: '#a7f3d0' };
    const c = cls.toLowerCase();
    if (c.includes('scam') || c.includes('fake')) return { color: '#dc2626', bg: '#fef2f2', border: '#fecaca' };
    if (c.includes('suspicious')) return { color: '#d97706', bg: '#fffbeb', border: '#fde68a' };
    return { color: '#059669', bg: '#ecfdf5', border: '#a7f3d0' };
};

const getProgressColor = (score) => {
    if (score > 60) return '#dc2626';
    if (score > 30) return '#d97706';
    return '#059669';
};

export default function HistoryPage() {
    const [history, setHistory] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [loading, setLoading] = useState(true);

    useEffect(() => { fetchHistory(); }, []);

    const fetchHistory = async () => {
        try { const res = await axios.get('/history'); setHistory(res.data); }
        catch { console.error('Failed to fetch history'); }
        finally { setLoading(false); }
    };

    const deleteItem = async (id) => {
        if (!confirm('Delete this scan result?')) return;
        try { await axios.delete(`/history/${id}`); setHistory(history.filter(item => item.id !== id)); }
        catch { alert('Failed to delete item'); }
    };

    const filtered = history.filter(item =>
        item.extracted_text?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        item.classification?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>

            {/* Search Bar */}
            <Card sx={{ background: 'rgba(255,255,255,0.85)', border: '1px solid rgba(0,0,0,0.07)', backdropFilter: 'blur(12px)' }}>
                <CardContent sx={{ p: 2.5, '&:last-child': { pb: 2.5 } }}>
                    <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2, alignItems: 'center', justifyContent: 'space-between' }}>
                        <TextField
                            placeholder="Search by classification or content..."
                            size="small" value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            InputProps={{ startAdornment: <InputAdornment position="start"><SearchIcon sx={{ color: '#cccccc', fontSize: 20 }} /></InputAdornment> }}
                            sx={{ minWidth: 300, '& .MuiOutlinedInput-root': { borderRadius: 2.5, background: '#fafafa' } }}
                        />
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                            <HistoryIcon sx={{ color: '#7c3aed', fontSize: 20 }} />
                            <Typography sx={{ fontSize: '0.75rem', fontWeight: 800, color: '#aaaaaa', textTransform: 'uppercase', letterSpacing: '0.12em' }}>
                                {filtered.length} Records
                            </Typography>
                        </Box>
                    </Box>
                </CardContent>
            </Card>

            {/* Content */}
            {loading ? (
                <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', py: 12, gap: 2 }}>
                    <CircularProgress sx={{ color: '#7c3aed' }} />
                    <Typography sx={{ color: '#cccccc', fontSize: '0.75rem', fontWeight: 800, letterSpacing: '0.15em', textTransform: 'uppercase' }}>Loading...</Typography>
                </Box>
            ) : filtered.length === 0 ? (
                <Card sx={{ background: 'rgba(255,255,255,0.85)', border: '1px solid rgba(0,0,0,0.07)' }}>
                    <CardContent sx={{ py: 12, textAlign: 'center' }}>
                        <Box sx={{ width: 72, height: 72, borderRadius: '50%', background: '#f5f5f5', border: '1px solid rgba(0,0,0,0.07)', display: 'flex', alignItems: 'center', justifyContent: 'center', mx: 'auto', mb: 3 }}>
                            <HistoryIcon sx={{ fontSize: 36, color: '#dddddd' }} />
                        </Box>
                        <Typography variant="h6" sx={{ fontWeight: 800, mb: 1, color: '#aaaaaa' }}>No Records Found</Typography>
                        <Typography sx={{ color: '#cccccc', maxWidth: 360, mx: 'auto', fontSize: '0.9rem' }}>Your scan history is empty. Start your first scan to begin tracking threats.</Typography>
                    </CardContent>
                </Card>
            ) : (
                <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.35 }}>
                    <TableContainer component={Paper} sx={{ background: 'rgba(255,255,255,0.9)', border: '1px solid rgba(0,0,0,0.07)', borderRadius: 4, overflow: 'hidden', boxShadow: '0 4px 24px rgba(0,0,0,0.06)' }}>
                        <Table>
                            <TableHead>
                                <TableRow>
                                    <TableCell>Security Rating</TableCell>
                                    <TableCell>Content Fragment</TableCell>
                                    <TableCell>Threat Confidence</TableCell>
                                    <TableCell>Timestamp</TableCell>
                                    <TableCell align="right">Actions</TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                                {filtered.map((item) => {
                                    const clsColor = getClassColor(item.classification);
                                    const progColor = getProgressColor(item.confidence_score);
                                    return (
                                        <TableRow key={item.id} sx={{
                                            borderBottom: '1px solid rgba(0,0,0,0.05)',
                                            transition: 'background 0.15s',
                                            '&:hover': { background: '#fafafa' },
                                            '&:last-child td': { border: 0 },
                                        }}>
                                            <TableCell>
                                                <Chip
                                                    icon={item.classification?.includes('Scam') || item.classification?.includes('Fake')
                                                        ? <WarningAmberIcon sx={{ fontSize: '16px !important', color: `${clsColor.color} !important` }} />
                                                        : <CheckCircleIcon sx={{ fontSize: '16px !important', color: `${clsColor.color} !important` }} />}
                                                    label={item.classification?.split(' / ')[0]} size="small"
                                                    sx={{ background: clsColor.bg, border: `1px solid ${clsColor.border}`, color: clsColor.color, fontWeight: 800, fontSize: '0.7rem' }}
                                                />
                                            </TableCell>
                                            <TableCell>
                                                <Typography sx={{ fontSize: '0.85rem', color: '#555555', fontWeight: 500, maxWidth: 220, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                                                    {item.extracted_text}
                                                </Typography>
                                            </TableCell>
                                            <TableCell>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, minWidth: 140 }}>
                                                    <LinearProgress variant="determinate" value={item.confidence_score} sx={{ flex: 1, '& .MuiLinearProgress-bar': { background: progColor } }} />
                                                    <Typography sx={{ fontSize: '0.75rem', fontWeight: 800, color: '#aaaaaa', minWidth: 34 }}>{item.confidence_score}%</Typography>
                                                </Box>
                                            </TableCell>
                                            <TableCell>
                                                <Typography sx={{ fontSize: '0.78rem', fontWeight: 600, color: '#aaaaaa', fontFamily: 'monospace' }}>
                                                    {DateTime.fromISO(item.created_at).isValid ? DateTime.fromISO(item.created_at).toFormat('yyyy-MM-dd · HH:mm') : '—'}
                                                </Typography>
                                            </TableCell>
                                            <TableCell align="right">
                                                <Tooltip title="Delete Record" arrow>
                                                    <IconButton onClick={() => deleteItem(item.id)} size="small"
                                                        sx={{ color: '#cccccc', '&:hover': { color: '#dc2626', background: 'rgba(220,38,38,0.07)' }, transition: 'all 0.18s' }}>
                                                        <DeleteOutlineIcon fontSize="small" />
                                                    </IconButton>
                                                </Tooltip>
                                            </TableCell>
                                        </TableRow>
                                    );
                                })}
                            </TableBody>
                        </Table>
                    </TableContainer>
                </motion.div>
            )}
        </Box>
    );
}
