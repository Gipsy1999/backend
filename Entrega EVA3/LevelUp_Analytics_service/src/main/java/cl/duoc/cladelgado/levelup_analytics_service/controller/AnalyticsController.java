package cl.duoc.cladelgado.levelup_analytics_service.controller;

import cl.duoc.cladelgado.levelup_analytics_service.dto.AnalyticsResponse;
import cl.duoc.cladelgado.levelup_analytics_service.service.AnalyticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/analytics")
public class AnalyticsController {

    @Autowired
    private AnalyticsService analyticsService;

    @GetMapping("/dashboard")
    public ResponseEntity<AnalyticsResponse> getDashboard() {
        return ResponseEntity.ok(analyticsService.getDashboardData());
    }

    @GetMapping("/ventas/totales")
    public ResponseEntity<Map<String, Object>> getVentasTotales() {
        BigDecimal total = analyticsService.getVentasTotales();
        Map<String, Object> response = new HashMap<>();
        response.put("total", total);
        response.put("moneda", "CLP");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/ventas/por-mes")
    public ResponseEntity<List<Map<String, Object>>> getVentasPorMes(
            @RequestParam(required = false) Integer año) {
        int year = año != null ? año : LocalDate.now().getYear();
        return ResponseEntity.ok(analyticsService.getVentasPorMes(year));
    }

    @GetMapping("/productos/mas-vendidos")
    public ResponseEntity<List<Map<String, Object>>> getProductosMasVendidos(
            @RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(analyticsService.getProductosMasVendidos(limit));
    }

    @GetMapping("/productos/bajo-stock")
    public ResponseEntity<List<Map<String, Object>>> getProductosBajoStock(
            @RequestParam(defaultValue = "10") int umbral) {
        return ResponseEntity.ok(analyticsService.getProductosBajoStock(umbral));
    }

    @GetMapping("/ordenes/por-estado")
    public ResponseEntity<Map<String, Long>> getOrdenesPorEstado() {
        return ResponseEntity.ok(analyticsService.getOrdenesPorEstado());
    }

    @GetMapping("/usuarios/nuevos")
    public ResponseEntity<Map<String, Object>> getUsuariosNuevos(
            @RequestParam(required = false) Integer dias) {
        int period = dias != null ? dias : 30;
        Long count = analyticsService.getUsuariosNuevos(period);
        Map<String, Object> response = new HashMap<>();
        response.put("count", count);
        response.put("periodo_dias", period);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/usuarios/por-rol")
    public ResponseEntity<Map<String, Long>> getUsuariosPorRol() {
        return ResponseEntity.ok(analyticsService.getUsuariosPorRol());
    }

    @GetMapping("/ingresos/por-categoria")
    public ResponseEntity<List<Map<String, Object>>> getIngresosPorCategoria() {
        return ResponseEntity.ok(analyticsService.getIngresosPorCategoria());
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "Analytics Service");
        response.put("timestamp", String.valueOf(System.currentTimeMillis()));
        return ResponseEntity.ok(response);
    }
}
