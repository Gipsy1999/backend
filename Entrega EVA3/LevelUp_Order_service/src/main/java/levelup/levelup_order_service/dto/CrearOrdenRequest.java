package levelup.levelup_order_service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CrearOrdenRequest {

    private Long usuarioId;
    private String usuarioNombre;
    private String usuarioCorreo;
    private String direccionEnvio;
    private String metodoPago;
    private List<DetalleOrdenDto> detalles;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class DetalleOrdenDto {
        private Long productoId;
        private String productoNombre;
        private Integer cantidad;
        private BigDecimal precioUnitario;
    }
}

