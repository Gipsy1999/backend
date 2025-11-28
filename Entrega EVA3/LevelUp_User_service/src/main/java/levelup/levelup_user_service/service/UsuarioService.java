package levelup.levelup_user_service.service;

import levelup.levelup_user_service.dto.*;
import levelup.levelup_user_service.entity.Usuario;
import levelup.levelup_user_service.repository.UsuarioRepository;
import levelup.levelup_user_service.security.JwtTokenProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class UsuarioService {

    private static final Logger logger = LoggerFactory.getLogger(UsuarioService.class);

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Transactional
    public AuthResponse login(LoginRequest loginRequest) {
        logger.info("Intento de login para correo: {}", loginRequest.getCorreo());

        try {
            // Verificar si el usuario existe
            Usuario usuarioExistente = usuarioRepository.findByCorreo(loginRequest.getCorreo())
                    .orElse(null);

            if (usuarioExistente == null) {
                logger.error("Usuario no encontrado en BD: {}", loginRequest.getCorreo());
                throw new RuntimeException("Usuario no encontrado en la base de datos");
            }

            logger.info("Usuario encontrado - ID: {}, Activo: {}, Verificado: {}, Rol: {}",
                usuarioExistente.getId(),
                usuarioExistente.getActivo(),
                usuarioExistente.getVerificado(),
                usuarioExistente.getRol());

            if (!usuarioExistente.getActivo()) {
                logger.error("Usuario inactivo: {}", loginRequest.getCorreo());
                throw new RuntimeException("Usuario inactivo");
            }

            // Intentar autenticar
            logger.info("Intentando autenticación con AuthenticationManager...");
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getCorreo(),
                            loginRequest.getPassword()
                    )
            );

            logger.info("Autenticación exitosa para: {}", loginRequest.getCorreo());

            SecurityContextHolder.getContext().setAuthentication(authentication);

            Usuario usuario = usuarioRepository.findByCorreo(loginRequest.getCorreo())
                    .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

            usuario.setUltimoAcceso(LocalDateTime.now());
            usuario.setIntentosFallidos(0);
            usuarioRepository.save(usuario);

            String token = jwtTokenProvider.generateToken(usuario);
            logger.info("Token generado exitosamente para: {}", loginRequest.getCorreo());

            return new AuthResponse(token, UsuarioResponse.fromEntity(usuario));
        } catch (Exception e) {
            logger.error("Error en login para {}: {} - {}",
                loginRequest.getCorreo(),
                e.getClass().getSimpleName(),
                e.getMessage());
            throw e;
        }
    }

    @Transactional
    public AuthResponse registro(RegistroRequest registroRequest) {
        if (usuarioRepository.existsByCorreo(registroRequest.getCorreo())) {
            throw new RuntimeException("El correo ya esta registrado");
        }

        if (usuarioRepository.existsByRun(registroRequest.getRun())) {
            throw new RuntimeException("El RUN ya esta registrado");
        }

        // Validar edad mínima 18 años
        if (registroRequest.getFechaNacimiento() != null) {
            LocalDate fechaNac = registroRequest.getFechaNacimiento();
            int edad = Period.between(fechaNac, LocalDate.now()).getYears();
            if (edad < 18) {
                throw new RuntimeException("Debes ser mayor de 18 años para registrarte");
            }
        }

        String rolString = registroRequest.getRol() != null ? registroRequest.getRol() : "CLIENTE";

        Usuario usuario = Usuario.builder()
                .run(registroRequest.getRun())
                .nombre(registroRequest.getNombre())
                .apellidos(registroRequest.getApellidos())
                .correo(registroRequest.getCorreo())
                .password(passwordEncoder.encode(registroRequest.getPassword()))
                .telefono(registroRequest.getTelefono())
                .direccion(registroRequest.getDireccion())
                .comuna(registroRequest.getComuna())
                .ciudad(registroRequest.getCiudad())
                .region(registroRequest.getRegion())
                .codigoPostal(registroRequest.getCodigoPostal())
                .fechaNacimiento(registroRequest.getFechaNacimiento())
                .rol(rolString)
                .activo(true)
                .verificado(false)
                .intentosFallidos(0)
                .build();

        usuario = usuarioRepository.save(usuario);

        String token = jwtTokenProvider.generateToken(usuario);

        return new AuthResponse(token, UsuarioResponse.fromEntity(usuario));
    }

    public UsuarioResponse obtenerPorId(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return UsuarioResponse.fromEntity(usuario);
    }

    public UsuarioResponse obtenerPorCorreo(String correo) {
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return UsuarioResponse.fromEntity(usuario);
    }

    public List<UsuarioResponse> listarTodos() {
        return usuarioRepository.findAll().stream()
                .map(UsuarioResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<UsuarioResponse> listarActivos() {
        return usuarioRepository.findByActivoTrue().stream()
                .map(UsuarioResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<UsuarioResponse> listarPorRol(String rol) {
        List<Usuario> usuarios = usuarioRepository.findAll();
        return usuarios.stream()
                .filter(u -> u.getRol().equals(rol))
                .map(UsuarioResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<UsuarioResponse> buscarPorNombre(String nombre) {
        return usuarioRepository.searchByName(nombre).stream()
                .map(UsuarioResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public UsuarioResponse actualizar(Long id, ActualizarUsuarioRequest request) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        // Validar correo solo si se está cambiando
        if (request.getCorreo() != null && !request.getCorreo().isEmpty() &&
            !usuario.getCorreo().equals(request.getCorreo()) &&
            usuarioRepository.existsByCorreo(request.getCorreo())) {
            throw new RuntimeException("El correo ya esta registrado");
        }

        // Validar RUN solo si se está cambiando
        if (request.getRun() != null && !request.getRun().isEmpty() &&
            !usuario.getRun().equals(request.getRun()) &&
            usuarioRepository.existsByRun(request.getRun())) {
            throw new RuntimeException("El RUN ya esta registrado");
        }

        // Actualizar solo los campos que vienen en el request (no nulos)
        if (request.getRun() != null && !request.getRun().isEmpty()) {
            usuario.setRun(request.getRun());
        }
        if (request.getNombre() != null && !request.getNombre().isEmpty()) {
            usuario.setNombre(request.getNombre());
        }
        if (request.getApellidos() != null && !request.getApellidos().isEmpty()) {
            usuario.setApellidos(request.getApellidos());
        }
        if (request.getCorreo() != null && !request.getCorreo().isEmpty()) {
            usuario.setCorreo(request.getCorreo());
        }
        if (request.getTelefono() != null && !request.getTelefono().isEmpty()) {
            usuario.setTelefono(request.getTelefono());
        }
        if (request.getDireccion() != null && !request.getDireccion().isEmpty()) {
            usuario.setDireccion(request.getDireccion());
        }
        if (request.getComuna() != null && !request.getComuna().isEmpty()) {
            usuario.setComuna(request.getComuna());
        }
        if (request.getCiudad() != null && !request.getCiudad().isEmpty()) {
            usuario.setCiudad(request.getCiudad());
        }
        if (request.getRegion() != null && !request.getRegion().isEmpty()) {
            usuario.setRegion(request.getRegion());
        }
        if (request.getCodigoPostal() != null && !request.getCodigoPostal().isEmpty()) {
            usuario.setCodigoPostal(request.getCodigoPostal());
        }
        if (request.getFechaNacimiento() != null) {
            usuario.setFechaNacimiento(request.getFechaNacimiento());
        }
        if (request.getPassword() != null && !request.getPassword().isEmpty()) {
            usuario.setPassword(passwordEncoder.encode(request.getPassword()));
        }

        usuario = usuarioRepository.save(usuario);
        return UsuarioResponse.fromEntity(usuario);
    }

    // Mantener compatibilidad con RegistroRequest
    @Transactional
    public UsuarioResponse actualizar(Long id, RegistroRequest request) {
        ActualizarUsuarioRequest actualizarRequest = ActualizarUsuarioRequest.builder()
                .run(request.getRun())
                .nombre(request.getNombre())
                .apellidos(request.getApellidos())
                .correo(request.getCorreo())
                .password(request.getPassword())
                .telefono(request.getTelefono())
                .direccion(request.getDireccion())
                .comuna(request.getComuna())
                .ciudad(request.getCiudad())
                .region(request.getRegion())
                .codigoPostal(request.getCodigoPostal())
                .fechaNacimiento(request.getFechaNacimiento())
                .build();
        return actualizar(id, actualizarRequest);
    }

    @Transactional
    public void desactivar(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        usuario.setActivo(false);
        usuarioRepository.save(usuario);
    }

    @Transactional
    public void eliminarPermanente(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        usuarioRepository.delete(usuario);
        logger.warn("Usuario eliminado permanentemente - ID: {}, Correo: {}", id, usuario.getCorreo());
    }

    @Transactional
    public void activar(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        usuario.setActivo(true);
        usuarioRepository.save(usuario);
    }

    @Transactional
    public void cambiarRol(Long id, String rol) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        usuario.setRol(rol);
        usuarioRepository.save(usuario);
    }

    public boolean validarCredenciales(String correo, String password) {
        Usuario usuario = usuarioRepository.findByCorreo(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return passwordEncoder.matches(password, usuario.getPassword());
    }
}

