import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { useCarrito } from '../context/CarritoContext';
import '../styles/Detalle.css';

export default function Detalle() {
  const { codigo } = useParams();
  const navigate = useNavigate();
  const [producto, setProducto] = useState(null);
  const [cantidad, setCantidad] = useState(1);
  const { agregarAlCarrito } = useCarrito();

  useEffect(() => {
    const productos = JSON.parse(localStorage.getItem('productos') || '[]');
    const prod = productos.find(p => p.codigo === codigo);
    
    if (prod) {
      setProducto(prod);
    } else {
      if (window.notificar) {
        window.notificar('Producto no encontrado', 'error', 3000);
      }
      navigate('/productos');
    }
  }, [codigo, navigate]);

  const handleAgregarAlCarrito = () => {
    if (producto) {
      agregarAlCarrito(producto, cantidad);
      if (window.notificar) {
        window.notificar(`¡${cantidad} x ${producto.nombre} agregado al carrito!`, 'success', 3000);
      }
    }
  };

  const formatearPrecio = (precio) => {
    return `$${precio.toLocaleString('es-CL')}`;
  };

  if (!producto) {
    return (
      <main className="container detalle-loading">
        <div className="text-center py-5">
          <p className="text-secondary">Cargando producto...</p>
        </div>
      </main>
    );
  }

  return (
    <main className="container detalle-page">
      <nav aria-label="breadcrumb" className="mb-4">
        <ol className="breadcrumb">
          <li className="breadcrumb-item">
            <Link to="/" className="detalle-breadcrumb-link">Inicio</Link>
          </li>
          <li className="breadcrumb-item">
            <Link to="/productos" className="detalle-breadcrumb-link">Productos</Link>
          </li>
          <li className="breadcrumb-item active" aria-current="page">
            {producto.nombre}
          </li>
        </ol>
      </nav>

      <div className="row">
        <div className="col-md-6 mb-4">
          <div className="detalle-imagen-container">
            <img 
              src={producto.imagen} 
              alt={producto.nombre}
              className="img-fluid rounded"
            />
          </div>
        </div>

        <div className="col-md-6">
          <div className="detalle-info">
            <span className="badge bg-secondary mb-3 detalle-badge">
              {producto.categoria}
            </span>
            
            <h1 className="mb-3 detalle-titulo-producto">
              {producto.nombre}
            </h1>

            <p className="mb-2 detalle-categoria">
              Código: {producto.codigo}
            </p>

            <div className="mb-4">
              <h2 className="detalle-precio">
                {formatearPrecio(producto.precio)}
              </h2>
            </div>

            <div className="mb-4">
              <h5 className="detalle-seccion-titulo">Descripción</h5>
              <p className="detalle-descripcion">
                {producto.descripcion || producto.desc || 'Sin descripción disponible.'}
              </p>
            </div>

            <div className="mb-4">
              <h5 className="detalle-seccion-titulo">Disponibilidad</h5>
              <p>
                <span 
                  className={`detalle-stock-disponible ${producto.stock > 0 ? 'text-success' : 'text-danger'}`}
                >
                  {producto.stock > 0 ? `${producto.stock} unidades disponibles` : 'Agotado'}
                </span>
              </p>
            </div>

            {producto.stock > 0 && (
              <>
                <div className="mb-4">
                  <h5 className="detalle-seccion-titulo">Cantidad</h5>
                  <div className="cantidad-selector d-flex align-items-center">
                    <button 
                      className="btn btn-outline-secondary"
                      onClick={() => setCantidad(Math.max(1, cantidad - 1))}
                      disabled={cantidad <= 1}
                    >
                      -
                    </button>
                    <input 
                      type="number" 
                      className="form-control mx-3 text-center detalle-cantidad-input"
                      value={cantidad}
                      onChange={(e) => setCantidad(Math.max(1, Math.min(producto.stock, parseInt(e.target.value) || 1)))}
                      min="1"
                      max={producto.stock}
                    />
                    <button 
                      className="btn btn-outline-secondary"
                      onClick={() => setCantidad(Math.min(producto.stock, cantidad + 1))}
                      disabled={cantidad >= producto.stock}
                    >
                      +
                    </button>
                  </div>
                </div>

                <div className="d-flex gap-3">
                  <button 
                    className="btn btn-success flex-grow-1 detalle-btn-agregar"
                    onClick={handleAgregarAlCarrito}
                  >
                    Agregar al Carrito
                  </button>
                  <Link 
                    to="/carrito"
                    className="btn btn-outline-success detalle-btn-volver"
                  >
                    Ir al Carrito
                  </Link>
                </div>
              </>
            )}

            {producto.stock === 0 && (
              <div className="alert alert-danger mt-3">
                Este producto está temporalmente agotado.
              </div>
            )}
          </div>
        </div>
      </div>
    </main>
  );
}
