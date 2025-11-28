import React from 'react';
import '../styles/ModalConfirmacion.css';

export default function ModalConfirmacion({ mostrar, onConfirmar, onCancelar, mensaje, titulo = "Confirmación" }) {
  if (!mostrar) return null;

  return (
    <div 
      className="modal-overlay" 
      onClick={onCancelar}
    >
      <div 
        className="modal-content"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="modal-icono-container">
          <img 
            src="/assets/icons/icono.png" 
            alt="Level Up" 
            width="80" 
            height="80"
            className="modal-icono"
          />
        </div>
        
        <h3 className="modal-titulo">
          {titulo}
        </h3>
        
        <p className="modal-mensaje">
          {mensaje}
        </p>
        
        <div className="modal-botones">
          <button 
            className="btn btn-danger px-4 modal-btn-confirmar"
            onClick={onConfirmar}
          >
            Confirmar
          </button>
          <button 
            className="btn btn-secondary px-4"
            onClick={onCancelar}
          >
            Cancelar
          </button>
        </div>
      </div>
    </div>
  );
}
