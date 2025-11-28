export const inicializarDatos = () => {
  const usuarios = localStorage.getItem('usuarios');
  const productos = localStorage.getItem('productos');

  if (!usuarios || JSON.parse(usuarios).length === 0) {
    const usuariosIniciales = [
      {
        run: '12345678-9',
        nombre: 'Admin',
        apellidos: 'Level Up',
        correo: 'admin@levelup.cl',
        password: 'admin123',
        fechaNac: '1990-01-01',
        rol: 'admin'
      },
      {
        run: '98765432-1',
        nombre: 'Usuario',
        apellidos: 'Demo',
        correo: 'usuario@levelup.cl',
        password: 'user123',
        fechaNac: '1995-05-15',
        rol: 'usuario'
      }
    ];
    localStorage.setItem('usuarios', JSON.stringify(usuariosIniciales));
  }

  if (!productos || JSON.parse(productos).length === 0) {
    const productosIniciales = [
      {
        id: "JM001",
        codigo: "JM001",
        categoria: "Juegos de Mesa",
        nombre: "Catan",
        precio: 29990,
        stock: 10,
        descripcion: "Juego clásico de estrategia para construir y colonizar.",
        imagen: "/assets/imgs/destacado1.png"
      },
      {
        id: "AC001",
        codigo: "AC001",
        categoria: "Accesorios",
        nombre: "Control Xbox Series X",
        precio: 59990,
        stock: 15,
        descripcion: "Control inalámbrico de última generación para Xbox.",
        imagen: "/assets/imgs/destacado2.png"
      },
      {
        id: "CO001",
        codigo: "CO001",
        categoria: "Consolas",
        nombre: "PlayStation 5",
        precio: 549990,
        stock: 5,
        descripcion: "Consola de última generación con tecnología de punta.",
        imagen: "/assets/imgs/destacado3.png"
      }
    ];
    localStorage.setItem('productos', JSON.stringify(productosIniciales));
  }
};
