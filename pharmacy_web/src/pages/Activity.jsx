import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Activity.css';

const Activity = () => {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState({
    entityType: '',
    actionType: ''
  });

  useEffect(() => {
    fetchLogs();
  }, [filters]);

  const fetchLogs = async () => {
    try {
      const queryParams = new URLSearchParams(filters).toString();
      const response = await axios.get(`http://localhost:5000/api/activities?${queryParams}`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setLogs(response.data.data);
      setLoading(false);
    } catch (error) {
      console.error("Erreur lors de la récupération des logs", error);
      setLoading(false);
    }
  };

  const getActionClass = (type) => {
    switch (type) {
      case 'create': return 'action-create';
      case 'update': return 'action-update';
      case 'delete': return 'action-delete';
      default: return '';
    }
  };

  const formatMetadata = (log) => {
    return (
      <div className="log-meta">
        {log.ipAddress && <span title="IP Address">🌐 {log.ipAddress}</span>}
        {log.userAgent && <span title={log.userAgent}>💻 {log.userAgent.substring(0, 20)}...</span>}
      </div>
    );
  };

  return (
    <div className="activity-container">
      <header className="activity-header">
        <div>
          <h1>Registre d'Activité</h1>
          <p>Audit complet des actions effectuées sur la plateforme</p>
        </div>
        <div className="filter-bar">
          <select 
            value={filters.entityType} 
            onChange={(e) => setFilters({...filters, entityType: e.target.value})}
          >
            <option value="">Toutes les entités</option>
            <option value="product">Produits</option>
            <option value="order">Commandes</option>
            <option value="client">Clients</option>
            <option value="user">Utilisateurs</option>
          </select>
          <select 
            value={filters.actionType} 
            onChange={(e) => setFilters({...filters, actionType: e.target.value})}
          >
            <option value="">Toutes les actions</option>
            <option value="create">Création</option>
            <option value="update">Modification</option>
            <option value="delete">Suppression</option>
          </select>
        </div>
      </header>

      <div className="activity-list">
        {loading ? (
          <div className="loader">Chargement des logs...</div>
        ) : (
          <table>
            <thead>
              <tr>
                <th>Date & Heure</th>
                <th>Utilisateur</th>
                <th>Action</th>
                <th>Entité</th>
                <th>Description</th>
                <th>Métadonnées</th>
              </tr>
            </thead>
            <tbody>
              {logs.map(log => (
                <tr key={log._id}>
                  <td className="log-time">
                    {new Date(log.createdAt).toLocaleString('fr-FR')}
                  </td>
                  <td className="log-user">
                    <span className="user-badge">{log.user}</span>
                  </td>
                  <td>
                    <span className={`action-badge ${getActionClass(log.actionType)}`}>
                      {log.actionType}
                    </span>
                  </td>
                  <td><span className="entity-badge">{log.entityType}</span></td>
                  <td className="log-desc">{log.description}</td>
                  <td>{formatMetadata(log)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
};

export default Activity;
