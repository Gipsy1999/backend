package cl.duoc.cladelgado.levelup_analytics_service.service;

import cl.duoc.cladelgado.levelup_analytics_service.dto.AnalyticsResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class AnalyticsService {

    private static final Logger logger = LoggerFactory.getLogger(AnalyticsService.class);

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public AnalyticsResponse getDashboardData() {
        logger.info("Generando datos del dashboard");

        return AnalyticsResponse.builder()
                .ventasTotales(getVentasTotales())
                .totalOrdenes(getTotalOrdenes())
                .totalUsuarios(getTotalUsuarios())
                .totalProductos(getTotalProductos())
                .ordenesHoy(getOrdenesHoy())
                .usuariosNuevosEsteMes(getUsuariosNuevos(30))
                .ticketPromedio(getTicketPromedio())
                .productosMasVendidos(getProductosMasVendidos(5))
                .ventasPorMes(getVentasPorMes(LocalDate.now().getYear()))
                .ordenesPorEstado(getOrdenesPorEstado())
                .usuariosPorRol(getUsuariosPorRol())
                .build();
    }

    public BigDecimal getVentasTotales() {
        String sql = "SELECT COALESCE(SUM(total), 0) FROM ordenes WHERE estado != 'CANCELADO'";
        return jdbcTemplate.queryForObject(sql, BigDecimal.class);
    }

    public Long getTotalOrdenes() {
        String sql = "SELECT COUNT(*) FROM ordenes";
        return jdbcTemplate.queryForObject(sql, Long.class);
    }

    public Long getTotalUsuarios() {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE activo = true";
        return jdbcTemplate.queryForObject(sql, Long.class);
    }

    public Long getTotalProductos() {
        String sql = "SELECT COUNT(*) FROM productos WHERE activo = true";
        return jdbcTemplate.queryForObject(sql, Long.class);
    }

    public Long getOrdenesHoy() {
        String sql = "SELECT COUNT(*) FROM ordenes WHERE DATE(fecha_creacion) = CURRENT_DATE";
        return jdbcTemplate.queryForObject(sql, Long.class);
    }

    public Long getUsuariosNuevos(int dias) {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE fecha_creacion >= NOW() - INTERVAL '" + dias + " days'";
        return jdbcTemplate.queryForObject(sql, Long.class);
    }

    public BigDecimal getTicketPromedio() {
        String sql = "SELECT COALESCE(AVG(total), 0) FROM ordenes WHERE estado != 'CANCELADO'";
        return jdbcTemplate.queryForObject(sql, BigDecimal.class);
    }

    public List<Map<String, Object>> getProductosMasVendidos(int limit) {
        String sql = """
            SELECT 
                p.id,
                p.nombre,
                p.categoria,
                COALESCE(SUM(d.cantidad), 0) as total_vendido,
                COALESCE(SUM(d.subtotal), 0) as ingresos_totales
            FROM productos p
            LEFT JOIN detalle_orden d ON p.id = d.producto_id
            LEFT JOIN ordenes o ON d.orden_id = o.id
            WHERE o.estado != 'CANCELADO' OR o.estado IS NULL
            GROUP BY p.id, p.nombre, p.categoria
            ORDER BY total_vendido DESC
            LIMIT ?
            """;
        return jdbcTemplate.queryForList(sql, limit);
    }

    public List<Map<String, Object>> getProductosBajoStock(int umbral) {
        String sql = """
            SELECT 
                id,
                nombre,
                categoria,
                stock,
                precio
            FROM productos
            WHERE stock < ? AND activo = true
            ORDER BY stock ASC
            """;
        return jdbcTemplate.queryForList(sql, umbral);
    }

    public List<Map<String, Object>> getVentasPorMes(int año) {
        String sql = """
            SELECT 
                EXTRACT(MONTH FROM fecha_creacion) as mes,
                TO_CHAR(fecha_creacion, 'Month') as nombre_mes,
                COUNT(*) as total_ordenes,
                COALESCE(SUM(total), 0) as total_ventas
            FROM ordenes
            WHERE EXTRACT(YEAR FROM fecha_creacion) = ? 
                AND estado != 'CANCELADO'
            GROUP BY EXTRACT(MONTH FROM fecha_creacion), TO_CHAR(fecha_creacion, 'Month')
            ORDER BY mes
            """;
        return jdbcTemplate.queryForList(sql, año);
    }

    public Map<String, Long> getOrdenesPorEstado() {
        String sql = "SELECT estado, COUNT(*) as total FROM ordenes GROUP BY estado";
        List<Map<String, Object>> results = jdbcTemplate.queryForList(sql);
        
        Map<String, Long> estadosMap = new HashMap<>();
        for (Map<String, Object> row : results) {
            estadosMap.put((String) row.get("estado"), ((Number) row.get("total")).longValue());
        }
        return estadosMap;
    }

    public Map<String, Long> getUsuariosPorRol() {
        String sql = "SELECT rol, COUNT(*) as total FROM usuarios WHERE activo = true GROUP BY rol";
        List<Map<String, Object>> results = jdbcTemplate.queryForList(sql);
        
        Map<String, Long> rolesMap = new HashMap<>();
        for (Map<String, Object> row : results) {
            rolesMap.put((String) row.get("rol"), ((Number) row.get("total")).longValue());
        }
        return rolesMap;
    }

    public List<Map<String, Object>> getIngresosPorCategoria() {
        String sql = """
            SELECT 
                p.categoria,
                COUNT(DISTINCT o.id) as total_ordenes,
                COALESCE(SUM(d.cantidad), 0) as unidades_vendidas,
                COALESCE(SUM(d.subtotal), 0) as ingresos_totales
            FROM productos p
            LEFT JOIN detalle_orden d ON p.id = d.producto_id
            LEFT JOIN ordenes o ON d.orden_id = o.id
            WHERE o.estado != 'CANCELADO' OR o.estado IS NULL
            GROUP BY p.categoria
            ORDER BY ingresos_totales DESC
            """;
        return jdbcTemplate.queryForList(sql);
    }
}
