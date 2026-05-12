import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { MessageSquare, Clock, CheckCircle2, AlertCircle, Send } from 'lucide-react';
import './Support.css';

const Support = () => {
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedTicket, setSelectedTicket] = useState(null);
  const [reply, setReply] = useState('');

  useEffect(() => {
    fetchTickets();
  }, []);

  const fetchTickets = async () => {
    try {
      const response = await axios.get('http://localhost:5000/api/QuestionsClients', {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setTickets(response.data.data);
      setLoading(false);
    } catch (error) {
      console.error("Erreur support", error);
      setLoading(false);
    }
  };

  const handleReply = async (e) => {
    e.preventDefault();
    if (!reply.trim()) return;

    try {
      await axios.post(`http://localhost:5000/api/QuestionsClients/${selectedTicket._id}/reponse`, {
        reponse: reply
      }, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setReply('');
      fetchTickets();
      setSelectedTicket(prev => ({ ...prev, status: 'répondu', reponse: reply }));
    } catch (error) {
      alert("Erreur lors de l'envoi de la réponse");
    }
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case 'répondu': return <span className="status-badge solved"><CheckCircle2 size={12} /> Répondu</span>;
      case 'en_attente': return <span className="status-badge pending"><Clock size={12} /> En attente</span>;
      default: return <span className="status-badge open"><AlertCircle size={12} /> Nouveau</span>;
    }
  };

  return (
    <div className="support-container">
      <header className="support-header">
        <h1>Centre de Support Clients</h1>
        <p>Répondez aux questions et préoccupations de vos patients</p>
      </header>

      <div className="support-layout">
        <aside className="ticket-list">
          <div className="list-header">
            <h3>Demandes Récentes</h3>
            <span>{tickets.length} tickets</span>
          </div>
          <div className="tickets-scroll">
            {tickets.map(ticket => (
              <div 
                key={ticket._id} 
                className={`ticket-item ${selectedTicket?._id === ticket._id ? 'active' : ''}`}
                onClick={() => setSelectedTicket(ticket)}
              >
                <div className="ticket-item-header">
                  <strong>{ticket.clientName || 'Patient'}</strong>
                  {getStatusBadge(ticket.status)}
                </div>
                <p className="ticket-preview">{ticket.question}</p>
                <small className="ticket-date">{new Date(ticket.createdAt).toLocaleDateString()}</small>
              </div>
            ))}
          </div>
        </aside>

        <main className="ticket-detail">
          {selectedTicket ? (
            <div className="detail-view">
              <div className="detail-header">
                <h2>Détails du Ticket</h2>
                <div className="patient-tag">Patient: {selectedTicket.clientName}</div>
              </div>

              <div className="conversation">
                <div className="message client">
                  <div className="message-header">Patient - {new Date(selectedTicket.createdAt).toLocaleString()}</div>
                  <div className="message-body">{selectedTicket.question}</div>
                </div>

                {selectedTicket.reponse && (
                  <div className="message pharmacy">
                    <div className="message-header">Votre réponse - {new Date(selectedTicket.updatedAt).toLocaleString()}</div>
                    <div className="message-body">{selectedTicket.reponse}</div>
                  </div>
                )}
              </div>

              {selectedTicket.status !== 'répondu' && (
                <form className="reply-box" onSubmit={handleReply}>
                  <textarea 
                    placeholder="Tapez votre réponse ici..." 
                    value={reply}
                    onChange={(e) => setReply(e.target.value)}
                  />
                  <button type="submit" className="send-btn">
                    <Send size={18} /> Répondre
                  </button>
                </form>
              )}
            </div>
          ) : (
            <div className="empty-support">
              <MessageSquare size={64} />
              <h3>Sélectionnez une demande pour y répondre</h3>
              <p>Maintenez un lien de confiance avec vos patients en répondant rapidement à leurs questions.</p>
            </div>
          )}
        </main>
      </div>
    </div>
  );
};

export default Support;
