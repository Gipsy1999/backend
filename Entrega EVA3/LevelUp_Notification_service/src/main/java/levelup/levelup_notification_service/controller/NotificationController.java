package levelup.levelup_notification_service.controller;

import levelup.levelup_notification_service.dto.EmailRequest;
import levelup.levelup_notification_service.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/notificaciones")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @PostMapping("/email/simple")
    public ResponseEntity<Map<String, String>> enviarEmail(@RequestBody EmailRequest request) {
        try {
            notificationService.enviarEmail(request.getTo(), request.getSubject(), request.getBody());
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "Email enviado exitosamente");
            response.put("destinatario", request.getTo());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @PostMapping("/email/bienvenida")
    public ResponseEntity<Map<String, String>> enviarBienvenida(@RequestBody Map<String, String> data) {
        try {
            String email = data.get("email");
            String nombre = data.get("nombre");
            notificationService.enviarEmailBienvenida(email, nombre);
            
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "Email de bienvenida enviado");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @PostMapping("/email/confirmacion-orden")
    public ResponseEntity<Map<String, String>> enviarConfirmacionOrden(@RequestBody Map<String, Object> data) {
        try {
            String email = (String) data.get("email");
            String nombre = (String) data.get("nombre");
            Long ordenId = ((Number) data.get("ordenId")).longValue();
            String total = (String) data.get("total");
            
            notificationService.enviarEmailConfirmacionOrden(email, nombre, ordenId, total);
            
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "Email de confirmación enviado");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @PostMapping("/email/cambio-estado-orden")
    public ResponseEntity<Map<String, String>> enviarCambioEstadoOrden(@RequestBody Map<String, Object> data) {
        try {
            String email = (String) data.get("email");
            String nombre = (String) data.get("nombre");
            Long ordenId = ((Number) data.get("ordenId")).longValue();
            String estado = (String) data.get("estado");
            
            notificationService.enviarEmailCambioEstadoOrden(email, nombre, ordenId, estado);
            
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "Email de cambio de estado enviado");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @PostMapping("/email/recuperar-password")
    public ResponseEntity<Map<String, String>> enviarRecuperarPassword(@RequestBody Map<String, String> data) {
        try {
            String email = data.get("email");
            String nombre = data.get("nombre");
            String token = data.get("token");
            
            notificationService.enviarEmailRecuperarPassword(email, nombre, token);
            
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "Email de recuperación enviado");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "Notification Service");
        response.put("timestamp", String.valueOf(System.currentTimeMillis()));
        return ResponseEntity.ok(response);
    }
}
