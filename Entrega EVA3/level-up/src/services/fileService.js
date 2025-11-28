// Servicio para interactuar con File Service (Puerto 8087)
const API_BASE_URL = process.env.REACT_APP_API_GATEWAY_URL || 'http://localhost:8080';
const FILE_SERVICE_URL = `${API_BASE_URL}/files`;

/**
 * Sube un archivo al servidor
 * @param {File} file - Archivo a subir
 * @param {string} category - Categoría del archivo (productos, usuarios, documentos)
 * @returns {Promise<Object>} Información del archivo subido
 */
export const uploadFile = async (file, category = 'productos') => {
  try {
    const token = localStorage.getItem('token');
    const formData = new FormData();
    formData.append('file', file);

    const response = await fetch(`${FILE_SERVICE_URL}/upload?category=${category}`, {
      method: 'POST',
      headers: {
        'Authorization': token ? `Bearer ${token}` : '',
      },
      body: formData,
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || `Error al subir archivo: ${response.status}`);
    }

    const result = await response.json();
    return result;
  } catch (error) {
    console.error('Error en uploadFile:', error);
    throw error;
  }
};

/**
 * Descarga un archivo del servidor
 * @param {string} filename - Nombre del archivo a descargar
 * @returns {Promise<Blob>} Archivo descargado
 */
export const downloadFile = async (filename) => {
  try {
    const token = localStorage.getItem('token');
    const response = await fetch(`${FILE_SERVICE_URL}/download/${filename}`, {
      method: 'GET',
      headers: {
        'Authorization': token ? `Bearer ${token}` : '',
      },
    });

    if (!response.ok) {
      throw new Error(`Error al descargar archivo: ${response.status}`);
    }

    return await response.blob();
  } catch (error) {
    console.error('Error en downloadFile:', error);
    throw error;
  }
};

/**
 * Obtiene la URL pública de un archivo
 * @param {string} filename - Nombre del archivo
 * @returns {string} URL del archivo
 */
export const getFileUrl = (filename) => {
  if (!filename) return '';
  
  // Si ya es una URL completa, devolverla tal cual
  if (filename.startsWith('http://') || filename.startsWith('https://') || filename.startsWith('data:')) {
    return filename;
  }
  
  // Si es una ruta local, devolverla tal cual
  if (filename.startsWith('/assets/') || filename.startsWith('./assets/')) {
    return filename;
  }
  
  // Si es un nombre de archivo del File Service
  return `${FILE_SERVICE_URL}/view/${filename}`;
};

/**
 * Elimina un archivo del servidor
 * @param {string} filename - Nombre del archivo a eliminar
 * @returns {Promise<Object>} Resultado de la eliminación
 */
export const deleteFile = async (filename) => {
  try {
    const token = localStorage.getItem('token');
    const response = await fetch(`${FILE_SERVICE_URL}/delete/${filename}`, {
      method: 'DELETE',
      headers: {
        'Authorization': token ? `Bearer ${token}` : '',
      },
    });

    if (!response.ok) {
      throw new Error(`Error al eliminar archivo: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('Error en deleteFile:', error);
    throw error;
  }
};

/**
 * Lista todos los archivos (Admin)
 * @param {string} category - Categoría opcional para filtrar
 * @returns {Promise<Array>} Lista de archivos
 */
export const listFiles = async (category = null) => {
  try {
    const token = localStorage.getItem('token');
    const url = category 
      ? `${FILE_SERVICE_URL}/list?category=${category}` 
      : `${FILE_SERVICE_URL}/list`;
    
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Authorization': token ? `Bearer ${token}` : '',
      },
    });

    if (!response.ok) {
      throw new Error(`Error al listar archivos: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('Error en listFiles:', error);
    throw error;
  }
};

/**
 * Valida un archivo antes de subirlo
 * @param {File} file - Archivo a validar
 * @param {Object} options - Opciones de validación
 * @param {number} options.maxSize - Tamaño máximo en bytes (default: 5MB)
 * @param {Array<string>} options.allowedTypes - Tipos MIME permitidos
 * @returns {Object} {valid: boolean, error: string}
 */
export const validateFile = (file, options = {}) => {
  const maxSize = options.maxSize || 5 * 1024 * 1024; // 5MB por defecto
  const allowedTypes = options.allowedTypes || ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

  if (!file) {
    return { valid: false, error: 'No se seleccionó ningún archivo' };
  }

  if (file.size > maxSize) {
    return { valid: false, error: `El archivo no puede pesar más de ${maxSize / (1024 * 1024)}MB` };
  }

  if (!allowedTypes.includes(file.type)) {
    return { valid: false, error: 'Tipo de archivo no permitido' };
  }

  return { valid: true };
};

const fileService = {
  uploadFile,
  downloadFile,
  getFileUrl,
  deleteFile,
  listFiles,
  validateFile,
};

export default fileService;
