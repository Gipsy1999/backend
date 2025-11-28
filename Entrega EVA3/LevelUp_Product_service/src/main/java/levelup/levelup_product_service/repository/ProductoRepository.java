package levelup.levelup_product_service.repository;

import levelup.levelup_product_service.model.Producto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductoRepository extends JpaRepository<Producto, Long> {

    List<Producto> findByActivoTrue();

    List<Producto> findByDestacadoTrueAndActivoTrue();

    List<Producto> findByCategoriaAndActivoTrue(String categoria);

    List<Producto> findByNombreContainingIgnoreCaseAndActivoTrue(String nombre);
}

