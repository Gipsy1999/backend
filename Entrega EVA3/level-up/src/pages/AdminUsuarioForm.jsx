import React, { useState, useEffect } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { registrarLogAdmin } from '../utils/logManager';
import '../styles/Admin.css';

export default function AdminUsuarioForm() {
  const { correo } = useParams();
  const navigate = useNavigate();
  const esEdicion = !!correo;

  const [formData, setFormData] = useState({
    run: '',
    nombre: '',
    apellidos: '',
    correo: '',
    password: '',
    fechaNac: '',
    rol: 'usuario'
  });

  useEffect(() => {
    if (esEdicion) {
      const usuarios = JSON.parse(localStorage.getItem('usuarios') || '[]');
      const usuario = usuarios.find(u => u.correo === decodeURIComponent(correo));
      if (usuario) {
        setFormData(usuario);
      } else {
        if (window.notificar) {
          window.notificar('Usuario no encontrado', 'error', 3000);
        }
        navigate('/admin/usuarios');
      }
    }
  }, [correo, esEdicion, navigate]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    if (!formData.correo || !formData.nombre) {
      if (window.notificar) {
        window.notificar('Por favor completa todos los campos obligatorios', 'error', 3000);
      }
      return;
    }

    if (!esEdicion && !formData.password) {
      if (window.notificar) {
        window.notificar('La contraseña es obligatoria para nuevos usuarios', 'error', 3000);
      }
      return;
    }

    const usuarios = JSON.parse(localStorage.getItem('usuarios') || '[]');

    if (esEdicion) {
      const index = usuarios.findIndex(u => u.correo === decodeURIComponent(correo));
      if (index !== -1) {
        usuarios[index] = {
          ...formData,
          password: formData.password || usuarios[index].password
        };
        localStorage.setItem('usuarios', JSON.stringify(usuarios));
        
        registrarLogAdmin(`Editó usuario: ${formData.nombre} ${formData.apellidos} (${formData.correo})`);
        
        if (window.notificar) {
          window.notificar('Usuario actualizado exitosamente', 'success', 3000);
        }
        navigate('/admin/usuarios');
      }
    } else {
      if (usuarios.some(u => u.correo === formData.correo)) {
        if (window.notificar) {
          window.notificar('Ya existe un usuario con ese correo', 'error', 3000);
        }
        return;
      }

      usuarios.push(formData);
      localStorage.setItem('usuarios', JSON.stringify(usuarios));
      
      registrarLogAdmin(`Creó usuario: ${formData.nombre} ${formData.apellidos} (${formData.correo})`);
      
      if (window.notificar) {
        window.notificar('Usuario creado exitosamente', 'success', 3000);
      }
      navigate('/admin/usuarios');
    }
  };

  return (
    <main className="container admin-page">
      <div className="mb-4">
        <h2 className="section-title mb-2">
          {esEdicion ? 'Editar Usuario' : 'Nuevo Usuario'}
        </h2>
        <Link to="/admin/usuarios" className="text-secondary">
          ← Volver a Usuarios
        </Link>
      </div>

      <form onSubmit={handleSubmit} className="admin-form">
        <div className="row">
          <div className="col-md-6 mb-3">
            <label htmlFor="run" className="form-label">RUN</label>
            <input
              type="text"
              className="form-control"
              id="run"
              name="run"
              value={formData.run}
              onChange={handleChange}
              placeholder="12345678-9"
            />
          </div>

          <div className="col-md-6 mb-3">
            <label htmlFor="correo" className="form-label">Correo Electrónico *</label>
            <input
              type="email"
              className="form-control"
              id="correo"
              name="correo"
              value={formData.correo}
              onChange={handleChange}
              disabled={esEdicion}
              required
            />
          </div>

          <div className="col-md-6 mb-3">
            <label htmlFor="nombre" className="form-label">Nombre *</label>
            <input
              type="text"
              className="form-control"
              id="nombre"
              name="nombre"
              value={formData.nombre}
              onChange={handleChange}
              required
            />
          </div>

          <div className="col-md-6 mb-3">
            <label htmlFor="apellidos" className="form-label">Apellidos</label>
            <input
              type="text"
              className="form-control"
              id="apellidos"
              name="apellidos"
              value={formData.apellidos}
              onChange={handleChange}
            />
          </div>

          <div className="col-md-6 mb-3">
            <label htmlFor="password" className="form-label">
              Contraseña {!esEdicion && '*'}
              {esEdicion && <small className="text-muted"> (dejar vacío para mantener)</small>}
            </label>
            <input
              type="password"
              className="form-control"
              id="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              required={!esEdicion}
            />
          </div>

          <div className="col-md-6 mb-3">
            <label htmlFor="fechaNac" className="form-label">Fecha de Nacimiento</label>
            <input
              type="date"
              className="form-control"
              id="fechaNac"
              name="fechaNac"
              value={formData.fechaNac}
              onChange={handleChange}
            />
          </div>

          <div className="col-md-6 mb-3">
            <label htmlFor="rol" className="form-label">Rol *</label>
            <select
              className="form-select"
              id="rol"
              name="rol"
              value={formData.rol}
              onChange={handleChange}
              required
            >
              <option value="usuario">Usuario</option>
              <option value="vendedor">Vendedor</option>
              <option value="admin">Administrador</option>
            </select>
          </div>
        </div>

        <div className="d-flex gap-3 mt-4 justify-content-center">
          <button 
            type="submit" 
            className="btn btn-success px-5"
          >
            {esEdicion ? 'Actualizar Usuario' : 'Crear Usuario'}
          </button>
          <Link 
            to="/admin/usuarios" 
            className="btn btn-secondary px-5"
          >
            Cancelar
          </Link>
        </div>
      </form>
    </main>
  );
}
