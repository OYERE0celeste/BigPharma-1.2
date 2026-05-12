import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Search, UserPlus, Phone, Mail, MapPin, ExternalLink } from 'lucide-react';
import './Clients.css';

const Clients = () => {
  const [clients, setClients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    fetchClients();
  }, [search]);

  const fetchClients = async () => {
    try {
      const response = await axios.get(`http://localhost:5000/api/clients?search=${search}`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setClients(response.data.data);
      setLoading(false);
    } catch (error) {
      console.error("Erreur clients", error);
      setLoading(false);
    }
  };

  return (
    <div className="clients-container">
      <header className="clients-header">
        <div>
          <h1>Base de Données Patients</h1>
          <p>Gérez les dossiers clients et l'historique médical</p>
        </div>
        <div className="clients-actions">
          <div className="search-pill">
            <Search size={18} />
            <input 
              type="text" 
              placeholder="Rechercher un patient..." 
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          <button className="add-client-btn">
            <UserPlus size={18} /> Nouveau Patient
          </button>
        </div>
      </header>

      <div className="clients-grid">
        {loading ? (
          <div className="loader">Chargement des patients...</div>
        ) : (
          clients.map(client => (
            <div key={client._id} className="client-card">
              <div className="client-card-header">
                <div className="client-avatar">
                  {client.fullName.charAt(0)}
                </div>
                <div className="client-main-info">
                  <h3>{client.fullName}</h3>
                  <span className="client-id">ID: {client._id.substring(18)}</span>
                </div>
                <button className="view-profile-btn" title="Voir le dossier complet">
                  <ExternalLink size={16} />
                </button>
              </div>

              <div className="client-details">
                <div className="detail-item">
                  <Phone size={14} />
                  <span>{client.phone || 'Non renseigné'}</span>
                </div>
                <div className="detail-item">
                  <Mail size={14} />
                  <span>{client.email}</span>
                </div>
                <div className="detail-item">
                  <MapPin size={14} />
                  <span>{client.address || 'Cotonou, Bénin'}</span>
                </div>
              </div>

              <div className="client-stats">
                <div className="stat-item">
                  <span className="stat-value">12</span>
                  <span className="stat-label">Commandes</span>
                </div>
                <div className="stat-item">
                  <span className="stat-value">0</span>
                  <span className="stat-label">Points</span>
                </div>
              </div>
            </div>
          ))
        )}
        {clients.length === 0 && !loading && (
          <div className="no-results">Aucun patient trouvé pour "{search}"</div>
        )}
      </div>
    </div>
  );
};

export default Clients;
