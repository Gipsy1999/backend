package levelup.levelup_user_service.controller;

import jakarta.validation.Valid;
import levelup.levelup_user_service.dto.*;
import levelup.levelup_user_service.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    // ENDPOINT TEMPORAL PARA DEBUG - ELIMINAR EN PRODUCCIÓN
    @PostMapping("/verificar-hash")
    public ResponseEntity<Map<String, Object>> verificarHash(@RequestBody Map<String, String> request) {
        String password = request.get("password");
        String hash = request.get("hash");

        Map<String, Object> response = new HashMap<>();
        response.put("password", password);
        response.put("hashProporcionado", hash);
        response.put("nuevoHashGenerado", passwordEncoder.encode(password));
        response.put("coincide", passwordEncoder.matches(password, hash));

        return ResponseEntity.ok(response);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest loginRequest) {
        try {
            AuthResponse response = usuarioService.login(loginRequest);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            // Crear respuesta con detalles del error
            ErrorResponse errorResponse = ErrorResponse.builder()
                .message("Error en autenticación: " + e.getMessage())
                .error(e.getClass().getSimpleName())
                .detalle("Correo: " + loginRequest.getCorreo())
                .status(HttpStatus.UNAUTHORIZED.value())
                .build();

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResponse);
        }
    }

    @PostMapping("/registro")
    public ResponseEntity<?> registro(@Valid @RequestBody RegistroRequest registroRequest) {
        try {
            AuthResponse response = usuarioService.registro(registroRequest);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            ErrorResponse errorResponse = ErrorResponse.builder()
                .message("Error en registro: " + e.getMessage())
                .error(e.getClass().getSimpleName())
                .detalle("Correo: " + registroRequest.getCorreo())
                .status(HttpStatus.BAD_REQUEST.value())
                .build();

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'VENDEDOR')")
    public ResponseEntity<UsuarioResponse> obtenerPorId(@PathVariable Long id) {
        try {
            UsuarioResponse response = usuarioService.obtenerPorId(id);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/correo/{correo}")
    @PreAuthorize("hasAnyRole('ADMIN', 'VENDEDOR')")
    public ResponseEntity<UsuarioResponse> obtenerPorCorreo(@PathVariable String correo) {
        try {
            UsuarioResponse response = usuarioService.obtenerPorCorreo(correo);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UsuarioResponse>> listarTodos() {
        List<UsuarioResponse> usuarios = usuarioService.listarTodos();
        return ResponseEntity.ok(usuarios);
    }

    @GetMapping("/activos")
    @PreAuthorize("hasAnyRole('ADMIN', 'VENDEDOR')")
    public ResponseEntity<List<UsuarioResponse>> listarActivos() {
        List<UsuarioResponse> usuarios = usuarioService.listarActivos();
        return ResponseEntity.ok(usuarios);
    }

    @GetMapping("/rol/{rol}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UsuarioResponse>> listarPorRol(@PathVariable String rol) {
        List<UsuarioResponse> usuarios = usuarioService.listarPorRol(rol);
        return ResponseEntity.ok(usuarios);
    }

    @GetMapping("/buscar/{nombre}")
    @PreAuthorize("hasAnyRole('ADMIN', 'VENDEDOR')")
    public ResponseEntity<List<UsuarioResponse>> buscarPorNombre(@PathVariable String nombre) {
        List<UsuarioResponse> usuarios = usuarioService.buscarPorNombre(nombre);
        return ResponseEntity.ok(usuarios);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'CLIENTE')")
    public ResponseEntity<UsuarioResponse> actualizar(@PathVariable Long id,
                                                       @Valid @RequestBody ActualizarUsuarioRequest request) {
        try {
            UsuarioResponse response = usuarioService.actualizar(id, request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> desactivar(@PathVariable Long id) {
        try {
            usuarioService.desactivar(id);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}/permanente")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, String>> eliminarPermanente(@PathVariable Long id) {
        try {
            usuarioService.eliminarPermanente(id);
            Map<String, String> response = new HashMap<>();
            response.put("message", "Usuario eliminado permanentemente");
            response.put("id", id.toString());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @PutMapping("/{id}/activar")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> activar(@PathVariable Long id) {
        try {
            usuarioService.activar(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PutMapping("/{id}/rol/{rol}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> cambiarRol(@PathVariable Long id, @PathVariable String rol) {
        try {
            usuarioService.cambiarRol(id, rol);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/validar")
    public ResponseEntity<Boolean> validarCredenciales(@RequestBody LoginRequest request) {
        try {
            boolean valido = usuarioService.validarCredenciales(request.getCorreo(), request.getPassword());
            return ResponseEntity.ok(valido);
        } catch (Exception e) {
            return ResponseEntity.ok(false);
        }
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "User Service");
        response.put("timestamp", String.valueOf(System.currentTimeMillis()));
        return ResponseEntity.ok(response);
    }
}
