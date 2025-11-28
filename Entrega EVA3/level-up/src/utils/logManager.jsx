const generarIdInvitado = () => {
  let idInvitado = localStorage.getItem('idInvitado');
  
  if (!idInvitado) {
    idInvitado = 'INV-' + Math.random().toString(36).substr(2, 9).toUpperCase();
    localStorage.setItem('idInvitado', idInvitado);
  }
  
  return idInvitado;
};

export const registrarLog = (tipo, accion, usuario = null) => {
  const logs = JSON.parse(localStorage.getItem('logs') || '[]');
  
  let nombreUsuario = usuario;
  
  if (!nombreUsuario) {
    const usuarioActual = JSON.parse(localStorage.getItem('usuarioActual') || 'null');
    if (usuarioActual) {
      nombreUsuario = usuarioActual.nombre || usuarioActual.correo;
    } else {
      nombreUsuario = generarIdInvitado();
    }
  }
  
  const nuevoLog = {
    tipo: tipo,
    fecha: new Date().toISOString(),
    usuario: nombreUsuario,
    accion: accion
  };
  
  logs.push(nuevoLog);
  
  if (logs.length > 500) {
    logs.shift();
  }
  
  localStorage.setItem('logs', JSON.stringify(logs));
  window.dispatchEvent(new Event('logsActualizados'));
};

export const registrarLogAdmin = (accion) => {
  const usuarioActual = JSON.parse(localStorage.getItem('usuarioActual') || 'null');
  const nombreAdmin = usuarioActual ? usuarioActual.nombre || usuarioActual.correo : 'Admin';
  registrarLog('admin', accion, nombreAdmin);
};

export const registrarLogUsuario = (accion) => {
  registrarLog('usuario', accion);
};
