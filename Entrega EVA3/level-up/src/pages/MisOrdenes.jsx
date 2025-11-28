import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getUserOrders } from '../services/orderService';
import '../styles/MisOrdenes.css';

export default function MisOrdenes() {
  const [ordenes, setOrdenes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    cargarOrdenes();
  }, []);

  const cargarOrdenes = async () => {
    try {
      setLoading(true);
      const data = await getUserOrders();
      // Ordenar por fecha más reciente primero
      const ordenesOrdenadas = data.sort((a, b) => 
        new Date(b.createdAt) - new Date(a.createdAt)
      );
      setOrdenes(ordenesOrdenadas);
    } catch (err) {
      console.error('Error al cargar órdenes:', err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const formatearPrecio = (precio) => {
    return `$${precio.toLocaleString('es-CL')}`;
  };

  const formatearFecha = (fecha) => {
    return new Date(fecha).toLocaleDateString('es-CL', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const obtenerEstadoBadge = (status) => {
    const badges = {
      PENDING: { class: 'badge-warning', text: 'Pendiente' },
      CONFIRMED: { class: 'badge-info', text: 'Confirmada' },
      SHIPPED: { class: 'badge-primary', text: 'Enviada' },
      DELIVERED: { class: 'badge-success', text: 'Entregada' },
      CANCELLED: { class: 'badge-danger', text: 'Cancelada' }
    };
    return badges[status] || { class: 'badge-secondary', text: status };
  };

  if (loading) {
    return (
      <main className="container mis-ordenes-page">
        <h2 className="section-title">Mis Órdenes</h2>
        <div className="text-center py-5">
          <div className="spinner-border text-success" role="status">
            <span className="visually-hidden">Cargando...</span>
          </div>
          <p className="mt-3">Cargando órdenes...</p>
        </div>
      </main>
    );
  }

  if (error) {
    return (
      <main className="container mis-ordenes-page">
        <h2 className="section-title">Mis Órdenes</h2>
        <div className="alert alert-danger" role="alert">
          <h4 className="alert-heading">Error al cargar órdenes</h4>
          <p>{error}</p>
          <hr />
          <button className="btn btn-danger" onClick={cargarOrdenes}>
            Reintentar
          </button>
        </div>
      </main>
    );
  }

  return (
    <main className="container mis-ordenes-page">
      <h2 className="section-title mb-4">Mis Órdenes</h2>

      {ordenes.length === 0 ? (
        <div className="text-center py-5">
          <img 
            src="/assets/icons/carrito.png" 
            alt="Sin órdenes" 
            className="mb-4"
            style={{ width: '100px', opacity: 0.5 }}
          />
          <h3 className="text-secondary mb-4">No tienes órdenes todavía</h3>
          <Link to="/productos" className="btn btn-success px-5">
            Ir a Productos
          </Link>
        </div>
      ) : (
        <div className="ordenes-list">
          {ordenes.map((orden) => {
            const badge = obtenerEstadoBadge(orden.status);
            return (
              <div key={orden.id} className="orden-card mb-4">
                <div className="orden-header">
                  <div className="orden-info">
                    <h5 className="orden-id">Orden #{orden.id}</h5>
                    <p className="orden-fecha mb-0">
                      {formatearFecha(orden.createdAt)}
                    </p>
                  </div>
                  <div className="orden-estado">
                    <span className={`badge ${badge.class}`}>
                      {badge.text}
                    </span>
                  </div>
                </div>

                <div className="orden-body">
                  <div className="orden-items">
                    <h6 className="mb-3">Productos:</h6>
                    {orden.items && orden.items.map((item, index) => (
                      <div key={index} className="orden-item mb-2">
                        <div className="d-flex justify-content-between">
                          <span>
                            {item.productName || `Producto ${item.productId}`}
                            <small className="text-muted ms-2">x{item.quantity}</small>
                          </span>
                          <span className="fw-bold">
                            {formatearPrecio(item.price * item.quantity)}
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>

                  <hr />

                  <div className="orden-totales">
                    {orden.subtotalAmount && (
                      <div className="d-flex justify-content-between mb-1">
                        <span>Subtotal:</span>
                        <span>{formatearPrecio(orden.subtotalAmount)}</span>
                      </div>
                    )}
                    {orden.discountAmount > 0 && (
                      <div className="d-flex justify-content-between mb-1">
                        <span>Descuento:</span>
                        <span className="text-success">
                          -{formatearPrecio(orden.discountAmount)}
                        </span>
                      </div>
                    )}
                    <div className="d-flex justify-content-between mb-2">
                      <strong>Total:</strong>
                      <strong className="orden-total">
                        {formatearPrecio(orden.totalAmount)}
                      </strong>
                    </div>
                  </div>

                  {orden.shippingAddress && (
                    <div className="orden-envio mt-3">
                      <small className="text-muted">
                        <strong>Dirección:</strong> {orden.shippingAddress}
                      </small>
                    </div>
                  )}

                  {orden.paymentMethod && (
                    <div className="orden-pago">
                      <small className="text-muted">
                        <strong>Método de pago:</strong> {orden.paymentMethod}
                      </small>
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </main>
  );
}
