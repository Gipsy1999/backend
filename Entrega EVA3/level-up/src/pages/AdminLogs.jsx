import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import '../styles/Admin.css';

export default function AdminLogs() {
  const [logs, setLogs] = useState([]);
  const [tipoFiltro, setTipoFiltro] = useState('todos');
  const [accionFiltro, setAccionFiltro] = useState('todas');
  const [fechaInicio, setFechaInicio] = useState('');
  const [fechaFin, setFechaFin] = useState('');

  useEffect(() => {
    cargarLogs();

    const handleLogsChange = () => {
      cargarLogs();
    };

    window.addEventListener('logsActualizados', handleLogsChange);
    window.addEventListener('storage', handleLogsChange);

    return () => {
      window.removeEventListener('logsActualizados', handleLogsChange);
      window.removeEventListener('storage', handleLogsChange);
    };
  }, []);

  const cargarLogs = () => {
    const logsLS = JSON.parse(localStorage.getItem('logs') || '[]');
    const logsOrdenados = logsLS.sort((a, b) => new Date(b.fecha) - new Date(a.fecha));
    setLogs(logsOrdenados);
  };

  const logsFiltrados = logs.filter(log => {
    if (tipoFiltro !== 'todos' && log.tipo !== tipoFiltro) {
      return false;
    }

    if (accionFiltro !== 'todas') {
      const accionLower = log.accion.toLowerCase();
      if (accionFiltro === 'crear' && !accionLower.includes('creó') && !accionLower.includes('registró')) {
        return false;
      }
      if (accionFiltro === 'editar' && !accionLower.includes('editó') && !accionLower.includes('actualizó')) {
        return false;
      }
      if (accionFiltro === 'eliminar' && !accionLower.includes('eliminó')) {
        return false;
      }
      if (accionFiltro === 'compra' && !accionLower.includes('compra')) {
        return false;
      }
      if (accionFiltro === 'carrito' && !accionLower.includes('carrito') && !accionLower.includes('agregó')) {
        return false;
      }
      if (accionFiltro === 'contacto' && !accionLower.includes('contacto')) {
        return false;
      }
      if (accionFiltro === 'sesion' && !accionLower.includes('sesión')) {
        return false;
      }
    }

    if (fechaInicio) {
      const fechaLog = new Date(log.fecha);
      const fechaInicioDate = new Date(fechaInicio);
      fechaInicioDate.setHours(0, 0, 0, 0);
      if (fechaLog < fechaInicioDate) {
        return false;
      }
    }

    if (fechaFin) {
      const fechaLog = new Date(log.fecha);
      const fechaFinDate = new Date(fechaFin);
      fechaFinDate.setHours(23, 59, 59, 999);
      if (fechaLog > fechaFinDate) {
        return false;
      }
    }

    return true;
  });

  const formatearFecha = (fechaISO) => {
    const fecha = new Date(fechaISO);
    return fecha.toLocaleString('es-CL', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });
  };

  const getIconoTipo = (tipo) => {
    return tipo === 'admin' ? '⚙️' : '🛒';
  };

  const getColorAccion = (accion) => {
    if (accion.includes('Creó') || accion.includes('Agregó') || accion.includes('agregó')) {
      return 'var(--accent-green)';
    }
    if (accion.includes('Eliminó') || accion.includes('eliminó')) {
      return '#ff4444';
    }
    if (accion.includes('Editó') || accion.includes('Actualizó')) {
      return 'var(--accent-blue)';
    }
    return '#fff';
  };

  const limpiarLogs = () => {
    if (window.confirm('¿Estás seguro de que deseas limpiar todos los logs?')) {
      localStorage.setItem('logs', JSON.stringify([]));
      setLogs([]);
      if (window.notificar) {
        window.notificar('Logs limpiados exitosamente', 'success', 3000);
      }
    }
  };

  return (
    <main className="container admin-page">
      <div className="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h2 className="section-title mb-2">Registro de Actividades (Logs)</h2>
          <Link to="/admin" className="text-secondary">
            ← Volver al Panel
          </Link>
        </div>
        <button 
          className="btn btn-danger"
          onClick={limpiarLogs}
          disabled={logs.length === 0}
        >
          Limpiar Logs
        </button>
      </div>

      <div className="admin-card mb-4">
        <div className="admin-card-body">
          <div className="row">
            <div className="col-md-12 mb-3">
              <label className="form-label text-white fw-bold">Filtrar por tipo:</label>
              <div className="d-flex gap-3 flex-wrap">
                <button
                  className={`btn ${tipoFiltro === 'todos' ? 'btn-success' : 'btn-outline-success'}`}
                  onClick={() => setTipoFiltro('todos')}
                >
                  Todos ({logs.length})
                </button>
                <button
                  className={`btn ${tipoFiltro === 'admin' ? 'btn-success' : 'btn-outline-success'}`}
                  onClick={() => setTipoFiltro('admin')}
                >
                  ⚙️ Admin ({logs.filter(l => l.tipo === 'admin').length})
                </button>
                <button
                  className={`btn ${tipoFiltro === 'usuario' ? 'btn-success' : 'btn-outline-success'}`}
                  onClick={() => setTipoFiltro('usuario')}
                >
                  🛒 Usuarios ({logs.filter(l => l.tipo === 'usuario').length})
                </button>
              </div>
            </div>

            <div className="col-md-12 mb-3">
              <label className="form-label text-white fw-bold">Filtrar por acción:</label>
              <div className="d-flex gap-2 flex-wrap">
                <button
                  className={`btn btn-sm ${accionFiltro === 'todas' ? 'btn-success' : 'btn-outline-success'}`}
                  onClick={() => setAccionFiltro('todas')}
                >
                  Todas
                </button>
                <button
                  className={`btn btn-sm ${accionFiltro === 'crear' ? 'btn-success' : 'btn-outline-success'}`}
                  onClick={() => setAccionFiltro('crear')}
                >
                  Crear/Registrar
                </button>
                <button
                  className={`btn btn-sm ${accionFiltro === 'editar' ? 'btn-success' : 'btn-outline-success'}`}
                  onClick={() => setAccionFiltro('editar')}
                >
                  Editar
                </button>
                <button
                  className={`btn btn-sm ${accionFiltro === 'eliminar' ? 'btn-success' : 'btn-outline-success'}`}
                  onClick={() => setAccionFiltro('eliminar')}
                >
                  Eliminar
                </button>
                <button
                  className={`btn btn-sm ${accionFiltro === 'compra' ? 'btn-success' : 'btn-outline-success'}`}
                  onClick={() => setAccionFiltro('compra')}
                >
                  Compras
                </button>
                <button
                  className={`btn btn-sm ${accionFiltro === 'carrito' ? 'btn-success' : 'btn-outline-success'}`}
                  onClick={() => setAccionFiltro('carrito')}
                >
                  Carrito
                </button>
                <button
                  className={`btn btn-sm ${accionFiltro === 'contacto' ? 'btn-success' : 'btn-outline-success'}`}
                  onClick={() => setAccionFiltro('contacto')}
                >
                  Contacto
                </button>
                <button
                  className={`btn btn-sm ${accionFiltro === 'sesion' ? 'btn-success' : 'btn-outline-success'}`}
                  onClick={() => setAccionFiltro('sesion')}
                >
                  Sesiones
                </button>
              </div>
            </div>

            <div className="col-md-6 mb-3">
              <label className="form-label text-white fw-bold">Fecha desde:</label>
              <input
                type="date"
                className="form-control admin-logs-fecha-input"
                value={fechaInicio}
                onChange={(e) => setFechaInicio(e.target.value)}
              />
            </div>

            <div className="col-md-6 mb-3">
              <label className="form-label text-white fw-bold">Fecha hasta:</label>
              <input
                type="date"
                className="form-control admin-logs-fecha-input"
                value={fechaFin}
                onChange={(e) => setFechaFin(e.target.value)}
              />
            </div>

            {(fechaInicio || fechaFin || accionFiltro !== 'todas' || tipoFiltro !== 'todos') && (
              <div className="col-md-12">
                <button
                  className="btn btn-secondary btn-sm"
                  onClick={() => {
                    setFechaInicio('');
                    setFechaFin('');
                    setAccionFiltro('todas');
                    setTipoFiltro('todos');
                  }}
                >
                  Limpiar Filtros
                </button>
                <span className="ms-3 text-white">
                  Mostrando {logsFiltrados.length} de {logs.length} registros
                </span>
              </div>
            )}
          </div>
        </div>
      </div>

      <div className="admin-card">
        <div className="admin-card-body">
          {logsFiltrados.length === 0 ? (
            <div className="text-center py-5">
              <p className="text-secondary">No hay registros de actividad</p>
            </div>
          ) : (
            <div className="table-responsive">
              <table className="table table-dark table-hover">
                <thead>
                  <tr>
                    <th className="admin-logs-th-tipo">Tipo</th>
                    <th className="admin-logs-th-fecha">Fecha y Hora</th>
                    <th className="admin-logs-th-usuario">Usuario/ID</th>
                    <th>Acción</th>
                  </tr>
                </thead>
                <tbody>
                  {logsFiltrados.map((log, index) => (
                    <tr key={index}>
                      <td className="text-center admin-logs-td-icono">
                        {getIconoTipo(log.tipo)}
                      </td>
                      <td className="admin-logs-td-fecha">
                        {formatearFecha(log.fecha)}
                      </td>
                      <td className="admin-logs-td-usuario">
                        {log.usuario}
                      </td>
                      <td style={{ color: getColorAccion(log.accion) }}>
                        {log.accion}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </main>
  );
}
