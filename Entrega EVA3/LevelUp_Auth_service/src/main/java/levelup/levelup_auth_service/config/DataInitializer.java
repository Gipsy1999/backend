package levelup.levelup_auth_service.config;

import levelup.levelup_auth_service.model.Usuario;
import levelup.levelup_auth_service.repository.UsuarioRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        logger.info("Inicializando datos de Auth Service...");

        // Crear usuario ADMIN si no existe
        if (!usuarioRepository.existsByCorreo("admin@levelup.cl")) {
            Usuario admin = Usuario.builder()
                    .run("11111111-1")
                    .nombre("Admin")
                    .apellidos("Level Up")
                    .correo("admin@levelup.cl")
                    .password(passwordEncoder.encode("admin123"))
                    .telefono("+56912345678")
                    .direccion("Av. Principal 123")
                    .fechaNacimiento(LocalDate.of(1990, 1, 1))
                    .rol("ADMIN")
                    .activo(true)
                    .verificado(true)
                    .intentosFallidos(0)
                    .build();

            usuarioRepository.save(admin);
            logger.info("✅ Usuario ADMIN creado: admin@levelup.cl / admin123");
        } else {
            logger.info("Usuario ADMIN ya existe");
        }

        // Crear usuario CLIENTE de prueba si no existe
        if (!usuarioRepository.existsByCorreo("usuario@test.cl")) {
            Usuario usuario = Usuario.builder()
                    .run("22222222-2")
                    .nombre("Usuario")
                    .apellidos("Prueba")
                    .correo("usuario@test.cl")
                    .password(passwordEncoder.encode("user123"))
                    .telefono("+56987654321")
                    .direccion("Calle Secundaria 456")
                    .fechaNacimiento(LocalDate.of(1995, 6, 15))
                    .rol("CLIENTE")
                    .activo(true)
                    .verificado(true)
                    .intentosFallidos(0)
                    .build();

            usuarioRepository.save(usuario);
            logger.info("✅ Usuario CLIENTE creado: usuario@test.cl / user123");
        } else {
            logger.info("Usuario CLIENTE ya existe");
        }

        // Crear usuario VENDEDOR si no existe
        if (!usuarioRepository.existsByCorreo("vendedor@levelup.cl")) {
            Usuario vendedor = Usuario.builder()
                    .run("33333333-3")
                    .nombre("Vendedor")
                    .apellidos("Level Up")
                    .correo("vendedor@levelup.cl")
                    .password(passwordEncoder.encode("vendedor123"))
                    .telefono("+56911111111")
                    .direccion("Oficina Central")
                    .fechaNacimiento(LocalDate.of(1988, 3, 20))
                    .rol("VENDEDOR")
                    .activo(true)
                    .verificado(true)
                    .intentosFallidos(0)
                    .build();

            usuarioRepository.save(vendedor);
            logger.info("✅ Usuario VENDEDOR creado: vendedor@levelup.cl / vendedor123");
        } else {
            logger.info("Usuario VENDEDOR ya existe");
        }

        logger.info("=".repeat(60));
        logger.info("🚀 Auth Service iniciado correctamente en puerto 8081");
        logger.info("=".repeat(60));
        logger.info("📋 CREDENCIALES DE PRUEBA:");
        logger.info("   ADMIN:    admin@levelup.cl / admin123");
        logger.info("   CLIENTE:  usuario@test.cl / user123");
        logger.info("   VENDEDOR: vendedor@levelup.cl / vendedor123");
        logger.info("=".repeat(60));
        logger.info("🔗 Endpoints disponibles:");
        logger.info("   POST   http://localhost:8081/api/auth/login");
        logger.info("   POST   http://localhost:8081/api/auth/register");
        logger.info("   POST   http://localhost:8081/api/auth/validate");
        logger.info("   GET    http://localhost:8081/api/auth/health");
        logger.info("=".repeat(60));
    }
}

