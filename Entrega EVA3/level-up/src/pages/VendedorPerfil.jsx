import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { registrarLogAdmin } from '../utils/logManager';
import '../styles/Perfil.css';

export default function VendedorPerfil() {
  const navigate = useNavigate();
  const [usuario, setUsuario] = useState(null);
  const [editando, setEditando] = useState(false);
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
    }
  }, []);

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

    if (!formData.nombre.trim()) {
      if (window.notificar) {
        window.notificar('El nombre es obligatorio', 'error', 3000);
      }
      return;
    }

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
      
      registrarLogAdmin(`Vendedor actualizó su perfil: ${usuarioActualizado.nombre} ${usuarioActualizado.apellidos}`);

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
        <h2 className="section-title">Mi Perfil - Vendedor</h2>
        <div className="d-flex gap-2">
          <Link to="/vendedor" className="btn btn-secondary">
            ← Panel
          </Link>
          <button className="btn btn-danger" onClick={handleCerrarSesion}>
            Cerrar Sesión
          </button>
        </div>
      </div>

      <div className="row">
        {/* Columna de Foto de Perfil */}
        <div className="col-md-4 mb-4">
          <div className="perfil-card perfil-foto-card-vendedor text-center">
            <div className="perfil-card-header">
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
                  <label htmlFor="foto-upload" className="btn btn-success btn-sm">
                    Cambiar Foto
                  </label>
                  <input
                    id="foto-upload"
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

        {/* Columna de Información */}
        <div className="col-md-8">
          <div className="perfil-card vendedor-perfil-card">
            <div className="perfil-card-header">
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
                  <label className="form-label vendedor-label">Nombre *</label>
                  <input
                    type="text"
                    className="form-control vendedor-input"
                    name="nombre"
                    value={formData.nombre}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label className="form-label vendedor-label">Apellidos</label>
                  <input
                    type="text"
                    className="form-control vendedor-input"
                    name="apellidos"
                    value={formData.apellidos}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label className="form-label vendedor-label">Teléfono</label>
                  <input
                    type="tel"
                    className="form-control vendedor-input"
                    name="telefono"
                    value={formData.telefono}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label className="form-label vendedor-label">Dirección</label>
                  <input
                    type="text"
                    className="form-control vendedor-input"
                    name="direccion"
                    value={formData.direccion}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label className="form-label vendedor-label">Ciudad</label>
                  <input
                    type="text"
                    className="form-control vendedor-input"
                    name="ciudad"
                    value={formData.ciudad}
                    onChange={handleChange}
                  />
                </div>

                <hr className="my-4 vendedor-divider" />
                <h5 className="mb-3 vendedor-subtitle">Cambiar Contraseña</h5>

                <div className="mb-3">
                  <label className="form-label vendedor-label">Contraseña Actual</label>
                  <input
                    type="password"
                    className="form-control vendedor-input"
                    name="password"
                    value={formData.password}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label className="form-label vendedor-label">Nueva Contraseña</label>
                  <input
                    type="password"
                    className="form-control vendedor-input"
                    name="newPassword"
                    value={formData.newPassword}
                    onChange={handleChange}
                  />
                </div>

                <div className="mb-3">
                  <label className="form-label vendedor-label">Confirmar Nueva Contraseña</label>
                  <input
                    type="password"
                    className="form-control vendedor-input"
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
                  <span className="badge bg-warning text-dark">{usuario.rol}</span>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </main>
  );
}
