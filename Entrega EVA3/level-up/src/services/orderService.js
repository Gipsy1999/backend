// Servicio para interactuar con Order Service (Puerto 8084)
const API_BASE_URL = process.env.REACT_APP_API_GATEWAY_URL || 'http://localhost:8080';
const ORDER_SERVICE_URL = `${API_BASE_URL}/orders`;

/**
 * Crea una nueva orden de compra
 * @param {Object} orderData - Datos de la orden
 * @param {string} orderData.userId - ID del usuario
 * @param {Array} orderData.items - Items de la orden [{productId, quantity, price}]
 * @param {number} orderData.totalAmount - Monto total
 * @param {string} orderData.shippingAddress - Dirección de envío
 * @param {string} orderData.paymentMethod - Método de pago
 * @returns {Promise<Object>} Orden creada
 */
export const createOrder = async (orderData) => {
  try {
    const token = localStorage.getItem('token');
    const response = await fetch(`${ORDER_SERVICE_URL}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token ? `Bearer ${token}` : '',
      },
      body: JSON.stringify(orderData),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || `Error al crear la orden: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('Error en createOrder:', error);
    throw error;
  }
};

/**
 * Obtiene todas las órdenes del usuario actual
 * @returns {Promise<Array>} Lista de órdenes
 */
export const getUserOrders = async () => {
  try {
    const token = localStorage.getItem('token');
    const userId = localStorage.getItem('userId');
    
    if (!userId) {
      throw new Error('Usuario no autenticado');
    }

    const response = await fetch(`${ORDER_SERVICE_URL}/user/${userId}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token ? `Bearer ${token}` : '',
      },
    });

    if (!response.ok) {
      throw new Error(`Error al obtener órdenes: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('Error en getUserOrders:', error);
    throw error;
  }
};

/**
 * Obtiene una orden por su ID
 * @param {string} orderId - ID de la orden
 * @returns {Promise<Object>} Orden encontrada
 */
export const getOrderById = async (orderId) => {
  try {
    const token = localStorage.getItem('token');
    const response = await fetch(`${ORDER_SERVICE_URL}/${orderId}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token ? `Bearer ${token}` : '',
      },
    });

    if (!response.ok) {
      throw new Error(`Error al obtener la orden: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('Error en getOrderById:', error);
    throw error;
  }
};

/**
 * Actualiza el estado de una orden
 * @param {string} orderId - ID de la orden
 * @param {string} status - Nuevo estado (PENDING, CONFIRMED, SHIPPED, DELIVERED, CANCELLED)
 * @returns {Promise<Object>} Orden actualizada
 */
export const updateOrderStatus = async (orderId, status) => {
  try {
    const token = localStorage.getItem('token');
    const response = await fetch(`${ORDER_SERVICE_URL}/${orderId}/status`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token ? `Bearer ${token}` : '',
      },
      body: JSON.stringify({ status }),
    });

    if (!response.ok) {
      throw new Error(`Error al actualizar el estado: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('Error en updateOrderStatus:', error);
    throw error;
  }
};

/**
 * Cancela una orden
 * @param {string} orderId - ID de la orden
 * @returns {Promise<Object>} Orden cancelada
 */
export const cancelOrder = async (orderId) => {
  return updateOrderStatus(orderId, 'CANCELLED');
};

/**
 * Obtiene todas las órdenes (Admin)
 * @param {Object} params - Parámetros de filtrado
 * @param {string} params.status - Estado de la orden
 * @param {string} params.startDate - Fecha inicio (ISO)
 * @param {string} params.endDate - Fecha fin (ISO)
 * @returns {Promise<Array>} Lista de órdenes
 */
export const getAllOrders = async (params = {}) => {
  try {
    const token = localStorage.getItem('token');
    const queryParams = new URLSearchParams();
    
    if (params.status) queryParams.append('status', params.status);
    if (params.startDate) queryParams.append('startDate', params.startDate);
    if (params.endDate) queryParams.append('endDate', params.endDate);

    const url = `${ORDER_SERVICE_URL}${queryParams.toString() ? '?' + queryParams.toString() : ''}`;
    
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token ? `Bearer ${token}` : '',
      },
    });

    if (!response.ok) {
      throw new Error(`Error al obtener todas las órdenes: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('Error en getAllOrders:', error);
    throw error;
  }
};

const orderService = {
  createOrder,
  getUserOrders,
  getOrderById,
  updateOrderStatus,
  cancelOrder,
  getAllOrders,
};

export default orderService;
