import { Routes, Route, Navigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import axios from './api/axios';
import Landing from './pages/Landing';
import Login from './pages/Login';
import Register from './pages/Register';
import DashboardLayout from './components/DashboardLayout';
import DashboardHome from './pages/DashboardHome';
import ScanPage from './pages/ScanPage';
import HistoryPage from './pages/HistoryPage';

function App() {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        checkSession();
    }, []);

    const checkSession = async () => {
        try {
            const res = await axios.get('/auth/check-session');
            if (res.data.loggedIn) {
                setUser(res.data.user);
            }
        } catch (err) {
            console.error("Session check failed");
        } finally {
            setLoading(false);
        }
    };

    if (loading) return (
        <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'linear-gradient(135deg, #090d1f 0%, #0d1535 100%)' }}>
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16 }}>
                <div style={{ width: 48, height: 48, border: '3px solid rgba(124,58,237,0.2)', borderTop: '3px solid #7c3aed', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
                <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
                <p style={{ color: '#334155', fontSize: '0.7rem', fontWeight: 800, letterSpacing: '0.2em', textTransform: 'uppercase', fontFamily: 'Inter, sans-serif' }}>Authenticating...</p>
            </div>
        </div>
    );

    return (
        <Routes>
            <Route path="/" element={<Landing user={user} />} />
            <Route path="/login" element={user ? <Navigate to="/dashboard" /> : <Login setUser={setUser} />} />
            <Route path="/register" element={user ? <Navigate to="/dashboard" /> : <Register />} />

            {/* Protected Routes */}
            <Route path="/dashboard" element={user ? <DashboardLayout user={user} setUser={setUser} /> : <Navigate to="/login" />}>
                <Route index element={<DashboardHome />} />
                <Route path="scan" element={<ScanPage />} />
                <Route path="history" element={<HistoryPage />} />
            </Route>
        </Routes>
    );
}

export default App;
