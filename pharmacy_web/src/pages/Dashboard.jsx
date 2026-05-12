import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { 
  TrendingUp, 
  AlertCircle, 
  Clock, 
  MessageSquare, 
  ShoppingBag, 
  Package, 
  Users, 
  ArrowRight 
} from 'lucide-react';
import { Link } from 'react-router-dom';
import './Dashboard.css';

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardStats();
  }, []);

  const fetchDashboardStats = async () => {
    try {
      const response = await axios.get('http://localhost:5000/api/dashboard/summary', {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setStats(response.data.data);
      setLoading(false);
    } catch (error) {
      console.error("Erreur stats dashboard", error);
      setLoading(false);
    }
  };

  if (loading) return <div className="loader">Chargement du tableau de bord...</div>;

  return (
    <div className="dashboard-page">
      <header className="dashboard-header">
        <h1>Bienvenue, Dr. Admin</h1>
        <p>Voici l'état actuel de votre pharmacie aujourd'hui.</p>
      </header>

      <div className="summary-widgets">
        <div className="summary-card primary">
          <div className="card-icon"><TrendingUp /></div>
          <div className="card-info">
            <span className="label">Ventes du Jour</span>
            <h3>{stats.todaySalesRevenue.toLocaleString()} FCFA</h3>
            <span className="sub">Tendance: +5.2%</span>
          </div>
        </div>
        <div className="summary-card danger">
          <div className="card-icon"><AlertCircle /></div>
          <div className="card-info">
            <span className="label">Alertes Stock</span>
            <h3>{stats.productsLowStock + stats.productsExpired}</h3>
            <span className="sub">{stats.productsExpired} produits périmés</span>
          </div>
        </div>
        <div className="summary-card warning">
          <div className="card-icon"><MessageSquare /></div>
          <div className="card-info">
            <span className="label">Questions Patients</span>
            <h3>{stats.pendingQuestions}</h3>
            <span className="sub">En attente de réponse</span>
          </div>
        </div>
        <div className="summary-card info">
          <div className="card-icon"><Users /></div>
          <div className="card-info">
            <span className="label">Nouveaux Clients</span>
            <h3>{stats.newClientsToday}</h3>
            <span className="sub">Inscrits aujourd'hui</span>
          </div>
        </div>
      </div>

      <div className="dashboard-grid">
        <section className="dashboard-section main-stats">
          <div className="section-header">
            <h3>Activité Récente</h3>
            <Link to="/activity" className="view-all">Voir tout <ArrowRight size={14} /></Link>
          </div>
          <div className="activity-mini-list">
            {/* Simulation of recent activity if not provided by API */}
            <div className="activity-item">
              <div className="act-icon sale"><ShoppingBag size={14} /></div>
              <div className="act-content">
                <p><strong>Vente effectuée</strong> - Par Pharmacien A</p>
                <span>Il y a 5 minutes</span>
              </div>
            </div>
            <div className="activity-item">
              <div className="act-icon product"><Package size={14} /></div>
              <div className="act-content">
                <p><strong>Stock mis à jour</strong> - Par Gestionnaire B</p>
                <span>Il y a 12 minutes</span>
              </div>
            </div>
          </div>
        </section>

        <section className="dashboard-section alerts-list">
          <div className="section-header">
            <h3>Actions Requises</h3>
          </div>
          <div className="task-list">
            {stats.productsLowStock > 0 && (
              <div className="task-item warning">
                <AlertCircle size={18} />
                <p>Approvisionner {stats.productsLowStock} produits en stock bas</p>
              </div>
            )}
            {stats.pendingQuestions > 0 && (
              <div className="task-item info">
                <MessageSquare size={18} />
                <p>Répondre aux {stats.pendingQuestions} questions patients</p>
              </div>
            )}
            {stats.productsExpired > 0 && (
              <div className="task-item danger">
                <AlertCircle size={18} />
                <p>Retirer {stats.productsExpired} produits périmés des rayons</p>
              </div>
            )}
          </div>
        </section>
      </div>
    </div>
  );
};

export default Dashboard;
