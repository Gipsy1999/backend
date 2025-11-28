import React, { createContext, useContext, useState, useEffect } from 'react';
import { registrarLogUsuario } from '../utils/logManager';

const CarritoContext = createContext();

export const useCarrito = () => {
  const context = useContext(CarritoContext);
  if (!context) {
    throw new Error('useCarrito debe usarse dentro de CarritoProvider');
  }
  return context;
};

export const CarritoProvider = ({ children }) => {
  const [carrito, setCarrito] = useState([]);

  const obtenerKeyCarrito = () => {
    const usuarioActual = JSON.parse(localStorage.getItem('usuarioActual') || 'null');
    return usuarioActual ? `carrito_${usuarioActual.correo || usuarioActual.email}` : 'carrito_invitado';
  };

  useEffect(() => {
    const keyCarrito = obtenerKeyCarrito();
    const carritoGuardado = localStorage.getItem(keyCarrito);
    if (carritoGuardado) {
      try {
        setCarrito(JSON.parse(carritoGuardado));
      } catch (error) {
        setCarrito([]);
      }
    } else {
      setCarrito([]);
    }
  }, []);

  useEffect(() => {
    const handleStorageChange = () => {
      const keyCarrito = obtenerKeyCarrito();
      const carritoGuardado = localStorage.getItem(keyCarrito);
      if (carritoGuardado) {
        try {
          setCarrito(JSON.parse(carritoGuardado));
        } catch (error) {
          setCarrito([]);
        }
      } else {
        setCarrito([]);
      }
    };

    window.addEventListener('usuarioActualizado', handleStorageChange);
    return () => window.removeEventListener('usuarioActualizado', handleStorageChange);
  }, []);

  useEffect(() => {
    const keyCarrito = obtenerKeyCarrito();
    if (carrito.length > 0) {
      localStorage.setItem(keyCarrito, JSON.stringify(carrito));
    } else {
      localStorage.removeItem(keyCarrito);
    }
  }, [carrito]);

  const agregarAlCarrito = (producto, qty = 1) => {
    if (!producto || !producto.codigo) {
      return;
    }
    
    const productos = JSON.parse(localStorage.getItem('productos') || '[]');
    const productoActual = productos.find(p => p.codigo === producto.codigo);
    const stockDisponible = productoActual ? productoActual.stock : producto.stock;
    
    if (stockDisponible <= 0) {
      if (window.notificar) {
        window.notificar('Producto sin stock disponible', 'error', 3000);
      }
      return;
    }
    
    setCarrito(prevCarrito => {
      const idx = prevCarrito.findIndex(item => item.codigo === producto.codigo);
      
      if (idx >= 0) {
        const cantidadActual = prevCarrito[idx].qty;
        const nuevaCantidad = cantidadActual + qty;
        
        if (nuevaCantidad > stockDisponible) {
          if (window.notificar) {
            window.notificar(`Solo hay ${stockDisponible} unidades disponibles`, 'error', 3000);
          }
          return prevCarrito;
        }
        
        const newCart = [...prevCarrito];
        newCart[idx] = {
          ...newCart[idx],
          qty: nuevaCantidad
        };
        
        registrarLogUsuario(`Agregó al carrito: ${producto.nombre} (cantidad: ${qty})`);
        return newCart;
      } else {
        if (qty > stockDisponible) {
          if (window.notificar) {
            window.notificar(`Solo hay ${stockDisponible} unidades disponibles`, 'error', 3000);
          }
          return prevCarrito;
        }
        
        registrarLogUsuario(`Agregó al carrito: ${producto.nombre} (cantidad: ${qty})`);
        return [...prevCarrito, {
          codigo: producto.codigo,
          nombre: producto.nombre,
          precio: producto.precio,
          imagen: producto.imagen,
          qty: qty
        }];
      }
    });
  };

  const eliminarDelCarrito = (codigo) => {
    const itemEliminado = carrito.find(item => item.codigo === codigo);
    if (itemEliminado) {
      registrarLogUsuario(`Eliminó del carrito: ${itemEliminado.nombre} (cantidad: ${itemEliminado.qty})`);
    }
    setCarrito(prevCarrito => prevCarrito.filter(item => item.codigo !== codigo));
  };

  const actualizarCantidad = (codigo, nuevaCantidad) => {
    if (nuevaCantidad <= 0) {
      eliminarDelCarrito(codigo);
      return;
    }
    
    const productos = JSON.parse(localStorage.getItem('productos') || '[]');
    const producto = productos.find(p => p.codigo === codigo);
    
    if (producto && nuevaCantidad > producto.stock) {
      if (window.notificar) {
        window.notificar(`Solo hay ${producto.stock} unidades disponibles`, 'error', 3000);
      }
      return;
    }
    
    setCarrito(prevCarrito =>
      prevCarrito.map(item =>
        item.codigo === codigo
          ? { ...item, qty: nuevaCantidad }
          : item
      )
    );
  };

  const vaciarCarrito = () => {
    const keyCarrito = obtenerKeyCarrito();
    setCarrito([]);
    localStorage.removeItem(keyCarrito);
  };

  const calcularTotales = () => {
    if (carrito.length === 0) {
      return { items: [], subtotal: 0, descuento: 0, total: 0 };
    }

    const items = carrito.map(it => {
      const subtotal = it.precio * it.qty;
      return { ...it, subtotal };
    });
    
    const subtotal = items.reduce((a, b) => a + b.subtotal, 0);
    
    let descuento = 0;
    try {
      const user = JSON.parse(localStorage.getItem('usuarioActual') || 'null');
      const email = user?.correo?.toLowerCase() || user?.email?.toLowerCase() || '';
      if (email.endsWith('@duoc.cl') || email.endsWith('@profesor.duoc.cl')) {
        descuento = subtotal * 0.20;
      }
    } catch (_) {}
    
    const total = Math.max(0, subtotal - descuento);
    
    return { items, subtotal, descuento, total };
  };

  const calcularTotal = () => {
    return calcularTotales().total;
  };

  const obtenerCantidadTotal = () => {
    return carrito.reduce((total, item) => total + item.qty, 0);
  };

  const value = {
    carrito,
    agregarAlCarrito,
    eliminarDelCarrito,
    actualizarCantidad,
    vaciarCarrito,
    calcularTotal,
    calcularTotales,
    obtenerCantidadTotal
  };

  return (
    <CarritoContext.Provider value={value}>
      {children}
    </CarritoContext.Provider>
  );
};
