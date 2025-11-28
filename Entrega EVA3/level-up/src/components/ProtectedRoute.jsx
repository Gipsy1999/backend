import React from 'react';
import { Navigate } from 'react-router-dom';

export default function ProtectedRoute({ children, allowedRoles = [] }) {
  const usuarioActual = JSON.parse(localStorage.getItem('usuarioActual') || 'null');
  
  // Si no hay usuario, redirigir al login
  if (!usuarioActual) {
    return <Navigate to="/login" replace />;
  }

  // Si no se especifican roles, solo verificar que esté autenticado
  if (allowedRoles.length === 0) {
    return children;
  }

  // Verificar si el usuario tiene uno de los roles permitidos
  const tienePermiso = allowedRoles.includes(usuarioActual.rol);

  if (!tienePermiso) {
    return <Navigate to="/" replace />;
  }

  return children;
}
