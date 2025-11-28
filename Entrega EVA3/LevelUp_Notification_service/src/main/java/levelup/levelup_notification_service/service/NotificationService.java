package levelup.levelup_notification_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@Service
public class NotificationService {

    private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);

    @Autowired(required = false)
    private JavaMailSender mailSender;

    @Value("${email.from:noreply@levelup.cl}")
    private String emailFrom;

    @Value("${email.frontend.url:http://localhost:3000}")
    private String frontendUrl;

    public void enviarEmail(String to, String subject, String body) {
        if (mailSender == null) {
            logger.warn("JavaMailSender no configurado. Email no enviado a: {}", to);
            logger.info("Simulando envío de email:");
            logger.info("  To: {}", to);
            logger.info("  Subject: {}", subject);
            logger.info("  Body: {}", body);
            return;
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(emailFrom);
            message.setTo(to);
            message.setSubject(subject);
            message.setText(body);
            
            mailSender.send(message);
            logger.info("Email enviado exitosamente a: {}", to);
        } catch (Exception e) {
            logger.error("Error al enviar email a {}: {}", to, e.getMessage());
            throw new RuntimeException("Error al enviar email: " + e.getMessage());
        }
    }

    public void enviarEmailBienvenida(String email, String nombre) {
        String subject = "¡Bienvenido a Level Up! 🎮";
        String body = String.format("""
            Hola %s,
            
            ¡Bienvenido a Level Up! Estamos emocionados de tenerte con nosotros.
            
            En Level Up encontrarás los mejores videojuegos, consolas y accesorios gaming.
            
            Algunos beneficios de tu cuenta:
            • Acceso a ofertas exclusivas
            • Seguimiento de tus pedidos
            • Historial de compras
            • Wishlist de productos
            
            ¡Comienza a explorar nuestro catálogo ahora!
            %s
            
            ¡Felices compras!
            Equipo Level Up
            """, nombre, frontendUrl);
        
        enviarEmail(email, subject, body);
    }

    public void enviarEmailConfirmacionOrden(String email, String nombre, Long ordenId, String total) {
        String subject = "Confirmación de Orden #" + ordenId + " - Level Up 🎮";
        String body = String.format("""
            Hola %s,
            
            ¡Gracias por tu compra en Level Up!
            
            Detalles de tu orden:
            • Número de orden: #%d
            • Total: $%s CLP
            • Estado: PENDIENTE
            
            Tu orden está siendo procesada y pronto recibirás actualizaciones sobre su estado.
            
            Puedes ver los detalles completos de tu orden en:
            %s/mis-ordenes
            
            Si tienes alguna pregunta, no dudes en contactarnos.
            
            ¡Gracias por confiar en Level Up!
            Equipo Level Up
            """, nombre, ordenId, total, frontendUrl);
        
        enviarEmail(email, subject, body);
    }

    public void enviarEmailCambioEstadoOrden(String email, String nombre, Long ordenId, String estado) {
        String subject = "Tu orden #" + ordenId + " ha sido " + estado + " - Level Up";
        
        String mensajeEstado = switch (estado) {
            case "PROCESANDO" -> "está siendo preparada para su envío";
            case "ENVIADO" -> "ha sido enviada y está en camino";
            case "ENTREGADO" -> "ha sido entregada. ¡Disfruta tus productos!";
            case "CANCELADO" -> "ha sido cancelada";
            default -> "ha cambiado de estado a: " + estado;
        };
        
        String body = String.format("""
            Hola %s,
            
            Tu orden #%d %s.
            
            Estado actual: %s
            
            Puedes ver los detalles completos en:
            %s/mis-ordenes
            
            ¡Gracias por tu compra!
            Equipo Level Up
            """, nombre, ordenId, mensajeEstado, estado, frontendUrl);
        
        enviarEmail(email, subject, body);
    }

    public void enviarEmailRecuperarPassword(String email, String nombre, String token) {
        String subject = "Recuperar Contraseña - Level Up";
        String resetUrl = frontendUrl + "/reset-password?token=" + token;
        
        String body = String.format("""
            Hola %s,
            
            Hemos recibido una solicitud para restablecer tu contraseña.
            
            Haz clic en el siguiente enlace para crear una nueva contraseña:
            %s
            
            Este enlace expirará en 1 hora.
            
            Si no solicitaste este cambio, puedes ignorar este email.
            
            Saludos,
            Equipo Level Up
            """, nombre, resetUrl);
        
        enviarEmail(email, subject, body);
    }
}
