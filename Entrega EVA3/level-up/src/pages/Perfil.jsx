import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { getUserOrders } from '../services/orderService';
import { registrarLogUsuario } from '../utils/logManager';
import '../styles/Perfil.css';

export default function Perfil() {
  const navigate = useNavigate();
  const [usuario, setUsuario] = useState(null);
  const [editando, setEditando] = useState(false);
  const [ordenes, setOrdenes] = useState([]);
  const [fotoPerfil, setFotoPerfil] = useState(null);
  const [previsualizacionFoto, setPrevisualizacionFoto] = useState(null);
  const [formData, setFormData] = useState({
    nombre: '',
    apellidos: '',
    telefono: '',
    direccion: '',
    ciudad: '',
    password: '',
    newPassword: '',
    confirmPassword: ''
  });

  useEffect(() => {
    const usuarioActual = JSON.parse(localStorage.getItem('usuarioActual') || 'null');
    if (usuarioActual) {
      setUsuario(usuarioActual);
      setPrevisualizacionFoto(usuarioActual.fotoPerfil || null);
      setFormData({
        nombre: usuarioActual.nombre || '',
        apellidos: usuarioActual.apellidos || '',
        telefono: usuarioActual.telefono || '',
        direccion: usuarioActual.direccion || '',
        ciudad: usuarioActual.ciudad || '',
        password: '',
        newPassword: '',
        confirmPassword: ''
      });
      cargarOrdenes();
    }
  }, []);

  const cargarOrdenes = async () => {
    try {
      const data = await getUserOrders();
      setOrdenes(data.slice(0, 5)); // Solo las últimas 5
    } catch (err) {
      console.error('Error al cargar órdenes:', err);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleFotoChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      if (file.size > 5 * 1024 * 1024) {
        if (window.notificar) {
          window.notificar('La imagen no debe superar 5MB', 'error', 3000);
        }
        return;
      }

      const reader = new FileReader();
      reader.onloadend = () => {
        setFotoPerfil(reader.result);
        setPrevisualizacionFoto(reader.result);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    // Validar campos obligatorios
    if (!formData.nombre.trim()) {
      if (window.notificar) {
        window.notificar('El nombre es obligatorio', 'error', 3000);
      }
      return;
    }

    // Si quiere cambiar contraseña
    if (formData.newPassword) {
      if (!formData.password) {
        if (window.notificar) {
          window.notificar('Debes ingresar tu contraseña actual', 'error', 3000);
        }
        return;
      }

      if (formData.password !== usuario.password) {
        if (window.notificar) {
          window.notificar('La contraseña actual es incorrecta', 'error', 3000);
        }
        return;
      }

      if (formData.newPassword.length < 6) {
        if (window.notificar) {
          window.notificar('La nueva contraseña debe tener al menos 6 caracteres', 'error', 3000);
        }
        return;
      }

      if (formData.newPassword !== formData.confirmPassword) {
        if (window.notificar) {
          window.notificar('Las contraseñas no coinciden', 'error', 3000);
        }
        return;
      }
    }

    // Actualizar usuario
    const usuarios = JSON.parse(localStorage.getItem('usuarios') || '[]');
    const index = usuarios.findIndex(u => u.correo === usuario.correo);
    
    if (index !== -1) {
      const usuarioActualizado = {
        ...usuarios[index],
        nombre: formData.nombre,
        apellidos: formData.apellidos,
        telefono: formData.telefono,
        direccion: formData.direccion,
        ciudad: formData.ciudad,
        ...(fotoPerfil && { fotoPerfil: fotoPerfil }),
        ...(formData.newPassword && { password: formData.newPassword })
      };

      usuarios[index] = usuarioActualizado;
      localStorage.setItem('usuarios', JSON.stringify(usuarios));
      localStorage.setItem('usuarioActual', JSON.stringify(usuarioActualizado));
      setUsuario(usuarioActualizado);
      setFotoPerfil(null);
      
      registrarLogUsuario(`Actualizó su perfil: ${usuarioActualizado.nombre} ${usuarioActualizado.apellidos}`);

      if (window.notificar) {
        window.notificar('Perfil actualizado exitosamente', 'success', 3000);
      }

      setEditando(false);
      setFormData(prev => ({
        ...prev,
        password: '',
        newPassword: '',
        confirmPassword: ''
      }));
    }
  };

  const handleCerrarSesion = () => {
    localStorage.removeItem('usuarioActual');
    window.dispatchEvent(new Event('usuarioActualizado'));
    if (window.notificar) {
      window.notificar('Sesión cerrada exitosamente', 'success', 3000);
    }
    navigate('/login');
  };

  const formatearFecha = (fecha) => {
    return new Date(fecha).toLocaleDateString('es-CL', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
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

  if (!usuario) {
    return (
      <main className="container perfil-page">
        <p>Cargando...</p>
      </main>
    );
  }

  return (
    <main className="container perfil-page">
      <div className="perfil-header mb-4">
        <div>
          <h2 className="section-title mb-2">Mi Perfil</h2>
          <h4 className="text-white">Bienvenido, {usuario.nombre} {usuario.apellidos}</h4>
        </div>
        <button className="btn btn-danger" onClick={handleCerrarSesion}>
          Cerrar Sesión
        </button>
      </div>

      <div className="row">
        {/* Columna de Foto de Perfil */}
        <div className="col-md-4 mb-4">
          <div className="usuario-perfil-card text-center">
            <div className="usuario-card-header">
              <h4>Foto de Perfil</h4>
            </div>
            <div className="perfil-foto-container">
              <div className="perfil-foto-circular">
                <img 
                  src={previsualizacionFoto || '/assets/icons/icono.png'} 
                  alt="Foto de perfil"
                  className="perfil-foto-img"
                />
              </div>
              {editando && (
                <div className="mt-3">
                  <label htmlFor="foto-upload-usuario" className="btn btn-success btn-sm">
                    Cambiar Foto
                  </label>
                  <input
                    id="foto-upload-usuario"
                    type="file"
                    accept="image/*"
                    onChange={handleFotoChange}
                    style={{ display: 'none' }}
                  />
                  <p className="text-muted small mt-2">Máx. 5MB</p>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Información del perfil */}
        <div className="col-md-8">
          <div className="usuario-perfil-card">
            <div className="usuario-card-header">
              <h4>Información Personal</h4>
              {!editando && (
                <button 
                  className="btn btn-sm btn-primary"
                  onClick={() => setEditando(true)}
                >
                  Editar
                </button>
              )}
            </div>

            {editando ? (
              <form onSubmit={handleSubmit}>
                <div className="mb-3">
                  <label className="usuario-label">Nombre *</label>
                  <input
                    type="text"
                    className="usuario-input"
                    name="nombre"
                    value={formData.nombre}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label className="usuario-label">Apellidos</label>
                  <input
                    type="text"
                    className="usuario-input"
                    name="apellidos"
                    value={formData.apellidos}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label className="usuario-label">Teléfono</label>
                  <input
                    type="tel"
                    className="usuario-input"
                    name="telefono"
                    value={formData.telefono}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label className="usuario-label">Dirección</label>
                  <input
                    type="text"
                    className="usuario-input"
                    name="direccion"
                    value={formData.direccion}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label className="usuario-label">Ciudad</label>
                  <input
                    type="text"
                    className="usuario-input"
                    name="ciudad"
                    value={formData.ciudad}
                    onChange={handleChange}
                  />
                </div>

                <hr className="usuario-divider my-4" />
                <h5 className="mb-3 usuario-subtitle">Cambiar Contraseña</h5>

                <div className="mb-3">
                  <label className="usuario-label">Contraseña Actual</label>
                  <input
                    type="password"
                    className="usuario-input"
                    name="password"
                    value={formData.password}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label className="usuario-label">Nueva Contraseña</label>
                  <input
                    type="password"
                    className="usuario-input"
                    name="newPassword"
                    value={formData.newPassword}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label className="usuario-label">Confirmar Nueva Contraseña</label>
                  <input
                    type="password"
                    className="usuario-input"
                    name="confirmPassword"
                    value={formData.confirmPassword}
                    onChange={handleChange}
                  />
                </div>

                <div className="d-flex gap-2">
                  <button type="submit" className="btn btn-success">
                    Guardar Cambios
                  </button>
                  <button 
                    type="button" 
                    className="btn btn-secondary"
                    onClick={() => setEditando(false)}
                  >
                    Cancelar
                  </button>
                </div>
              </form>
            ) : (
              <div className="perfil-info">
                <div className="info-item">
                  <strong>Nombre:</strong>
                  <span>{usuario.nombre} {usuario.apellidos}</span>
                </div>
                <div className="info-item">
                  <strong>Email:</strong>
                  <span>{usuario.correo || usuario.email}</span>
                </div>
                <div className="info-item">
                  <strong>Teléfono:</strong>
                  <span>{usuario.telefono || 'No registrado'}</span>
                </div>
                <div className="info-item">
                  <strong>Dirección:</strong>
                  <span>{usuario.direccion || 'No registrada'}</span>
                </div>
                <div className="info-item">
                  <strong>Ciudad:</strong>
                  <span>{usuario.ciudad || 'No registrada'}</span>
                </div>
                <div className="info-item">
                  <strong>Rol:</strong>
                  <span className={`badge ${usuario.rol === 'vendedor' ? 'bg-warning text-dark' : 'bg-info'}`}>{usuario.rol}</span>
                </div>
              </div>
            )}
          </div>

        </div>

        {/* Últimas órdenes */}
        <div className="col-md-12 mt-4">
          <div className="usuario-perfil-card">
            <div className="usuario-card-header">
              <h4>Mis Últimas Órdenes</h4>
              <Link to="/mis-ordenes" className="btn btn-sm btn-primary">
                Ver Todas
              </Link>
            </div>

            {ordenes.length === 0 ? (
              <p className="text-muted text-center py-4">No tienes órdenes todavía</p>
            ) : (
              <div className="ordenes-recientes">
                {ordenes.map(orden => {
                  const badge = obtenerEstadoBadge(orden.status);
                  return (
                    <div key={orden.id} className="orden-item-small">
                      <div className="orden-item-header">
                        <span className="orden-id-small">#{orden.id}</span>
                        <span className={`badge ${badge.class}`}>{badge.text}</span>
                      </div>
                      <div className="orden-item-body">
                        <small className="text-muted">
                          {formatearFecha(orden.createdAt)}
                        </small>
                        <strong className="orden-total-small">
                          ${orden.totalAmount.toLocaleString('es-CL')}
                        </strong>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>
      </div>
    </main>
  );
}
