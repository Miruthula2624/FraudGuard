import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import {
    Box, Drawer, AppBar, Toolbar, Typography, List, ListItem,
    ListItemIcon, ListItemText, ListItemButton, Avatar, Chip, Divider
} from '@mui/material';
import SecurityIcon from '@mui/icons-material/Security';
import DashboardIcon from '@mui/icons-material/Dashboard';
import DocumentScannerIcon from '@mui/icons-material/DocumentScanner';
import HistoryIcon from '@mui/icons-material/History';
import LogoutIcon from '@mui/icons-material/Logout';
import FiberManualRecordIcon from '@mui/icons-material/FiberManualRecord';
import axios from '../api/axios';
import { motion } from 'framer-motion';

const DRAWER_WIDTH = 260;

export default function DashboardLayout({ user, setUser }) {
    const navigate = useNavigate();
    const location = useLocation();

    const handleLogout = async () => {
        try { await axios.post('/auth/logout'); setUser(null); navigate('/login'); }
        catch { console.error('Logout failed'); }
    };

    const navItems = [
        { icon: <DashboardIcon fontSize="small" />, label: 'Overview', path: '/dashboard' },
        { icon: <DocumentScannerIcon fontSize="small" />, label: 'New Scan', path: '/dashboard/scan' },
        { icon: <HistoryIcon fontSize="small" />, label: 'History', path: '/dashboard/history' },
    ];

    return (
        <Box sx={{ display: 'flex', minHeight: '100vh', background: '#f5f5f5' }}>

            {/* Sidebar */}
            <Drawer variant="permanent" sx={{
                width: DRAWER_WIDTH, flexShrink: 0,
                '& .MuiDrawer-paper': {
                    width: DRAWER_WIDTH, boxSizing: 'border-box',
                    background: 'rgba(255,255,255,0.92)',
                    backdropFilter: 'blur(20px)',
                    borderRight: '1px solid rgba(0,0,0,0.07)',
                    display: 'flex', flexDirection: 'column',
                    boxShadow: '2px 0 16px rgba(0,0,0,0.05)',
                },
            }}>
                {/* Logo */}
                <Box sx={{ px: 3, py: 3, display: 'flex', alignItems: 'center', gap: 1.5 }}>
                    <Box sx={{
                        width: 38, height: 38,
                        background: 'linear-gradient(135deg, #7c3aed, #f97316)',
                        borderRadius: 2, display: 'flex', alignItems: 'center', justifyContent: 'center',
                        boxShadow: '0 4px 14px rgba(124,58,237,0.3)', flexShrink: 0,
                    }}>
                        <SecurityIcon sx={{ color: 'white', fontSize: 20 }} />
                    </Box>
                    <Typography sx={{ fontWeight: 900, fontSize: '1.1rem', fontFamily: 'Outfit, sans-serif', color: '#111111', letterSpacing: '-0.01em' }}>
                        Trust<span style={{ color: '#7c3aed' }}>Shield</span>{' '}
                        <span style={{ color: '#f97316' }}>AI</span>
                    </Typography>
                </Box>

                <Divider />

                {/* Nav */}
                <Box sx={{ px: 2, pt: 2, flex: 1 }}>
                    <Typography sx={{ fontSize: '0.62rem', fontWeight: 800, letterSpacing: '0.18em', color: '#cccccc', textTransform: 'uppercase', px: 1.5, mb: 1.5 }}>
                        Navigation
                    </Typography>
                    <List disablePadding sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
                        {navItems.map((item) => {
                            const isActive = location.pathname === item.path;
                            return (
                                <ListItem key={item.path} disablePadding>
                                    <ListItemButton component={Link} to={item.path} sx={{
                                        borderRadius: 2.5, px: 2, py: 1.3,
                                        background: isActive ? 'rgba(124,58,237,0.1)' : 'transparent',
                                        border: isActive ? '1px solid rgba(124,58,237,0.18)' : '1px solid transparent',
                                        '&:hover': { background: isActive ? 'rgba(124,58,237,0.12)' : 'rgba(0,0,0,0.04)' },
                                        transition: 'all 0.18s',
                                    }}>
                                        <ListItemIcon sx={{ minWidth: 34, color: isActive ? '#7c3aed' : '#aaaaaa' }}>
                                            {item.icon}
                                        </ListItemIcon>
                                        <ListItemText primary={item.label} primaryTypographyProps={{
                                            fontSize: '0.9rem', fontWeight: 700,
                                            color: isActive ? '#7c3aed' : '#444444',
                                        }} />
                                        {isActive && (
                                            <motion.div layoutId="active-dot">
                                                <Box sx={{ width: 6, height: 6, borderRadius: '50%', background: '#7c3aed' }} />
                                            </motion.div>
                                        )}
                                    </ListItemButton>
                                </ListItem>
                            );
                        })}
                    </List>
                </Box>

                {/* User Card + Logout */}
                <Box sx={{ p: 2, pb: 3 }}>
                    <Box sx={{
                        p: 2, background: 'rgba(124,58,237,0.06)',
                        border: '1px solid rgba(124,58,237,0.12)',
                        borderRadius: 3, mb: 1.5, display: 'flex', alignItems: 'center', gap: 1.5,
                    }}>
                        <Avatar sx={{ width: 38, height: 38, background: 'linear-gradient(135deg, #7c3aed, #f97316)', fontSize: '0.95rem', fontWeight: 900 }}>
                            {user.username.charAt(0).toUpperCase()}
                        </Avatar>
                        <Box sx={{ overflow: 'hidden', flex: 1 }}>
                            <Typography sx={{ fontSize: '0.85rem', fontWeight: 800, color: '#111111', lineHeight: 1.2 }} noWrap>
                                {user.username}
                            </Typography>
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                <FiberManualRecordIcon sx={{ fontSize: 8, color: '#059669' }} />
                                <Typography sx={{ fontSize: '0.65rem', color: '#059669', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em' }}>Active</Typography>
                            </Box>
                        </Box>
                    </Box>
                    <ListItemButton onClick={handleLogout} sx={{
                        borderRadius: 2.5, px: 2, py: 1.2, gap: 1.5,
                        color: '#cccccc',
                        '&:hover': { background: 'rgba(220,38,38,0.06)', color: '#dc2626' },
                        transition: 'all 0.18s',
                    }}>
                        <LogoutIcon fontSize="small" />
                        <Typography sx={{ fontWeight: 700, fontSize: '0.9rem' }}>Sign Out</Typography>
                    </ListItemButton>
                </Box>
            </Drawer>

            {/* Main area */}
            <Box component="main" sx={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
                <AppBar position="sticky" elevation={0}>
                    <Toolbar sx={{ px: { xs: 3, md: 5 }, py: 1, minHeight: '68px !important' }}>
                        <Box sx={{ flex: 1 }}>
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                                <Box sx={{ width: 4, height: 24, background: 'linear-gradient(180deg, #7c3aed, #f97316)', borderRadius: 4 }} />
                                <Typography variant="h6" sx={{ fontWeight: 900, fontFamily: 'Outfit, sans-serif', color: '#111111' }}>
                                    {navItems.find(i => i.path === location.pathname)?.label || 'Dashboard'}
                                </Typography>
                            </Box>
                            <Typography sx={{ fontSize: '0.73rem', color: '#aaaaaa', fontWeight: 600, ml: '20px' }}>
                                TrustShield AI — Intelligent Threat Monitor
                            </Typography>
                        </Box>
                        <Chip
                            icon={<FiberManualRecordIcon sx={{ fontSize: '10px !important', color: '#059669 !important' }} />}
                            label="System Online"
                            size="small"
                            sx={{ background: 'rgba(5,150,105,0.08)', border: '1px solid rgba(5,150,105,0.2)', color: '#059669', fontWeight: 700, fontSize: '0.7rem' }}
                        />
                    </Toolbar>
                </AppBar>
                <Box sx={{ flex: 1, p: { xs: 3, md: 5 }, pt: { xs: 3, md: 4 } }}>
                    <Outlet />
                </Box>
            </Box>
        </Box>
    );
}
