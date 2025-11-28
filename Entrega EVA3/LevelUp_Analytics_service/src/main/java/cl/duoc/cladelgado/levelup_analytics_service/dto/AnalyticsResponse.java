package cl.duoc.cladelgado.levelup_analytics_service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AnalyticsResponse {
    private BigDecimal ventasTotales;
    private Long totalOrdenes;
    private Long totalUsuarios;
    private Long totalProductos;
    private Long ordenesHoy;
    private Long usuariosNuevosEsteMes;
    private BigDecimal ticketPromedio;
    private List<Map<String, Object>> productosMasVendidos;
    private List<Map<String, Object>> ventasPorMes;
    private Map<String, Long> ordenesPorEstado;
    private Map<String, Long> usuariosPorRol;
}
