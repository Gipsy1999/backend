import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { registrarLogUsuario, registrarLogAdmin } from '../utils/logManager';
import '../styles/Login.css';

export default function Login() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const validarFormulario = () => {
    if (!formData.email || formData.email.trim().length === 0) {
      if (window.notificar) {
        window.notificar('El correo es obligatorio', 'error', 3000);
      }
      return false;
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      if (window.notificar) {
        window.notificar('Debes ingresar un correo válido', 'error', 3000);
      }
      return false;
    }

    if (!formData.password || formData.password.trim().length === 0) {
      if (window.notificar) {
        window.notificar('La contraseña es obligatoria', 'error', 3000);
      }
      return false;
    }

    return true;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    if (!validarFormulario()) {
      return;
    }

    const usuarios = JSON.parse(localStorage.getItem('usuarios') || '[]');
    const usuario = usuarios.find(u => 
      (u.correo === formData.email || u.email === formData.email) && 
      u.password === formData.password
    );
    
    if (usuario) {
      localStorage.setItem('usuarioActual', JSON.stringify(usuario));
      window.dispatchEvent(new Event('usuarioActualizado'));
      
      if (usuario.rol === 'admin') {
        registrarLogAdmin(`Inició sesión: ${usuario.nombre} ${usuario.apellidos || ''} (${usuario.correo})`);
      } else {
        registrarLogUsuario(`Inició sesión: ${usuario.nombre} ${usuario.apellidos || ''} (${usuario.correo})`);
      }
      
      if (window.notificar) {
        window.notificar(`¡Bienvenido ${usuario.nombre}!`, 'success', 3000);
      }
      
      setTimeout(() => {
        if (usuario.rol === 'admin') {
          navigate('/admin');
        } else if (usuario.rol === 'vendedor') {
          navigate('/vendedor');
        } else {
          navigate('/perfil');
        }
      }, 1000);
    } else {
      if (window.notificar) {
        window.notificar('Credenciales incorrectas. Prueba: admin@levelup.cl / admin123', 'error', 4000);
      }
    }
  };

  return (
    <main className="container">
      <h2 className="section-title">Inicio de sesión</h2>
      <form id="form-login" onSubmit={handleSubmit} noValidate>
        <label htmlFor="login-email">Correo</label>
        <input 
          id="login-email"
          name="email"
          type="email"
          value={formData.email}
          onChange={handleChange}
        />

        <label htmlFor="login-pass">Contraseña</label>
        <input 
          id="login-pass"
          name="password"
          type="password"
          value={formData.password}
          onChange={handleChange}
        />

        <button className="btn btn-success" type="submit">Ingresar</button>
      </form>
    </main>
  );
}
