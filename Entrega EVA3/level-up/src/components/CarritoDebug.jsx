import React from 'react';
import { useCarrito } from '../context/CarritoContext';
import '../styles/CarritoDebug.css';

export default function CarritoDebug() {
  const { carrito, obtenerCantidadTotal, calcularTotal } = useCarrito();

  const handleLimpiarTodo = () => {
    if (window.confirm('¿Limpiar todo el localStorage?')) {
      localStorage.clear();
      window.location.reload();
    }
  };

  const handleVerLocalStorage = () => {
    const info = {
      carrito: localStorage.getItem('carrito'),
      productos: localStorage.getItem('productos'),
      usuarios: localStorage.getItem('usuarios'),
      usuarioActual: localStorage.getItem('usuarioActual')
    };
    alert(JSON.stringify(info, null, 2));
  };

  return (
    <div className="carrito-debug">
      <h6 className="carrito-debug-title"> Debug Carrito</h6>
      <div className="carrito-debug-info">
        <p>Items: {obtenerCantidadTotal()}</p>
        <p>Total: ${calcularTotal().toLocaleString('es-CL')}</p>
        <p>Productos en carrito: {carrito.length}</p>
      </div>
      <details className="carrito-debug-details">
        <summary className="carrito-debug-summary">Ver carrito</summary>
        <pre className="carrito-debug-pre">
          {JSON.stringify(carrito, null, 2)}
        </pre>
      </details>
      <div className="carrito-debug-buttons">
        <button 
          onClick={handleVerLocalStorage}
          className="carrito-debug-btn-primary"
        >
          Ver LocalStorage
        </button>
        <button 
          onClick={handleLimpiarTodo}
          className="carrito-debug-btn-danger"
        >
          Limpiar Todo
        </button>
      </div>
    </div>
  );
}
