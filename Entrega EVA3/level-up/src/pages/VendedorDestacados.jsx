import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { registrarLogAdmin } from '../utils/logManager';
import ModalConfirmacion from '../components/ModalConfirmacion';
import '../styles/Admin.css';

export default function VendedorDestacados() {
  const [destacadosCodigos, setDestacadosCodigos] = useState([]);
  const [productos, setProductos] = useState([]);
  const [codigoSeleccionado, setCodigoSeleccionado] = useState('');
  const [mostrarModal, setMostrarModal] = useState(false);
  const [productoAEliminar, setProductoAEliminar] = useState(null);

  useEffect(() => {
    cargarDatos();
    limpiarDestacados();
  }, []);

  const limpiarDestacados = () => {
    const productosLS = JSON.parse(localStorage.getItem('productos') || '[]');
    const destacadosLS = JSON.parse(localStorage.getItem('destacados') || '[]');
    
    const destacadosValidos = destacadosLS.filter(codigo => 
      productosLS.some(p => p.codigo === codigo)
    );
    
    localStorage.setItem('destacados', JSON.stringify(destacadosValidos));
    window.dispatchEvent(new Event('destacadosActualizados'));
    window.dispatchEvent(new Event('storage'));
  };

  const cargarDatos = () => {
    const productosLS = JSON.parse(localStorage.getItem('productos') || '[]');
    const destacadosLS = JSON.parse(localStorage.getItem('destacados') || '[]');
    
    const destacadosLimpios = destacadosLS.filter(codigo => 
      productosLS.find(p => p.codigo === codigo)
    );
    
    if (destacadosLimpios.length !== destacadosLS.length) {
      localStorage.setItem('destacados', JSON.stringify(destacadosLimpios));
      window.dispatchEvent(new Event('destacadosActualizados'));
    }
    
    setProductos(productosLS);
    setDestacadosCodigos(destacadosLimpios);
  };

  const destacados = destacadosCodigos.map(codigo => {
    const producto = productos.find(p => p.codigo === codigo);
    if (producto) {
      return {
        codigo: producto.codigo,
        nombre: producto.nombre,
        categoria: producto.categoria,
        precio: producto.precio,
        desc: producto.descripcion || producto.desc || 'Producto destacado',
        img: producto.imagen,
        imagen: producto.imagen
      };
    }
    return null;
  }).filter(p => p !== null);

  const agregarDestacado = () => {
    if (!codigoSeleccionado) {
      if (window.notificar) {
        window.notificar('Debes seleccionar un producto', 'error', 3000);
      }
      return;
    }

    const productoExiste = productos.find(p => p.codigo === codigoSeleccionado);
    if (!productoExiste) {
      if (window.notificar) {
        window.notificar('El producto seleccionado no existe', 'error', 3000);
      }
      return;
    }

    const yaDestacado = destacadosCodigos.find(codigo => codigo === codigoSeleccionado);
    if (yaDestacado) {
      if (window.notificar) {
        window.notificar('Este producto ya está destacado', 'error', 3000);
      }
      return;
    }

    const nuevosDestacados = [...destacadosCodigos, codigoSeleccionado];
    localStorage.setItem('destacados', JSON.stringify(nuevosDestacados));
    setDestacadosCodigos(nuevosDestacados);
    setCodigoSeleccionado('');
    
    window.dispatchEvent(new Event('destacadosActualizados'));
    window.dispatchEvent(new Event('storage'));
    
    registrarLogAdmin(`Agregó producto a destacados: ${productoExiste.nombre} (${codigoSeleccionado})`);
    
    if (window.notificar) {
      window.notificar('Producto agregado a destacados exitosamente', 'success', 3000);
    }
  };

  const confirmarEliminar = (codigo) => {
    setProductoAEliminar(codigo);
    setMostrarModal(true);
  };

  const eliminarDestacado = () => {
    if (productoAEliminar) {
      const producto = productos.find(p => p.codigo === productoAEliminar);
      const destacadosActualizados = destacadosCodigos.filter(c => c !== productoAEliminar);
      localStorage.setItem('destacados', JSON.stringify(destacadosActualizados));
      setDestacadosCodigos(destacadosActualizados);
      
      window.dispatchEvent(new Event('destacadosActualizados'));
      window.dispatchEvent(new Event('storage'));
      
      cargarDatos();
      
      registrarLogAdmin(`Eliminó producto de destacados: ${producto?.nombre || 'Desconocido'} (${productoAEliminar})`);
      
      if (window.notificar) {
        window.notificar('Producto eliminado de destacados exitosamente', 'success', 3000);
      }
      setMostrarModal(false);
      setProductoAEliminar(null);
    }
  };

  const cancelarEliminar = () => {
    setMostrarModal(false);
    setProductoAEliminar(null);
  };

  const productosDisponibles = productos.filter(p => 
    !destacadosCodigos.find(codigo => codigo === p.codigo)
  );

  return (
    <main className="container admin-page">
      <div className="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h2 className="section-title mb-2">Gestión de Productos Destacados</h2>
          <p className="admin-destacados-info">
            Total de productos destacados: <span className="admin-destacados-contador">{destacados.length}</span>
          </p>
          <Link to="/vendedor" className="text-secondary">
            ← Volver al Panel
          </Link>
        </div>
      </div>

      <div className="admin-card mb-4">
        <div className="admin-card-header">
          <h4>Agregar Producto Destacado</h4>
        </div>
        <div className="admin-card-body">
          <div className="row align-items-end">
            <div className="col-md-9 mb-3 mb-md-0">
              <label className="form-label text-white">Seleccionar Producto Existente</label>
              <select
                className="form-control admin-destacados-select"
                value={codigoSeleccionado}
                onChange={(e) => setCodigoSeleccionado(e.target.value)}
              >
                <option value="">-- Seleccione un producto --</option>
                {productosDisponibles.map(producto => (
                  <option key={producto.codigo} value={producto.codigo}>
                    {producto.codigo} - {producto.nombre} (${producto.precio.toLocaleString('es-CL')})
                  </option>
                ))}
              </select>
            </div>
            <div className="col-md-3">
              <button 
                className="btn btn-success w-100"
                onClick={agregarDestacado}
              >
                + Agregar Destacado
              </button>
            </div>
          </div>
          {productosDisponibles.length === 0 && productos.length > 0 && (
            <div className="alert alert-info mt-3 mb-0">
              Todos los productos ya están destacados o no hay productos disponibles.
            </div>
          )}
          {productos.length === 0 && (
            <div className="alert alert-warning mt-3 mb-0">
              No hay productos registrados. <Link to="/vendedor/productos/nuevo" className="alert-link">Crear producto</Link>
            </div>
          )}
        </div>
      </div>

      <div className="admin-card">
        <div className="admin-card-header">
          <h4>Productos Destacados en el Carrusel</h4>
        </div>
        <div className="admin-card-body">
          {destacados.length === 0 ? (
            <div className="text-center py-4">
              <p className="text-secondary">No hay productos destacados</p>
              <p className="text-white">Los productos que agregues aquí aparecerán en el carrusel de la página de inicio</p>
            </div>
          ) : (
            <div className="admin-table">
              <table className="table table-dark table-hover">
                <thead>
                  <tr>
                    <th>Imagen</th>
                    <th>Código</th>
                    <th>Nombre</th>
                    <th>Categoría</th>
                    <th>Precio</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {destacados.map((producto) => (
                    <tr key={producto.codigo}>
                      <td>
                        <img 
                          src={producto.imagen || '/assets/icons/icono.png'} 
                          alt={producto.nombre}
                          width="50"
                          height="50"
                          className="admin-producto-img"
                        />
                      </td>
                      <td>{producto.codigo}</td>
                      <td>{producto.nombre}</td>
                      <td>
                        <span className="badge bg-secondary">
                          {producto.categoria}
                        </span>
                      </td>
                      <td className="admin-producto-precio">
                        ${producto.precio.toLocaleString('es-CL')}
                      </td>
                      <td>
                        <button 
                          className="btn btn-sm btn-danger btn-action"
                          onClick={() => confirmarEliminar(producto.codigo)}
                        >
                          Eliminar
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>

      <ModalConfirmacion
        mostrar={mostrarModal}
        titulo="Eliminar Producto Destacado"
        mensaje={`¿Estás seguro de que deseas eliminar este producto de destacados? El producto seguirá existiendo pero ya no aparecerá en el carrusel.`}
        onConfirmar={eliminarDestacado}
        onCancelar={cancelarEliminar}
      />
    </main>
  );
}
