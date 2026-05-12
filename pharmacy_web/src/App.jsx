import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import DashboardLayout from './layouts/DashboardLayout';
import Dashboard from './pages/Dashboard';
import Stock from './pages/Stock';
import Orders from './pages/Orders';
import Sales from './pages/Sales';
import Staff from './pages/Staff';
import Activity from './pages/Activity';
import Finances from './pages/Finances';
import Clients from './pages/Clients';
import Support from './pages/Support';
import Settings from './pages/Settings';
import Login from './pages/Login';
import { Navigate, Outlet } from 'react-router-dom';

const ProtectedRoute = () => {
  const token = localStorage.getItem('token');
  if (!token) return <Navigate to="/login" replace />;
  return <Outlet />;
};

// Fallback component for routes under construction
const UnderConstruction = ({ title }) => (
  <div className="card fade-in" style={{ textAlign: 'center', padding: '4rem' }}>
    <h2>{title}</h2>
    <p style={{ color: 'var(--text-muted)', marginTop: '1rem' }}>
      Cette section est en cours de développement.
    </p>
  </div>
);

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        
        <Route element={<ProtectedRoute />}>
          <Route path="/" element={<DashboardLayout />}>
            <Route index element={<Dashboard />} />
            <Route path="stock" element={<Stock />} />
            <Route path="sales" element={<Sales />} />
            <Route path="orders" element={<Orders />} />
            <Route path="staff" element={<Staff />} />
            <Route path="activity" element={<Activity />} />
            <Route path="clients" element={<Clients />} />
            <Route path="finances" element={<Finances />} />
            <Route path="support" element={<Support />} />
            <Route path="settings" element={<Settings />} />
          </Route>
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
