package levelup.levelup_order_service.repository;

import levelup.levelup_order_service.model.Orden;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrdenRepository extends JpaRepository<Orden, Long> {

    List<Orden> findByUsuarioIdOrderByFechaCreacionDesc(Long usuarioId);

    List<Orden> findByEstadoOrderByFechaCreacionDesc(Orden.EstadoOrden estado);
}

