import React, { useState } from 'react';
import { Outlet, Link, useLocation } from 'react-router-dom';
import { 
  LayoutDashboard, 
  Package, 
  ShoppingCart, 
  ClipboardList, 
  Users, 
  UserRound,
  Activity, 
  BarChart3, 
  LifeBuoy, 
  Settings,
  Menu,
  X,
  Bell,
  Search,
  ChevronRight,
  LogOut
} from 'lucide-react';
import './DashboardLayout.css';

const SidebarItem = ({ icon: Icon, label, path, active, onClick }) => (
  <Link 
    to={path} 
    className={`sidebar-item ${active ? 'active' : ''}`}
    onClick={onClick}
  >
    <Icon size={20} />
    <span>{label}</span>
    {active && <div className="active-indicator" />}
  </Link>
);

const DashboardLayout = () => {
  const [isSidebarOpen, setSidebarOpen] = useState(true);
  const location = useLocation();
  const user = JSON.parse(localStorage.getItem('user') || '{}');

  const menuItems = [
    { icon: LayoutDashboard, label: 'Dashboard', path: '/' },
    { icon: Package, label: 'Stock', path: '/stock' },
    { icon: ShoppingCart, label: 'Ventes', path: '/sales' },
    { icon: ClipboardList, label: 'Commandes', path: '/orders' },
    { icon: Users, label: 'Clients', path: '/clients' },
    ...(user.role === 'administrateur' ? [{ icon: UserRound, label: 'Personnel', path: '/staff' }] : []),
    { icon: Activity, label: 'Activité', path: '/activity' },
    { icon: BarChart3, label: 'Finances', path: '/finances' },
    { icon: LifeBuoy, label: 'Support', path: '/support' },
  ];

  const bottomMenuItems = [
    { icon: Settings, label: 'Paramètres', path: '/settings' },
  ];

  return (
    <div className="dashboard-container">
      {/* Sidebar */}
      <aside className={`sidebar ${isSidebarOpen ? 'open' : 'closed'}`}>
        <div className="sidebar-header">
          <div className="logo-container">
            <span className="logo-text">BigPharma</span>
          </div>
          <button className="sidebar-toggle-mobile" onClick={() => setSidebarOpen(false)}>
            <X size={20} />
          </button>
        </div>

        <nav className="sidebar-nav">
          <div className="nav-group">
            <span className="group-label">Menu Principal</span>
            {menuItems.map((item) => (
              <SidebarItem 
                key={item.path}
                {...item}
                active={location.pathname === item.path}
              />
            ))}
          </div>

          <div className="nav-group bottom">
            <span className="group-label">Système</span>
            {bottomMenuItems.map((item) => (
              <SidebarItem 
                key={item.path}
                {...item}
                active={location.pathname === item.path}
              />
            ))}
            <button className="sidebar-item logout-btn">
              <LogOut size={20} />
              <span>Déconnexion</span>
            </button>
          </div>
        </nav>
      </aside>

      {/* Main Content */}
      <main className="main-content">
        {/* Navbar */}
        <header className="navbar glass">
          <div className="navbar-left">
            <button className="sidebar-toggle" onClick={() => setSidebarOpen(!isSidebarOpen)}>
              <Menu size={20} />
            </button>
            <div className="search-bar">
              <Search size={18} className="search-icon" />
              <input type="text" placeholder="Rechercher un produit, une commande..." />
            </div>
          </div>

          <div className="navbar-right">
            <button className="nav-action-btn">
              <Bell size={20} />
              <span className="badge">3</span>
            </button>
            <div className="divider" />
            <div className="user-profile">
              <div className="user-info">
                <span className="user-name">{user.fullName || 'Utilisateur'}</span>
                <span className="user-role" style={{ textTransform: 'capitalize' }}>{user.role}</span>
              </div>
              <div className="user-avatar">{user.fullName ? user.fullName.substring(0, 2).toUpperCase() : '??'}</div>
            </div>
          </div>
        </header>

        {/* Page Content */}
        <div className="content-wrapper">
          <Outlet />
        </div>
      </main>
    </div>
  );
};

export default DashboardLayout;
