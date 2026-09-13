import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'
import { BrowserRouter } from 'react-router-dom'
import { ThemeProvider, createTheme, CssBaseline } from '@mui/material'

const theme = createTheme({
    palette: {
        mode: 'light',
        primary: {
            main: '#7c3aed',
            light: '#a78bfa',
            dark: '#5b21b6',
            contrastText: '#ffffff',
        },
        secondary: {
            main: '#f97316',
            light: '#fdba74',
            dark: '#c2410c',
            contrastText: '#ffffff',
        },
        error: { main: '#dc2626' },
        warning: { main: '#d97706' },
        success: { main: '#059669' },
        background: {
            default: '#f9f9f9',
            paper: '#ffffff',
        },
        text: {
            primary: '#111111',
            secondary: '#555555',
            disabled: '#aaaaaa',
        },
        divider: 'rgba(0,0,0,0.08)',
    },
    typography: {
        fontFamily: '"Inter", "Outfit", system-ui, sans-serif',
        h1: { fontWeight: 900, letterSpacing: '-0.03em', color: '#111111' },
        h2: { fontWeight: 800, letterSpacing: '-0.02em', color: '#111111' },
        h3: { fontWeight: 800, color: '#111111' },
        h4: { fontWeight: 700, color: '#111111' },
        h5: { fontWeight: 700, color: '#111111' },
        h6: { fontWeight: 600, color: '#111111' },
        button: { fontWeight: 700, textTransform: 'none' },
    },
    shape: { borderRadius: 16 },
    components: {
        MuiCard: {
            styleOverrides: {
                root: {
                    background: 'rgba(255,255,255,0.75)',
                    backdropFilter: 'blur(16px)',
                    border: '1px solid rgba(0,0,0,0.08)',
                    boxShadow: '0 4px 32px rgba(0,0,0,0.07)',
                },
            },
        },
        MuiPaper: {
            styleOverrides: {
                root: {
                    backgroundImage: 'none',
                    background: 'rgba(255,255,255,0.75)',
                    backdropFilter: 'blur(16px)',
                    border: '1px solid rgba(0,0,0,0.08)',
                    boxShadow: '0 4px 32px rgba(0,0,0,0.07)',
                },
            },
        },
        MuiButton: {
            styleOverrides: {
                root: {
                    borderRadius: 12,
                    padding: '10px 24px',
                    fontSize: '1rem',
                    fontWeight: 700,
                    boxShadow: 'none',
                    '&:hover': { boxShadow: '0 4px 20px rgba(124,58,237,0.3)' },
                },
                containedPrimary: {
                    background: 'linear-gradient(135deg, #7c3aed 0%, #5b21b6 100%)',
                    '&:hover': { background: 'linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%)' },
                },
                containedSecondary: {
                    background: 'linear-gradient(135deg, #f97316 0%, #c2410c 100%)',
                    '&:hover': { background: 'linear-gradient(135deg, #fb923c 0%, #f97316 100%)' },
                },
                outlinedPrimary: {
                    borderColor: 'rgba(124,58,237,0.35)',
                    color: '#7c3aed',
                    '&:hover': { background: 'rgba(124,58,237,0.06)', borderColor: '#7c3aed' },
                },
            },
        },
        MuiAppBar: {
            styleOverrides: {
                root: {
                    background: 'rgba(255,255,255,0.85)',
                    backdropFilter: 'blur(20px)',
                    color: '#111111',
                    borderBottom: '1px solid rgba(0,0,0,0.07)',
                    boxShadow: '0 1px 12px rgba(0,0,0,0.06)',
                },
            },
        },
        MuiDrawer: {
            styleOverrides: {
                paper: {
                    background: 'rgba(255,255,255,0.92)',
                    backdropFilter: 'blur(20px)',
                    borderRight: '1px solid rgba(0,0,0,0.07)',
                    boxShadow: '2px 0 20px rgba(0,0,0,0.05)',
                },
            },
        },
        MuiTextField: {
            styleOverrides: {
                root: {
                    '& .MuiOutlinedInput-root': {
                        borderRadius: 12,
                        background: 'rgba(255,255,255,0.8)',
                        '& fieldset': { borderColor: 'rgba(0,0,0,0.12)' },
                        '&:hover fieldset': { borderColor: 'rgba(124,58,237,0.4)' },
                        '&.Mui-focused fieldset': { borderColor: '#7c3aed' },
                    },
                    '& .MuiInputLabel-root': { color: '#888888' },
                    '& .MuiInputLabel-root.Mui-focused': { color: '#7c3aed' },
                },
            },
        },
        MuiChip: {
            styleOverrides: {
                root: { borderRadius: 8, fontWeight: 700 },
            },
        },
        MuiTab: {
            styleOverrides: {
                root: { fontWeight: 700, fontSize: '0.9rem', color: '#666666' },
            },
        },
        MuiTableCell: {
            styleOverrides: {
                root: { borderColor: 'rgba(0,0,0,0.06)', color: '#333333' },
                head: {
                    fontWeight: 800,
                    fontSize: '0.7rem',
                    letterSpacing: '0.12em',
                    textTransform: 'uppercase',
                    color: '#999999',
                    background: '#fafafa',
                },
            },
        },
        MuiLinearProgress: {
            styleOverrides: {
                root: { borderRadius: 4, height: 8, backgroundColor: 'rgba(0,0,0,0.07)' },
            },
        },
        MuiDivider: {
            styleOverrides: {
                root: { borderColor: 'rgba(0,0,0,0.07)' },
            },
        },
    },
});

ReactDOM.createRoot(document.getElementById('root')).render(
    <React.StrictMode>
        <BrowserRouter>
            <ThemeProvider theme={theme}>
                <CssBaseline />
                <App />
            </ThemeProvider>
        </BrowserRouter>
    </React.StrictMode>,
)
