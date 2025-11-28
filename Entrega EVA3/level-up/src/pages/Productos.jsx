import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useCarrito } from '../context/CarritoContext';
import '../styles/Productos.css';

const PRODUCTOS_BASE = [
  {
    id: "JM001",
    codigo: "JM001",
    categoria: "Juegos de Mesa",
    nombre: "Catan",
    precio: 29990,
    stock: 10,
    descripcion: "Juego clásico de estrategia.",
    imagen: "/assets/imgs/destacado1.png"
  },
  {
    id: "AC001",
    codigo: "AC001",
    categoria: "Accesorios",
    nombre: "Control Xbox Series X",
    precio: 59990,
    stock: 15,
    descripcion: "Control inalámbrico.",
    imagen: "/assets/imgs/destacado2.png"
  },
  {
    id: "CO001",
    codigo: "CO001",
    categoria: "Consolas",
    nombre: "PlayStation 5",
    precio: 549990,
    stock: 5,
    descripcion: "Consola de última generación.",
    imagen: "/assets/imgs/destacado3.png"
  }
];

export default function Productos() {
  const [productos, setProductos] = useState([]);
  const [filtroCategoria, setFiltroCategoria] = useState('todas');
  const [busqueda, setBusqueda] = useState('');
  const { agregarAlCarrito } = useCarrito();

  useEffect(() => {
    const cargarProductos = () => {
      const productosLS = JSON.parse(localStorage.getItem('productos') || '[]');
      
      const productosValidos = productosLS.length > 0 
        ? productosLS.filter(p => p.stock > 0).map(p => ({ ...p, id: p.codigo }))
        : PRODUCTOS_BASE;

      setProductos(productosValidos);
    };

    cargarProductos();

    const handleStorageChange = () => {
      cargarProductos();
    };

    window.addEventListener('storage', handleStorageChange);

    return () => {
      window.removeEventListener('storage', handleStorageChange);
    };
  }, []);

  const categoriasDisponibles = [
    'todas',
    'Juegos de Mesa',
    'Accesorios',
    'Consolas',
    'Videojuegos',
    'Figuras',
    'Otros'
  ];

  let productosFiltrados = productos.filter(producto => {
    const cumpleCategoria = filtroCategoria === 'todas' || producto.categoria === filtroCategoria;
    const cumpleBusqueda = producto.nombre.toLowerCase().includes(busqueda.toLowerCase()) ||
                          producto.descripcion?.toLowerCase().includes(busqueda.toLowerCase()) ||
                          producto.codigo.toLowerCase().includes(busqueda.toLowerCase());
    return cumpleCategoria && cumpleBusqueda;
  });

  const handleAgregarAlCarrito = (codigo) => {
    const prod = productos.find(p => p.codigo === codigo);
    if (prod) {
      agregarAlCarrito(prod);
      if (window.notificar) {
        window.notificar(`¡${prod.nombre} agregado al carrito!`, 'success', 3000);
      }
    }
  };

  return (
    <main className="container">
      <h2 className="section-title">Productos</h2>
      
      {/* Barra de búsqueda mejorada */}
      <div className="search-container mb-4">
        <div className="search-wrapper">
          <div className="search-icon">
            <i className="fas fa-search"></i>
          </div>
          <input
            type="text"
            className="search-input"
            placeholder="¿Qué producto estás buscando?"
            value={busqueda}
            onChange={(e) => setBusqueda(e.target.value)}
          />
          {busqueda && (
            <button 
              className="search-clear"
              onClick={() => setBusqueda('')}
              title="Limpiar búsqueda"
            >
              <i className="fas fa-times"></i>
            </button>
          )}
        </div>
        {busqueda && (
          <div className="search-hint">
            <i className="fas fa-info-circle me-2"></i>
            Buscando: "<span className="text-success fw-bold">{busqueda}</span>"
          </div>
        )}
      </div>

      <div className="filtros-productos mb-4">
        <div className="filtros-header mb-3">
          <i className="fas fa-filter me-2"></i>
          <span>Filtrar por categoría</span>
        </div>
        <div className="d-flex gap-2 flex-wrap justify-content-center">
          {categoriasDisponibles.map(categoria => {
            const cantidadProductos = categoria === 'todas' 
              ? productos.length 
              : productos.filter(p => p.categoria === categoria).length;
            
            return (
              <button
                key={categoria}
                className={`btn filtro-btn ${filtroCategoria === categoria ? 'btn-success active' : 'btn-outline-success'}`}
                onClick={() => setFiltroCategoria(categoria)}
              >
                <span className="filtro-nombre">
                  {categoria.charAt(0).toUpperCase() + categoria.slice(1)}
                </span>
                <span className="filtro-badge">{cantidadProductos}</span>
              </button>
            );
          })}
        </div>
      </div>

      {(busqueda || filtroCategoria !== 'todas') && (
        <div className="text-center mb-3">
          <small className="text-secondary">
            Mostrando {productosFiltrados.length} de {productos.length} productos
          </small>
        </div>
      )}

      <div id="listado-productos" className="grid products productos-table">
        {productosFiltrados.length === 0 ? (
          <div className="no-productos-container">
            <div className="no-productos-icon">
              <i className="fas fa-box-open"></i>
            </div>
            <h4 className="no-productos-title">
              {productos.length === 0 
                ? 'No hay productos disponibles por el momento' 
                : 'No se encontraron productos'}
            </h4>
            <p className="no-productos-text">
              {productos.length === 0 
                ? 'Estamos trabajando para traerte los mejores productos gaming. ¡Vuelve pronto!' 
                : filtroCategoria !== 'todas'
                  ? `No hay productos en la categoría "${filtroCategoria}"`
                  : 'Intenta con otros términos de búsqueda'}
            </p>
            {(busqueda || filtroCategoria !== 'todas') && (
              <button 
                className="btn btn-success mt-3"
                onClick={() => {
                  setBusqueda('');
                  setFiltroCategoria('todas');
                }}
              >
                <i className="fas fa-redo me-2"></i>
                Ver todos los productos
              </button>
            )}
          </div>
        ) : (
          productosFiltrados.map((prod) => (
            <div 
              key={prod.codigo} 
              className="card bg-dark text-white border-success m-2 d-inline-block producto-card"
            >
              <div className="card-body d-flex flex-column align-items-center producto-card-body">
                {prod.imagen && (
                  <div className="producto-img-container">
                    <img 
                      src={prod.imagen} 
                      alt={prod.nombre} 
                      className="img-fluid rounded producto-img" 
                    />
                  </div>
                )}
                <h5 className="card-title mt-2 producto-titulo">{prod.nombre}</h5>
                <p className="card-text mb-1">
                  <span className="badge bg-secondary producto-categoria">{prod.categoria}</span>
                </p>
                <p className="card-text mb-1 producto-descripcion">{prod.descripcion || ''}</p>
                <p className="card-text fw-bold mb-1 producto-precio">${prod.precio.toLocaleString('es-CL')}</p>
                <div className="d-flex flex-column align-items-center w-100 mt-auto">
                  <button 
                    className="btn btn-success mb-2 w-75" 
                    onClick={() => handleAgregarAlCarrito(prod.codigo)}
                  >
                    Agregar al carrito
                  </button>
                  <Link 
                    className="btn btn-outline-success px-4 text-center" 
                    to={`/detalle/${prod.codigo}`}
                  >
                    Ver Detalles
                  </Link>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </main>
  );
}
