import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, Legend } from 'recharts';
import './Finances.css';

const Finances = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchFinanceData();
  }, []);

  const fetchFinanceData = async () => {
    try {
      const response = await axios.get('http://localhost:5000/api/finance/summary', {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setData(response.data.data);
      setLoading(false);
    } catch (error) {
      console.error("Erreur finance", error);
      setLoading(false);
    }
  };

  if (loading) return <div className="loader">Chargement des données financières...</div>;

  return (
    <div className="finance-container">
      <header className="finance-header">
        <h1>Rapports Financiers</h1>
        <div className="date-picker-mock">Derniers 30 jours</div>
      </header>

      <div className="stats-grid">
        <div className="stat-card income">
          <span className="label">Revenus Totaux</span>
          <h2 className="value">{data.summary.totalIncome.toLocaleString()} FCFA</h2>
          <span className="trend positive">↑ 12% vs mois dernier</span>
        </div>
        <div className="stat-card expense">
          <span className="label">Dépenses Totales</span>
          <h2 className="value">{data.summary.totalExpense.toLocaleString()} FCFA</h2>
          <span className="trend negative">↑ 5% vs mois dernier</span>
        </div>
        <div className="stat-card profit">
          <span className="label">Bénéfice Net</span>
          <h2 className="value">{data.summary.netProfit.toLocaleString()} FCFA</h2>
          <span className="trend positive">↑ 18% vs mois dernier</span>
        </div>
      </div>

      <div className="charts-grid">
        <div className="chart-box">
          <h3>Flux de Trésorerie (Revenus vs Dépenses)</h3>
          <div className="chart-wrapper">
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={data.trends}>
                <defs>
                  <linearGradient id="colorIncome" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#10b981" stopOpacity={0.1}/>
                    <stop offset="95%" stopColor="#10b981" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="date" stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} />
                <YAxis stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} tickFormatter={(val) => `${val/1000}k`} />
                <Tooltip />
                <Area type="monotone" dataKey="income" stroke="#10b981" fillOpacity={1} fill="url(#colorIncome)" strokeWidth={3} />
                <Area type="monotone" dataKey="expense" stroke="#f43f5e" fillOpacity={0} strokeWidth={2} strokeDasharray="5 5" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="chart-box">
          <h3>Distribution des Transactions</h3>
          <div className="chart-wrapper">
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={data.trends}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="date" stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} />
                <YAxis stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} />
                <Tooltip />
                <Bar dataKey="income" fill="#10b981" radius={[4, 4, 0, 0]} barSize={20} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      <div className="recent-transactions">
        <h3>Transactions Récentes</h3>
        <table>
          <thead>
            <tr>
              <th>Date</th>
              <th>Référence</th>
              <th>Description</th>
              <th>Catégorie</th>
              <th>Montant</th>
              <th>Méthode</th>
            </tr>
          </thead>
          <tbody>
            {data.transactions.map(t => (
              <tr key={t._id}>
                <td>{new Date(t.dateTime).toLocaleDateString()}</td>
                <td><code className="ref-code">{t.reference}</code></td>
                <td>{t.description}</td>
                <td><span className={`type-badge ${t.type}`}>{t.type}</span></td>
                <td className={t.isIncome ? 'amount-plus' : 'amount-minus'}>
                  {t.isIncome ? '+' : '-'} {t.amount.toLocaleString()}
                </td>
                <td>{t.paymentMethod}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Finances;
