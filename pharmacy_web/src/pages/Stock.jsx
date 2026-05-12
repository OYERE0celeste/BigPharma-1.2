import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { AlertTriangle, Package, History, TrendingDown } from 'lucide-react';
import './Stock.css';

const Stock = () => {
  const [alerts, setAlerts] = useState(null);
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStockData();
  }, []);

  const fetchStockData = async () => {
    try {
      const [alertsRes, productsRes] = await Promise.all([
        axios.get('http://localhost:5000/api/products/alerts/status', {
          headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
        }),
        axios.get('http://localhost:5000/api/products', {
          headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
        })
      ]);
      setAlerts(alertsRes.data.data);
      setProducts(productsRes.data.data);
      setLoading(false);
    } catch (error) {
      console.error("Erreur stock", error);
      setLoading(false);
    }
  };

  if (loading) return <div className="loader">Chargement de l'inventaire...</div>;

  return (
    <div className="stock-container">
      <header className="stock-header">
        <div>
          <h1>Gestion du Stock & Alertes</h1>
          <p>Surveillez vos niveaux d'inventaire et les dates de péremption</p>
        </div>
      </header>

      <div className="alerts-row">
        <div className="alert-card critical">
          <div className="alert-icon"><AlertTriangle /></div>
          <div className="alert-content">
            <h3>Péremption Proche</h3>
            <p><strong>{alerts.expiringCount}</strong> produits expirent dans les 3 mois</p>
          </div>
        </div>
        <div className="alert-card warning">
          <div className="alert-icon"><TrendingDown /></div>
          <div className="alert-content">
            <h3>Rupture Proche</h3>
            <p><strong>{alerts.lowStock.length}</strong> produits sous le seuil critique</p>
          </div>
        </div>
      </div>

      <div className="stock-grid-layout">
        <div className="inventory-section">
          <h3>Inventaire Global</h3>
          <div className="inventory-table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>Produit</th>
                  <th>Catégorie</th>
                  <th>Stock Total</th>
                  <th>Prix Vente</th>
                  <th>Statut</th>
                </tr>
              </thead>
              <tbody>
                {products.map(p => (
                  <tr key={p._id}>
                    <td className="prod-name">{p.name}</td>
                    <td>{p.category}</td>
                    <td className={p.stockQuantity < 10 ? 'stock-low' : ''}>
                      {p.stockQuantity} {p.unit}
                    </td>
                    <td>{p.sellingPrice} FCFA</td>
                    <td>
                      <span className={`status-pill ${p.stockQuantity > 0 ? 'in-stock' : 'out-of-stock'}`}>
                        {p.stockQuantity > 0 ? 'En Stock' : 'Rupture'}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        <div className="expiring-section">
          <h3>Lots Expérant Bientôt</h3>
          <div className="expiring-list">
            {alerts.expiringProducts.map(p => (
              <div key={p._id} className="expiring-item">
                <div className="exp-prod-info">
                  <strong>{p.name}</strong>
                  {p.lots.map((l, i) => (
                    <div key={i} className="lot-info">
                      <span>Lot: {l.lotNumber}</span>
                      <span className="exp-date">Expire le: {new Date(l.expirationDate).toLocaleDateString()}</span>
                    </div>
                  ))}
                </div>
                <div className="exp-action">⚠️</div>
              </div>
            ))}
            {alerts.expiringCount === 0 && <p className="empty-msg">Aucune péremption proche détectée.</p>}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Stock;
