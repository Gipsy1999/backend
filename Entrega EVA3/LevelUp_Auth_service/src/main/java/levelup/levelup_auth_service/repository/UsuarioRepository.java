package levelup.levelup_auth_service.repository;

import levelup.levelup_auth_service.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByCorreo(String correo);

    Optional<Usuario> findByRun(String run);

    Boolean existsByCorreo(String correo);

    Boolean existsByRun(String run);
}

