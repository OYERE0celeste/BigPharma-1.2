import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Building2, Settings as SettingsIcon, ShieldCheck, Clock } from 'lucide-react';
import './Settings.css';

const Settings = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('pharmacy');
  const [message, setMessage] = useState('');

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    try {
      const response = await axios.get('http://localhost:5000/api/settings', {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setData(response.data.data);
      setLoading(false);
    } catch (error) {
      console.error("Erreur settings", error);
      setLoading(false);
    }
  };

  const handleUpdatePharmacy = async (e) => {
    e.preventDefault();
    try {
      await axios.patch('http://localhost:5000/api/settings/pharmacy', data.pharmacy, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setMessage('Informations officine mises à jour !');
      setTimeout(() => setMessage(''), 3000);
    } catch (error) {
      alert("Erreur de mise à jour");
    }
  };

  const handleUpdateSystem = async (e) => {
    e.preventDefault();
    try {
      await axios.patch('http://localhost:5000/api/settings/system', data.system, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setMessage('Paramètres système mis à jour !');
      setTimeout(() => setMessage(''), 3000);
    } catch (error) {
      alert("Erreur de mise à jour");
    }
  };

  if (loading) return <div className="loader">Chargement des paramètres...</div>;

  return (
    <div className="settings-container">
      <header className="settings-header">
        <h1>Paramètres Système</h1>
        <p>Configurez les détails de votre officine et les règles métier</p>
      </header>

      {message && <div className="success-toast">{message}</div>}

      <div className="settings-layout">
        <aside className="settings-tabs">
          <button className={activeTab === 'pharmacy' ? 'active' : ''} onClick={() => setActiveTab('pharmacy')}>
            <Building2 size={20} /> Infos Officine
          </button>
          <button className={activeTab === 'system' ? 'active' : ''} onClick={() => setActiveTab('system')}>
            <SettingsIcon size={20} /> Configuration
          </button>
          <button className={activeTab === 'security' ? 'active' : ''} onClick={() => setActiveTab('security')}>
            <ShieldCheck size={20} /> Sécurité
          </button>
        </aside>

        <main className="settings-content">
          {activeTab === 'pharmacy' && (
            <form onSubmit={handleUpdatePharmacy} className="settings-form">
              <h2>Informations de la Pharmacie</h2>
              <div className="form-group">
                <label>Nom de l'officine</label>
                <input 
                  type="text" 
                  value={data.pharmacy.name} 
                  onChange={(e) => setData({...data, pharmacy: {...data.pharmacy, name: e.target.value}})}
                />
              </div>
              <div className="form-row">
                <div className="form-group">
                  <label>Email de contact</label>
                  <input 
                    type="email" 
                    value={data.pharmacy.email} 
                    onChange={(e) => setData({...data, pharmacy: {...data.pharmacy, email: e.target.value}})}
                  />
                </div>
                <div className="form-group">
                  <label>Téléphone</label>
                  <input 
                    type="text" 
                    value={data.pharmacy.phone} 
                    onChange={(e) => setData({...data, pharmacy: {...data.pharmacy, phone: e.target.value}})}
                  />
                </div>
              </div>
              <div className="form-group">
                <label>Adresse complète</label>
                <textarea 
                  value={data.pharmacy.address} 
                  onChange={(e) => setData({...data, pharmacy: {...data.pharmacy, address: e.target.value}})}
                />
              </div>
              <button type="submit" className="save-btn">Enregistrer les modifications</button>
            </form>
          )}

          {activeTab === 'system' && (
            <form onSubmit={handleUpdateSystem} className="settings-form">
              <h2>Paramètres Globaux</h2>
              <div className="form-row">
                <div className="form-group">
                  <label>Devise</label>
                  <input 
                    type="text" 
                    value={data.system.currency} 
                    onChange={(e) => setData({...data, system: {...data.system, currency: e.target.value}})}
                  />
                </div>
                <div className="form-group">
                  <label>Taux de TVA (%)</label>
                  <input 
                    type="number" 
                    value={data.system.taxRate} 
                    onChange={(e) => setData({...data, system: {...data.system, taxRate: e.target.value}})}
                  />
                </div>
              </div>
              <div className="form-group">
                <label>Marge par défaut (%)</label>
                <input 
                  type="number" 
                  value={data.system.defaultMargin} 
                  onChange={(e) => setData({...data, system: {...data.system, defaultMargin: e.target.value}})}
                />
              </div>
              <div className="form-group">
                <label>Pied de page des factures</label>
                <input 
                  type="text" 
                  value={data.system.invoiceFooter} 
                  onChange={(e) => setData({...data, system: {...data.system, invoiceFooter: e.target.value}})}
                />
              </div>
              <button type="submit" className="save-btn">Appliquer les paramètres</button>
            </form>
          )}

          {activeTab === 'security' && (
            <div className="settings-form">
              <h2>Paramètres de Sécurité</h2>
              <div className="security-item">
                <div className="security-info">
                  <h4>Authentification à deux facteurs</h4>
                  <p>Ajoutez une couche de sécurité supplémentaire à votre compte admin.</p>
                </div>
                <button className="setup-btn">Configurer</button>
              </div>
              <div className="security-item">
                <div className="security-info">
                  <h4>Audit automatique</h4>
                  <p>Toutes les actions sont enregistrées dans le registre d'activité.</p>
                </div>
                <span className="status-badge active">Activé</span>
              </div>
            </div>
          )}
        </main>
      </div>
    </div>
  );
};

export default Settings;
