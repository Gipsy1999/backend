import React, { useState } from 'react';
import { registrarLogUsuario } from '../utils/logManager';
import '../styles/Contacto.css';

export default function Contacto() {
  const [formData, setFormData] = useState({
    nombre: '',
    correo: '',
    comentario: ''
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const validarFormulario = () => {
    if (!formData.nombre || formData.nombre.trim().length === 0) {
      if (window.notificar) {
        window.notificar('El nombre es obligatorio', 'error', 3000);
      }
      return false;
    }

    if (formData.nombre.length > 100) {
      if (window.notificar) {
        window.notificar('El nombre debe tener máximo 100 caracteres', 'error', 3000);
      }
      return false;
    }

    if (!formData.correo || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.correo)) {
      if (window.notificar) {
        window.notificar('Debes ingresar un correo válido', 'error', 3000);
      }
      return false;
    }

    if (!formData.comentario || formData.comentario.trim().length === 0) {
      if (window.notificar) {
        window.notificar('El comentario es obligatorio', 'error', 3000);
      }
      return false;
    }

    if (formData.comentario.length > 500) {
      if (window.notificar) {
        window.notificar('El comentario debe tener máximo 500 caracteres', 'error', 3000);
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

    registrarLogUsuario(`Envió mensaje de contacto: "${formData.comentario.substring(0, 50)}${formData.comentario.length > 50 ? '...' : ''}" - Email: ${formData.correo}`);

    if (window.notificar) {
      window.notificar(`¡Gracias ${formData.nombre}, tu mensaje ha sido enviado!`, 'success', 3000);
    }
    setFormData({ nombre: '', correo: '', comentario: '' });
  };

  return (
    <main className="container">
      <h2 className="section-title">Contacto</h2>
      <form id="form-contacto" onSubmit={handleSubmit} noValidate>
        <label htmlFor="ct-nombre">Nombre</label>
        <input 
          id="ct-nombre" 
          name="nombre"
          value={formData.nombre}
          onChange={handleChange}
        />

        <label htmlFor="ct-correo">Correo</label>
        <input 
          id="ct-correo" 
          name="correo"
          type="email"
          value={formData.correo}
          onChange={handleChange}
        />

        <label htmlFor="ct-comentario">Comentario</label>
        <textarea 
          id="ct-comentario" 
          name="comentario"
          value={formData.comentario}
          onChange={handleChange}
        />

        <button className="btn btn-success" type="submit">Enviar</button>
      </form>
    </main>
  );
}
