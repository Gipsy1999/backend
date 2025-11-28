package levelup.levelup_order_service.service;

import levelup.levelup_order_service.dto.CrearOrdenRequest;
import levelup.levelup_order_service.model.DetalleOrden;
import levelup.levelup_order_service.model.Orden;
import levelup.levelup_order_service.repository.OrdenRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
public class OrdenService {

    private static final Logger logger = LoggerFactory.getLogger(OrdenService.class);

    @Autowired
    private OrdenRepository ordenRepository;

    @Transactional(readOnly = true)
    public List<Orden> obtenerTodas() {
        return ordenRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Orden obtenerPorId(Long id) {
        return ordenRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Orden no encontrada"));
    }

    @Transactional(readOnly = true)
    public List<Orden> obtenerPorUsuario(Long usuarioId) {
        return ordenRepository.findByUsuarioIdOrderByFechaCreacionDesc(usuarioId);
    }

    @Transactional(readOnly = true)
    public List<Orden> obtenerPorEstado(Orden.EstadoOrden estado) {
        return ordenRepository.findByEstadoOrderByFechaCreacionDesc(estado);
    }

    @Transactional
    public Orden crear(CrearOrdenRequest request) {
        logger.info("Creando orden para usuario: {}", request.getUsuarioId());

        Orden orden = Orden.builder()
                .usuarioId(request.getUsuarioId())
                .clienteNombre(request.getUsuarioNombre())
                .clienteCorreo(request.getUsuarioCorreo())
                .direccionEnvio(request.getDireccionEnvio())
                .metodoPago(request.getMetodoPago())
                .estado(Orden.EstadoOrden.PENDIENTE)
                .subtotal(BigDecimal.ZERO)
                .iva(BigDecimal.ZERO)
                .total(BigDecimal.ZERO)
                .build();

        BigDecimal total = BigDecimal.ZERO;

        for (CrearOrdenRequest.DetalleOrdenDto detalleDto : request.getDetalles()) {
            BigDecimal subtotal = detalleDto.getPrecioUnitario()
                    .multiply(BigDecimal.valueOf(detalleDto.getCantidad()));

            DetalleOrden detalle = DetalleOrden.builder()
                    .productoId(detalleDto.getProductoId())
                    .productoNombre(detalleDto.getProductoNombre())
                    .cantidad(detalleDto.getCantidad())
                    .precioUnitario(detalleDto.getPrecioUnitario())
                    .subtotal(subtotal)
                    .build();

            orden.agregarDetalle(detalle);
            total = total.add(subtotal);
        }

        orden.setTotal(total);

        Orden ordenGuardada = ordenRepository.save(orden);
        logger.info("Orden creada con ID: {}, Total: {}", ordenGuardada.getId(), ordenGuardada.getTotal());

        return ordenGuardada;
    }

    @Transactional
    public Orden actualizarEstado(Long id, Orden.EstadoOrden nuevoEstado) {
        Orden orden = obtenerPorId(id);
        orden.setEstado(nuevoEstado);
        logger.info("Estado de orden {} actualizado a: {}", id, nuevoEstado);
        return ordenRepository.save(orden);
    }

    @Transactional
    public void cancelar(Long id) {
        Orden orden = obtenerPorId(id);

        if (orden.getEstado() == Orden.EstadoOrden.ENTREGADO) {
            throw new RuntimeException("No se puede cancelar una orden ya entregada");
        }

        orden.setEstado(Orden.EstadoOrden.CANCELADO);
        ordenRepository.save(orden);
        logger.info("Orden {} cancelada", id);
    }
}

