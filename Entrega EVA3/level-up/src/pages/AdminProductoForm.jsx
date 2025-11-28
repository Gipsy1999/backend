import React, { useState, useEffect } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { registrarLogAdmin } from '../utils/logManager';
import { uploadFile, validateFile, getFileUrl } from '../services/fileService';
import '../styles/Admin.css';

export default function AdminProductoForm() {
  const { codigo } = useParams();
  const navigate = useNavigate();
  const esEdicion = !!codigo;

  const [formData, setFormData] = useState({
    codigo: '',
    nombre: '',
    categoria: 'Juegos de Mesa',
    precio: '',
    stock: '',
    descripcion: '',
    imagen: ''
  });
  const [uploadingImage, setUploadingImage] = useState(false);

  useEffect(() => {
    if (esEdicion) {
      const productos = JSON.parse(localStorage.getItem('productos') || '[]');
      const producto = productos.find(p => p.codigo === codigo);
      if (producto) {
        setFormData(producto);
      } else {
        if (window.notificar) {
          window.notificar('Producto no encontrado', 'error', 3000);
        }
        navigate('/admin/productos');
      }
    }
  }, [codigo, esEdicion, navigate]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleImageChange = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    // Validar archivo
    const validation = validateFile(file);
    if (!validation.valid) {
      if (window.notificar) {
        window.notificar(validation.error, 'error', 3000);
      }
      return;
    }

    setUploadingImage(true);

    try {
      // Subir archivo al File Service
      const result = await uploadFile(file, 'productos');
      
      // Actualizar formData con la URL del archivo subido
      setFormData(prev => ({
        ...prev,
        imagen: result.fileUrl || result.filename
      }));

      if (window.notificar) {
        window.notificar('Imagen subida exitosamente', 'success', 2000);
      }
    } catch (error) {
      console.error('Error al subir imagen:', error);
      if (window.notificar) {
        window.notificar('Error al subir la imagen. Intenta nuevamente.', 'error', 3000);
      }
      
      // Fallback: usar base64 local si falla el upload
      const reader = new FileReader();
      reader.onloadend = () => {
        setFormData(prev => ({
          ...prev,
          imagen: reader.result
        }));
      };
      reader.readAsDataURL(file);
    } finally {
      setUploadingImage(false);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    if (!formData.codigo.trim() || !formData.nombre.trim() || !formData.precio || !formData.stock || !formData.descripcion.trim() || !formData.imagen.trim()) {
      if (window.notificar) {
        window.notificar('Por favor completa todos los campos obligatorios', 'error', 3000);
      }
      return;
    }

    const precio = parseFloat(formData.precio);
    if (precio >= 10000000) {
      if (window.notificar) {
        window.notificar('El precio no puede ser mayor o igual a $10.000.000', 'error', 3000);
      }
      return;
    }

    if (precio <= 0) {
      if (window.notificar) {
        window.notificar('El precio debe ser mayor a $0', 'error', 3000);
      }
      return;
    }

    const stock = parseInt(formData.stock);
    if (stock >= 10000000) {
      if (window.notificar) {
        window.notificar('El stock no puede ser mayor o igual a 10.000.000', 'error', 3000);
      }
      return;
    }

    if (stock < 0) {
      if (window.notificar) {
        window.notificar('El stock no puede ser negativo', 'error', 3000);
      }
      return;
    }

    const productos = JSON.parse(localStorage.getItem('productos') || '[]');

    if (esEdicion) {
      const index = productos.findIndex(p => p.codigo === codigo);
      if (index !== -1) {
        productos[index] = {
          ...formData,
          precio: parseFloat(formData.precio),
          stock: parseInt(formData.stock),
          fechaModificacion: new Date().toISOString(),
          fechaCreacion: productos[index].fechaCreacion || new Date().toISOString()
        };
        localStorage.setItem('productos', JSON.stringify(productos));
        window.dispatchEvent(new Event('storage'));
        registrarLogAdmin(`Editó producto: ${formData.nombre} (${formData.codigo})`);
        if (window.notificar) {
          window.notificar('Producto actualizado exitosamente', 'success', 3000);
        }
        navigate('/admin/productos');
      }
    } else {
      if (productos.some(p => p.codigo === formData.codigo)) {
        if (window.notificar) {
          window.notificar('Ya existe un producto con ese código', 'error', 3000);
        }
        return;
      }

      const fechaActual = new Date().toISOString();
      productos.push({
        ...formData,
        id: formData.codigo,
        precio: parseFloat(formData.precio),
        stock: parseInt(formData.stock),
        fechaCreacion: fechaActual,
        fechaModificacion: fechaActual
      });
      localStorage.setItem('productos', JSON.stringify(productos));
      window.dispatchEvent(new Event('storage'));
      registrarLogAdmin(`Creó producto: ${formData.nombre} (${formData.codigo})`);
      if (window.notificar) {
        window.notificar('Producto creado exitosamente', 'success', 3000);
      }
      navigate('/admin/productos');
    }
  };

  return (
    <main className="container admin-page">
      <div className="mb-4">
        <h2 className="section-title mb-2">
          {esEdicion ? 'Editar Producto' : 'Nuevo Producto'}
        </h2>
        <Link to="/admin/productos" className="text-secondary">
          ← Volver a Productos
        </Link>
      </div>

      <form onSubmit={handleSubmit} className="admin-form">
        <div className="row">
          <div className="col-md-6 mb-3">
            <label htmlFor="codigo" className="form-label">Código *</label>
            <input
              type="text"
              className="form-control"
              id="codigo"
              name="codigo"
              value={formData.codigo}
              onChange={handleChange}
              disabled={esEdicion}
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
            />
          </div>

          <div className="col-md-6 mb-3">
            <label htmlFor="categoria" className="form-label">Categoría *</label>
            <select
              className="form-select"
              id="categoria"
              name="categoria"
              value={formData.categoria}
              onChange={handleChange}
            >
              <option value="Juegos de Mesa">Juegos de Mesa</option>
              <option value="Accesorios">Accesorios</option>
              <option value="Consolas">Consolas</option>
              <option value="Videojuegos">Videojuegos</option>
              <option value="Figuras">Figuras</option>
              <option value="Otros">Otros</option>
            </select>
          </div>

          <div className="col-md-3 mb-3">
            <label htmlFor="precio" className="form-label">Precio *</label>
            <input
              type="number"
              className="form-control"
              id="precio"
              name="precio"
              value={formData.precio}
              onChange={handleChange}
              min="1"
              max="9999999"
              step="1"
            />
          </div>

          <div className="col-md-3 mb-3">
            <label htmlFor="stock" className="form-label">Stock *</label>
            <input
              type="number"
              className="form-control"
              id="stock"
              name="stock"
              value={formData.stock}
              onChange={handleChange}
              min="0"
              max="9999999"
            />
          </div>

          <div className="col-12 mb-3">
            <label htmlFor="descripcion" className="form-label">Descripción *</label>
            <textarea
              className="form-control"
              id="descripcion"
              name="descripcion"
              value={formData.descripcion}
              onChange={handleChange}
              rows="3"
            ></textarea>
          </div>

          <div className="col-12 mb-3">
            <label htmlFor="imagen" className="form-label">Imagen del Producto *</label>
            <div className="mb-2">
              <label 
                htmlFor="imagenFile" 
                className={`btn btn-success w-100 admin-form-imagen-label ${uploadingImage ? 'disabled' : ''}`}
              >
                {uploadingImage ? '⏳ Subiendo imagen...' : '📁 Seleccionar Imagen desde el Computador'}
              </label>
              <input
                type="file"
                className="form-control admin-form-imagen-input-hidden"
                id="imagenFile"
                accept="image/*"
                onChange={handleImageChange}
                disabled={uploadingImage}
              />
              <small className="admin-form-imagen-info">Formatos: JPG, PNG, GIF, WEBP. Máximo 5MB</small>
            </div>
            <div className="mb-2 admin-form-url-label">O ingresa una URL:</div>
            <input
              type="text"
              className="form-control"
              id="imagen"
              name="imagen"
              value={formData.imagen}
              onChange={handleChange}
              placeholder="/assets/imgs/producto.png o https://ejemplo.com/imagen.jpg"
              disabled={uploadingImage}
            />
            {formData.imagen && (
              <div className="mt-3 text-center">
                <p className="text-white mb-2">Vista previa:</p>
                <img 
                  src={getFileUrl(formData.imagen)} 
                  alt="Preview"
                  className="admin-form-preview-img"
                  onError={(e) => {
                    e.target.src = '/assets/icons/icono.png';
                  }}
                />
              </div>
            )}
          </div>
        </div>

        <div className="d-flex gap-3 mt-4 justify-content-center">
          <button 
            type="submit" 
            className="btn btn-success px-5"
            disabled={uploadingImage}
          >
            {uploadingImage ? 'Esperando imagen...' : (esEdicion ? 'Actualizar Producto' : 'Crear Producto')}
          </button>
          <Link 
            to="/admin/productos" 
            className="btn btn-secondary px-5"
          >
            Cancelar
          </Link>
        </div>
      </form>
    </main>
  );
}
