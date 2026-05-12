import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Staff.css';

const Staff = () => {
  const [staff, setStaff] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    password: '',
    role: 'pharmacien',
    phone: '',
    address: ''
  });

  const roles = [
    { value: 'pharmacien', label: 'Pharmacien' },
    { value: 'agent de vente', label: 'Agent de Vente' },
    { value: 'gestionnaire de stock', label: 'Gestionnaire de Stock' },
    { value: 'personnel autorisé', label: 'Personnel Autorisé' },
    { value: 'administrateur', label: 'Administrateur' }
  ];

  useEffect(() => {
    fetchStaff();
  }, []);

  const fetchStaff = async () => {
    try {
      const response = await axios.get('http://localhost:5000/api/users/staff', {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setStaff(response.data.data);
      setLoading(false);
    } catch (error) {
      console.error("Erreur lors de la récupération du personnel", error);
      setLoading(false);
    }
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await axios.post('http://localhost:5000/api/users/staff', formData, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setShowModal(false);
      setFormData({ fullName: '', email: '', password: '', role: 'pharmacien', phone: '', address: '' });
      fetchStaff();
    } catch (error) {
      alert(error.response?.data?.message || "Erreur lors de la création");
    }
  };

  const toggleStatus = async (user) => {
    try {
      await axios.patch(`http://localhost:5000/api/users/staff/${user._id}`, 
        { isActive: !user.isActive },
        { headers: { Authorization: `Bearer ${localStorage.getItem('token')}` } }
      );
      fetchStaff();
    } catch (error) {
      alert("Erreur lors de la mise à jour");
    }
  };

  return (
    <div className="staff-container">
      <header className="staff-header">
        <div>
          <h1>Gestion du Personnel</h1>
          <p>Gérez les accès et les rôles de votre équipe officinale</p>
        </div>
        <button className="add-staff-btn" onClick={() => setShowModal(true)}>
          + Nouvel Employé
        </button>
      </header>

      <div className="staff-grid">
        {staff.map(member => (
          <div key={member._id} className={`staff-card ${!member.isActive ? 'inactive' : ''}`}>
            <div className="staff-avatar">
              {member.fullName.charAt(0)}
            </div>
            <div className="staff-info">
              <h3>{member.fullName}</h3>
              <span className="staff-role">{member.role}</span>
              <p className="staff-email">{member.email}</p>
            </div>
            <div className="staff-actions">
              <button 
                className={`status-btn ${member.isActive ? 'active' : ''}`}
                onClick={() => toggleStatus(member)}
              >
                {member.isActive ? 'Activé' : 'Désactivé'}
              </button>
            </div>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="modal-overlay">
          <div className="modal-content">
            <h2>Ajouter un membre au personnel</h2>
            <form onSubmit={handleCreate}>
              <div className="form-row">
                <div className="form-group">
                  <label>Nom complet</label>
                  <input 
                    type="text" 
                    value={formData.fullName}
                    onChange={(e) => setFormData({...formData, fullName: e.target.value})}
                    required 
                  />
                </div>
                <div className="form-group">
                  <label>Rôle</label>
                  <select 
                    value={formData.role}
                    onChange={(e) => setFormData({...formData, role: e.target.value})}
                  >
                    {roles.map(r => <option key={r.value} value={r.value}>{r.label}</option>)}
                  </select>
                </div>
              </div>

              <div className="form-group">
                <label>Email professionnel</label>
                <input 
                  type="email" 
                  value={formData.email}
                  onChange={(e) => setFormData({...formData, email: e.target.value})}
                  required 
                />
              </div>

              <div className="form-group">
                <label>Mot de passe initial</label>
                <input 
                  type="password" 
                  value={formData.password}
                  onChange={(e) => setFormData({...formData, password: e.target.value})}
                  required 
                />
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>Téléphone</label>
                  <input 
                    type="text" 
                    value={formData.phone}
                    onChange={(e) => setFormData({...formData, phone: e.target.value})}
                  />
                </div>
                <div className="form-group">
                  <label>Adresse</label>
                  <input 
                    type="text" 
                    value={formData.address}
                    onChange={(e) => setFormData({...formData, address: e.target.value})}
                  />
                </div>
              </div>

              <div className="modal-actions">
                <button type="button" className="cancel-btn" onClick={() => setShowModal(false)}>Annuler</button>
                <button type="submit" className="submit-btn">Créer le compte</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Staff;
