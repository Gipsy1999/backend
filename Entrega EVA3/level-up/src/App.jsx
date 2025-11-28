import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { CarritoProvider } from './context/CarritoContext';
import ProtectedRoute from './components/ProtectedRoute';
import Header from './components/Header';
import Footer from './components/Footer';
import NotificacionContainer from './components/Notificacion';
import Home from './pages/Home';
import Productos from './pages/Productos';
import Detalle from './pages/Detalle';
import Carrito from './pages/Carrito';
import Nosotros from './pages/Nosotros';
import Contacto from './pages/Contacto';
import Noticias from './pages/Noticias';
import Login from './pages/Login';
import Registro from './pages/Registro';
import AdminHome from './pages/AdminHome';
import AdminProductos from './pages/AdminProductos';
import AdminProductoForm from './pages/AdminProductoForm';
import AdminUsuarios from './pages/AdminUsuarios';
import AdminUsuarioForm from './pages/AdminUsuarioForm';
import AdminDestacados from './pages/AdminDestacados';
import AdminLogs from './pages/AdminLogs';
import MisOrdenes from './pages/MisOrdenes';
import Perfil from './pages/Perfil';
import VendedorHome from './pages/VendedorHome';
import VendedorProductos from './pages/VendedorProductos';
import VendedorProductoForm from './pages/VendedorProductoForm';
import VendedorDestacados from './pages/VendedorDestacados';
import VendedorPerfil from './pages/VendedorPerfil';

function App() {
  return (
    <CarritoProvider>
      <Router>
        <div className="App">
          <NotificacionContainer />
          <Header />
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/productos" element={<Productos />} />
            <Route path="/detalle/:codigo" element={<Detalle />} />
            <Route path="/carrito" element={<Carrito />} />
            <Route path="/nosotros" element={<Nosotros />} />
            <Route path="/contacto" element={<Contacto />} />
            <Route path="/noticias" element={<Noticias />} />
            <Route path="/login" element={<Login />} />
            <Route path="/registro" element={<Registro />} />
            
            {/* Rutas de Usuario */}
            <Route path="/perfil" element={<ProtectedRoute allowedRoles={['usuario']}><Perfil /></ProtectedRoute>} />
            <Route path="/mis-ordenes" element={<ProtectedRoute allowedRoles={['usuario']}><MisOrdenes /></ProtectedRoute>} />
            
            {/* Rutas de Vendedor */}
            <Route path="/vendedor" element={<ProtectedRoute allowedRoles={['vendedor']}><VendedorHome /></ProtectedRoute>} />
            <Route path="/vendedor/productos" element={<ProtectedRoute allowedRoles={['vendedor']}><VendedorProductos /></ProtectedRoute>} />
            <Route path="/vendedor/productos/nuevo" element={<ProtectedRoute allowedRoles={['vendedor']}><VendedorProductoForm /></ProtectedRoute>} />
            <Route path="/vendedor/productos/editar/:codigo" element={<ProtectedRoute allowedRoles={['vendedor']}><VendedorProductoForm /></ProtectedRoute>} />
            <Route path="/vendedor/destacados" element={<ProtectedRoute allowedRoles={['vendedor']}><VendedorDestacados /></ProtectedRoute>} />
            <Route path="/vendedor/perfil" element={<ProtectedRoute allowedRoles={['vendedor']}><VendedorPerfil /></ProtectedRoute>} />
            
            {/* Rutas de Admin */}
            <Route path="/admin" element={<ProtectedRoute allowedRoles={['admin']}><AdminHome /></ProtectedRoute>} />
            <Route path="/admin/logs" element={<ProtectedRoute allowedRoles={['admin']}><AdminLogs /></ProtectedRoute>} />
            <Route path="/admin/productos" element={<ProtectedRoute allowedRoles={['admin']}><AdminProductos /></ProtectedRoute>} />
            <Route path="/admin/productos/nuevo" element={<ProtectedRoute allowedRoles={['admin']}><AdminProductoForm /></ProtectedRoute>} />
            <Route path="/admin/productos/editar/:codigo" element={<ProtectedRoute allowedRoles={['admin']}><AdminProductoForm /></ProtectedRoute>} />
            <Route path="/admin/destacados" element={<ProtectedRoute allowedRoles={['admin']}><AdminDestacados /></ProtectedRoute>} />
            <Route path="/admin/usuarios" element={<ProtectedRoute allowedRoles={['admin']}><AdminUsuarios /></ProtectedRoute>} />
            <Route path="/admin/usuarios/nuevo" element={<ProtectedRoute allowedRoles={['admin']}><AdminUsuarioForm /></ProtectedRoute>} />
            <Route path="/admin/usuarios/editar/:correo" element={<ProtectedRoute allowedRoles={['admin']}><AdminUsuarioForm /></ProtectedRoute>} />
          </Routes>
          <Footer />
        </div>
      </Router>
    </CarritoProvider>
  );
}

export default App;
