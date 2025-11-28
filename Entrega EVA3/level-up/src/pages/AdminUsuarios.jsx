import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { registrarLogAdmin } from '../utils/logManager';
import ModalConfirmacion from '../components/ModalConfirmacion';
import '../styles/Admin.css';

export default function AdminUsuarios() {
  const [usuarios, setUsuarios] = useState([]);
  const [busqueda, setBusqueda] = useState('');
  const [mostrarModal, setMostrarModal] = useState(false);
  const [usuarioAEliminar, setUsuarioAEliminar] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    cargarUsuarios();
  }, []);

  const cargarUsuarios = () => {
    const usuariosLS = JSON.parse(localStorage.getItem('usuarios') || '[]');
    setUsuarios(usuariosLS);
  };

  const confirmarEliminar = (correo) => {
    setUsuarioAEliminar(correo);
    setMostrarModal(true);
  };

  const eliminarUsuario = () => {
    if (usuarioAEliminar) {
      const usuario = usuarios.find(u => u.correo === usuarioAEliminar);
      const usuariosActualizados = usuarios.filter(u => u.correo !== usuarioAEliminar);
      localStorage.setItem('usuarios', JSON.stringify(usuariosActualizados));
      setUsuarios(usuariosActualizados);
      
      registrarLogAdmin(`Eliminó usuario: ${usuario?.nombre || 'Desconocido'} (${usuarioAEliminar})`);
      
      if (window.notificar) {
        window.notificar('Usuario eliminado exitosamente', 'success', 3000);
      }
      setMostrarModal(false);
      setUsuarioAEliminar(null);
    }
  };

  const cancelarEliminar = () => {
    setMostrarModal(false);
    setUsuarioAEliminar(null);
  };

  const editarUsuario = (correo) => {
    navigate(`/admin/usuarios/editar/${encodeURIComponent(correo)}`);
  };

  const usuariosFiltrados = usuarios.filter(u => 
    u.nombre.toLowerCase().includes(busqueda.toLowerCase()) ||
    u.correo.toLowerCase().includes(busqueda.toLowerCase()) ||
    (u.apellidos && u.apellidos.toLowerCase().includes(busqueda.toLowerCase()))
  );

  return (
    <main className="container admin-page">
      <div className="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h2 className="section-title mb-2">Gestión de Usuarios</h2>
          <Link to="/admin" className="text-secondary">
            ← Volver al Panel
          </Link>
        </div>
        <Link to="/admin/usuarios/nuevo" className="btn btn-success">
          + Nuevo Usuario
        </Link>
      </div>

      <div className="mb-4">
        <input
          type="text"
          className="form-control admin-search-input"
          placeholder="Buscar por nombre, apellido o correo..."
          value={busqueda}
          onChange={(e) => setBusqueda(e.target.value)}
        />
      </div>

      {usuarios.length === 0 ? (
        <div className="text-center py-5">
          <p className="text-secondary mb-4">No hay usuarios registrados</p>
          <Link to="/admin/usuarios/nuevo" className="btn btn-success">
            Agregar Primer Usuario
          </Link>
        </div>
      ) : (
        <div className="admin-table">
          <table className="table table-dark table-hover">
            <thead>
              <tr>
                <th>RUN</th>
                <th>Nombre</th>
                <th>Apellidos</th>
                <th>Correo</th>
                <th>Fecha Nacimiento</th>
                <th>Rol</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {usuariosFiltrados.map((usuario) => (
                <tr key={usuario.correo}>
                  <td>{usuario.run || 'N/A'}</td>
                  <td>{usuario.nombre}</td>
                  <td>{usuario.apellidos || 'N/A'}</td>
                  <td>{usuario.correo}</td>
                  <td>{usuario.fechaNac || 'N/A'}</td>
                  <td>
                    <span 
                      className={`badge ${usuario.rol === 'admin' ? 'admin-badge-admin' : 'admin-badge-usuario'}`}
                    >
                      {usuario.rol || 'usuario'}
                    </span>
                  </td>
                  <td>
                    <button 
                      className="btn btn-sm btn-success btn-action"
                      onClick={() => editarUsuario(usuario.correo)}
                    >
                      Editar
                    </button>
                    <button 
                      className="btn btn-sm btn-danger btn-action"
                      onClick={() => confirmarEliminar(usuario.correo)}
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

      {usuariosFiltrados.length === 0 && usuarios.length > 0 && (
        <div className="text-center py-4">
          <p className="text-secondary">No se encontraron usuarios con "{busqueda}"</p>
        </div>
      )}

      <ModalConfirmacion
        mostrar={mostrarModal}
        titulo="Eliminar Usuario"
        mensaje={`¿Estás seguro de que deseas eliminar el usuario ${usuarioAEliminar}? Esta acción no se puede deshacer.`}
        onConfirmar={eliminarUsuario}
        onCancelar={cancelarEliminar}
      />
    </main>
  );
}
