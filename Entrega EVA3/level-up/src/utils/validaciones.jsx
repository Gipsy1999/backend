export const validarEmailVacio = (email) => {
  return !email || email.trim().length === 0 ? false : true;
};

export const validarFormatoEmail = (email) => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
};

export const validarPasswordVacio = (password) => {
  return !password || password.trim().length === 0 ? false : true;
};

export const validarCredenciales = (credentials) => {
  const usuarios = JSON.parse(localStorage.getItem('usuarios') || '[]');
  return usuarios.some(u => 
    (u.correo === credentials.email || u.email === credentials.email) && 
    u.password === credentials.password
  );
};

export const validarRUN = (run) => {
  return run && run.length >= 7 && run.length <= 9;
};

export const validarNombreLength = (nombre) => {
  return nombre && nombre.length <= 50;
};

export const validarApellidosLength = (apellidos) => {
  return apellidos && apellidos.length <= 100;
};

export const validarEmailDuplicado = (email) => {
  const usuarios = JSON.parse(localStorage.getItem('usuarios') || '[]');
  return !usuarios.some(u => u.correo === email);
};

export const validarStock = (producto, cantidad) => {
  return producto.stock >= cantidad;
};

export const agregarProductoAlCarrito = (producto, cantidad) => {
  if (!validarStock(producto, cantidad)) return false;
  
  const carrito = JSON.parse(localStorage.getItem('carrito') || '[]');
  carrito.push({
    ...producto,
    cantidad
  });
  localStorage.setItem('carrito', JSON.stringify(carrito));
  return true;
};