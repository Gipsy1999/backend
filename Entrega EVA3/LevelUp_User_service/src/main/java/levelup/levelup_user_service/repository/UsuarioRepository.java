package levelup.levelup_user_service.repository;

import levelup.levelup_user_service.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByCorreo(String correo);

    Optional<Usuario> findByRun(String run);

    boolean existsByCorreo(String correo);

    boolean existsByRun(String run);

    List<Usuario> findByActivoTrue();

    List<Usuario> findByRol(String rol);

    @Query("SELECT u FROM Usuario u WHERE u.activo = true AND u.rol = ?1")
    List<Usuario> findActiveUsersByRole(String rol);

    @Query("SELECT u FROM Usuario u WHERE LOWER(u.nombre) LIKE LOWER(CONCAT('%', ?1, '%')) OR LOWER(u.apellidos) LIKE LOWER(CONCAT('%', ?1, '%'))")
    List<Usuario> searchByName(String nombre);
}

