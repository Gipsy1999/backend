package levelup.levelup_auth_service.service;

import levelup.levelup_auth_service.dto.AuthResponse;
import levelup.levelup_auth_service.dto.LoginRequest;
import levelup.levelup_auth_service.dto.RegisterRequest;
import levelup.levelup_auth_service.model.Usuario;
import levelup.levelup_auth_service.repository.UsuarioRepository;
import levelup.levelup_auth_service.security.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.Period;

@Service
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        logger.info("Intentando registrar usuario: {}", request.getCorreo());

        // Validar que no exista el correo
        if (usuarioRepository.existsByCorreo(request.getCorreo())) {
            throw new RuntimeException("Ya existe un usuario con ese correo");
        }

        // Validar que no exista el RUN
        if (usuarioRepository.existsByRun(request.getRun())) {
            throw new RuntimeException("Ya existe un usuario con ese RUN");
        }

        // Validar edad mínima 18 años
        if (request.getFechaNacimiento() != null) {
            LocalDate fechaNac = request.getFechaNacimiento();
            int edad = Period.between(fechaNac, LocalDate.now()).getYears();
            if (edad < 18) {
                throw new RuntimeException("Debes ser mayor de 18 años para registrarte");
            }
        }

        // Crear nuevo usuario
        Usuario usuario = Usuario.builder()
                .run(request.getRun())
                .nombre(request.getNombre())
                .apellidos(request.getApellidos())
                .correo(request.getCorreo())
                .password(passwordEncoder.encode(request.getPassword()))
                .telefono(request.getTelefono())
                .direccion(request.getDireccion())
                .fechaNacimiento(request.getFechaNacimiento())
                .rol("CLIENTE")
                .activo(true)
                .verificado(false)
                .intentosFallidos(0)
                .build();

        usuario = usuarioRepository.save(usuario);
        logger.info("Usuario registrado exitosamente: {}", usuario.getCorreo());

        // Generar token
        String token = jwtUtil.generateToken(usuario);

        return AuthResponse.builder()
                .token(token)
                .tipo("Bearer")
                .id(usuario.getId())
                .nombre(usuario.getNombre())
                .apellidos(usuario.getApellidos())
                .correo(usuario.getCorreo())
                .rol(usuario.getRol())
                .mensaje("Usuario registrado exitosamente")
                .build();
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        logger.info("Intentando iniciar sesión: {}", request.getCorreo());

        Usuario usuario = usuarioRepository.findByCorreo(request.getCorreo())
                .orElseThrow(() -> new RuntimeException("Credenciales incorrectas"));

        if (!usuario.getActivo()) {
            throw new RuntimeException("Usuario inactivo");
        }

        if (!passwordEncoder.matches(request.getPassword(), usuario.getPassword())) {
            throw new RuntimeException("Credenciales incorrectas");
        }

        logger.info("Inicio de sesión exitoso: {}", usuario.getCorreo());

        // Generar token
        String token = jwtUtil.generateToken(usuario);

        return AuthResponse.builder()
                .token(token)
                .tipo("Bearer")
                .id(usuario.getId())
                .nombre(usuario.getNombre())
                .apellidos(usuario.getApellidos())
                .correo(usuario.getCorreo())
                .rol(usuario.getRol())
                .mensaje("Inicio de sesión exitoso")
                .build();
    }

    @Transactional(readOnly = true)
    public AuthResponse validateToken(String token) {
        if (!jwtUtil.validateToken(token)) {
            throw new RuntimeException("Token inválido o expirado");
        }

        String correo = jwtUtil.extractCorreo(token);
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        return AuthResponse.builder()
                .id(usuario.getId())
                .nombre(usuario.getNombre())
                .apellidos(usuario.getApellidos())
                .correo(usuario.getCorreo())
                .rol(usuario.getRol())
                .mensaje("Token válido")
                .build();
    }
}

