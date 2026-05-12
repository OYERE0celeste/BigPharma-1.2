import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Orders.css';

const Orders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchCode, setSearchCode] = useState('');
  const [selectedOrder, setSelectedOrder] = useState(null);

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const response = await axios.get('http://localhost:5000/api/orders');
      setOrders(response.data.data);
      setLoading(false);
    } catch (error) {
      console.error("Erreur lors de la récupération des commandes", error);
      setLoading(false);
    }
  };

  const handleSearchByCode = () => {
    const found = orders.find(o => o.collectionCode === searchCode || o.orderNumber === searchCode);
    if (found) {
      setSelectedOrder(found);
    } else {
      alert("Aucune commande trouvée avec ce code.");
    }
  };

  const updateStatus = async (id, status) => {
    try {
      await axios.patch(`http://localhost:5000/api/orders/${id}/status`, { status });
      fetchOrders();
      if (selectedOrder && selectedOrder._id === id) {
        setSelectedOrder({ ...selectedOrder, status });
      }
    } catch (error) {
      alert("Erreur lors de la mise à jour");
    }
  };

  return (
    <div className="orders-container">
      <header className="orders-header">
        <div>
          <h1>Gestion des Commandes</h1>
          <p>Validez les retraits clients via code de récupération</p>
        </div>
        <div className="search-box">
          <button className="scan-btn" onClick={() => alert("Scanner prêt... (Simulation)")}>
            📷 Scan QR
          </button>
          <input 
            type="text" 
            placeholder="Code de retrait ou scan..." 
            value={searchCode}
            onChange={(e) => setSearchCode(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSearchByCode()}
          />
          <button onClick={handleSearchByCode}>Vérifier</button>
        </div>
      </header>

      {selectedOrder && (
        <div className="selected-order-card">
          <div className="card-header">
            <h3>Commande {selectedOrder.orderNumber}</h3>
            <span className={`status-badge ${selectedOrder.status}`}>
              {selectedOrder.status}
            </span>
          </div>
          <div className="card-body">
            <div className="client-info">
              <p><strong>Client:</strong> {selectedOrder.clientId?.fullName}</p>
              <p><strong>Code de retrait:</strong> <span className="code-highlight">{selectedOrder.collectionCode}</span></p>
            </div>
            <div className="order-items">
              <h4>Articles:</h4>
              <ul>
                {selectedOrder.products.map((p, i) => (
                  <li key={i}>{p.quantity}x {p.name}</li>
                ))}
              </ul>
            </div>
            <div className="actions">
              {selectedOrder.status === 'en_attente' && (
                <button className="btn-prep" onClick={() => updateStatus(selectedOrder._id, 'en_preparation')}>
                  Commencer la préparation
                </button>
              )}
              {selectedOrder.status === 'en_preparation' && (
                <button className="btn-ready" onClick={() => updateStatus(selectedOrder._id, 'pret_pour_recuperation')}>
                  Prêt pour retrait
                </button>
              )}
              {selectedOrder.status === 'pret_pour_recuperation' && (
                <button className="btn-validate" onClick={() => updateStatus(selectedOrder._id, 'validee')}>
                  Confirmer le retrait (Délivré)
                </button>
              )}
            </div>
          </div>
          <button className="close-btn" onClick={() => setSelectedOrder(null)}>×</button>
        </div>
      )}

      <div className="orders-list">
        <table>
          <thead>
            <tr>
              <th>N° Commande</th>
              <th>Date</th>
              <th>Client</th>
              <th>Code Retrait</th>
              <th>Total</th>
              <th>Statut</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {orders.map(order => (
              <tr key={order._id}>
                <td>{order.orderNumber}</td>
                <td>{new Date(order.createdAt).toLocaleDateString()}</td>
                <td>{order.clientId?.fullName}</td>
                <td><code className="table-code">{order.collectionCode}</code></td>
                <td>{order.totalPrice} FCFA</td>
                <td>
                  <span className={`status-dot ${order.status}`}></span>
                  {order.status}
                </td>
                <td>
                  <button className="view-btn" onClick={() => setSelectedOrder(order)}>Détails</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Orders;
