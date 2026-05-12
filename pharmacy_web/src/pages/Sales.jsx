import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Sales.css';

const Sales = () => {
  const [products, setProducts] = useState([]);
  const [cart, setCart] = useState([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(false);
  const [paymentMethod, setPaymentMethod] = useState('cash');

  useEffect(() => {
    if (search.length > 2) {
      const delayDebounceFn = setTimeout(() => {
        fetchProducts();
      }, 300);
      return () => clearTimeout(delayDebounceFn);
    }
  }, [search]);

  const fetchProducts = async () => {
    setLoading(true);
    try {
      const response = await axios.get(`http://localhost:5000/api/products?search=${search}`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setProducts(response.data.data);
    } catch (error) {
      console.error("Erreur de recherche", error);
    } finally {
      setLoading(false);
    }
  };

  const addToCart = (product) => {
    if (product.stockQuantity <= 0) {
      alert("Stock épuisé !");
      return;
    }
    const existing = cart.find(item => item._id === product._id);
    if (existing) {
      setCart(cart.map(item => 
        item._id === product._id ? { ...item, quantity: item.quantity + 1 } : item
      ));
    } else {
      setCart([...cart, { ...product, quantity: 1 }]);
    }
  };

  const removeFromCart = (id) => {
    setCart(cart.filter(item => item._id !== id));
  };

  const total = cart.reduce((sum, item) => sum + (item.sellingPrice * item.quantity), 0);

  const handleCheckout = async () => {
    if (cart.length === 0) return;
    
    try {
      const saleData = {
        items: cart.map(item => ({
          productId: item._id,
          quantity: item.quantity,
          price: item.sellingPrice
        })),
        paymentMethod,
        totalAmount: total
      };

      await axios.post('http://localhost:5000/api/sales', saleData, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });

      alert("Vente réussie !");
      setCart([]);
      setProducts([]);
      setSearch('');
    } catch (error) {
      alert(error.response?.data?.message || "Erreur lors de la vente");
    }
  };

  return (
    <div className="pos-container">
      <div className="pos-main">
        <header className="pos-header">
          <div className="search-wrapper">
            <input 
              type="text" 
              placeholder="Rechercher un produit (Nom, Barcode)..." 
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
            {loading && <div className="spinner"></div>}
          </div>
        </header>

        <div className="products-grid">
          {products.map(product => (
            <div key={product._id} className="product-item" onClick={() => addToCart(product)}>
              <div className="product-info">
                <h4>{product.name}</h4>
                <p>{product.stockQuantity} en stock</p>
              </div>
              <div className="product-price">
                {product.sellingPrice} FCFA
              </div>
            </div>
          ))}
          {products.length === 0 && !loading && (
            <div className="pos-placeholder">
              Recherchez des produits pour commencer la vente.
            </div>
          )}
        </div>
      </div>

      <div className="pos-cart">
        <div className="cart-header">
          <h2>Panier Actuel</h2>
          <button className="clear-btn" onClick={() => setCart([])}>Vider</button>
        </div>

        <div className="cart-items">
          {cart.map(item => (
            <div key={item._id} className="cart-item">
              <div className="item-details">
                <span className="item-name">{item.name}</span>
                <span className="item-price">{item.sellingPrice} x {item.quantity}</span>
              </div>
              <div className="item-actions">
                <span className="item-total">{item.sellingPrice * item.quantity} FCFA</span>
                <button onClick={() => removeFromCart(item._id)}>×</button>
              </div>
            </div>
          ))}
          {cart.length === 0 && (
            <div className="cart-empty">Le panier est vide.</div>
          )}
        </div>

        <div className="cart-footer">
          <div className="payment-options">
            <label>Mode de paiement:</label>
            <div className="options-grid">
              {['cash', 'card', 'mobile_money'].map(m => (
                <button 
                  key={m}
                  className={paymentMethod === m ? 'active' : ''}
                  onClick={() => setPaymentMethod(m)}
                >
                  {m === 'cash' ? 'Espèces' : m === 'card' ? 'Carte' : 'Mobile'}
                </button>
              ))}
            </div>
          </div>

          <div className="total-display">
            <span>Total à payer</span>
            <h1>{total} FCFA</h1>
          </div>

          <button className="checkout-btn" disabled={cart.length === 0} onClick={handleCheckout}>
            Valider la Vente
          </button>
        </div>
      </div>
    </div>
  );
};

export default Sales;
