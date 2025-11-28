package levelup.levelup_order_service.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "ordenes")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Orden {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "El ID de usuario es obligatorio")
    @Column(name = "usuario_id", nullable = false)
    private Long usuarioId;

    @Column(name = "cliente_nombre", length = 150)
    private String clienteNombre;

    @Column(name = "cliente_correo", length = 255)
    private String clienteCorreo;

    @Column(name = "cliente_telefono", length = 15)
    private String clienteTelefono;

    @Column(name = "cliente_run", length = 12)
    private String clienteRun;

    @Column(name = "numero_orden", length = 20, unique = true)
    private String numeroOrden;

    @Column(name = "carrito_id")
    private Long carritoId;

    // Dirección de envío completa
    @Column(name = "direccion_envio", columnDefinition = "TEXT")
    private String direccionEnvio;

    @Column(name = "comuna_envio", length = 100)
    private String comunaEnvio;

    @Column(name = "ciudad_envio", length = 100)
    private String ciudadEnvio;

    @Column(name = "region_envio", length = 100)
    private String regionEnvio;

    @Column(name = "codigo_postal_envio", length = 10)
    private String codigoPostalEnvio;

    // Totales
    @NotNull(message = "El subtotal es obligatorio")
    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal subtotal;

    @Column(name = "descuento_total", precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal descuentoTotal = BigDecimal.ZERO;

    @Column(name = "envio", precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal envio = BigDecimal.ZERO;

    @NotNull(message = "El IVA es obligatorio")
    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal iva;

    @NotNull(message = "El total es obligatorio")
    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal total;

    // Estado y pago
    @Enumerated(EnumType.STRING)
    @Column(name = "estado", length = 20, nullable = false)
    @Builder.Default
    private EstadoOrden estado = EstadoOrden.PENDIENTE;

    @Column(name = "metodo_pago", length = 50)
    private String metodoPago;

    @Column(name = "estado_pago", length = 20, nullable = false)
    @Builder.Default
    private String estadoPago = "PENDIENTE";

    @Column(name = "fecha_pago")
    private LocalDateTime fechaPago;

    @Column(name = "notas_cliente", columnDefinition = "TEXT")
    private String notasCliente;

    @Column(name = "notas_internas", columnDefinition = "TEXT")
    private String notasInternas;

    @OneToMany(mappedBy = "orden", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<DetalleOrden> detalles = new ArrayList<>();

    @CreationTimestamp
    @Column(name = "fecha_creacion", nullable = false, updatable = false)
    private LocalDateTime fechaCreacion;

    @UpdateTimestamp
    @Column(name = "fecha_actualizacion")
    private LocalDateTime fechaActualizacion;

    @Column(name = "fecha_completada")
    private LocalDateTime fechaCompletada;

    @Column(name = "fecha_cancelada")
    private LocalDateTime fechaCancelada;

    public void agregarDetalle(DetalleOrden detalle) {
        detalles.add(detalle);
        detalle.setOrden(this);
    }

    // Enum para estados
    public enum EstadoOrden {
        PENDIENTE,
        PROCESANDO,
        ENVIADO,
        ENTREGADO,
        CANCELADO
    }
}

