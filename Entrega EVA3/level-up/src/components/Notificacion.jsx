import React, { useState, useEffect } from 'react';
import '../styles/Notificacion.css';

export default function NotificacionContainer() {
  const [notificaciones, setNotificaciones] = useState([]);

  useEffect(() => {
    window.notificar = (mensaje, tipo = 'info', duracion = 3000) => {
      const id = Date.now();
      setNotificaciones(prev => [...prev, { id, mensaje, tipo }]);
      
      if (duracion > 0) {
        setTimeout(() => {
          setNotificaciones(prev => prev.filter(n => n.id !== id));
        }, duracion);
      }
    };

    return () => {
      window.notificar = null;
    };
  }, []);

  const cerrarNotificacion = (id) => {
    setNotificaciones(prev => prev.filter(n => n.id !== id));
  };

  return (
    <div className="notificacion-container">
      {notificaciones.map(noti => (
        <div
          key={noti.id}
          className={`notificacion-item ${noti.tipo}`}
        >
          <span className="notificacion-mensaje">{noti.mensaje}</span>
          <button
            onClick={() => cerrarNotificacion(noti.id)}
            className="notificacion-btn-cerrar"
          >
            OK
          </button>
        </div>
      ))}
    </div>
  );
}
