package levelup.levelup_user_service.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ActualizarUsuarioRequest {

    // Todos los campos son OPCIONALES - solo se actualiza lo que se envía
    
    @Size(max = 12, message = "El RUN debe tener máximo 12 caracteres")
    private String run;

    @Size(max = 50, message = "El nombre debe tener máximo 50 caracteres")
    private String nombre;

    @Size(max = 100, message = "Los apellidos no pueden exceder 100 caracteres")
    private String apellidos;

    @Email(message = "Formato de correo invalido")
    private String correo;

    @Size(min = 6, message = "La contrasena debe tener al menos 6 caracteres")
    private String password;

    @Size(max = 15, message = "El teléfono debe tener máximo 15 caracteres")
    private String telefono;

    private String direccion;

    @Size(max = 100, message = "La comuna debe tener máximo 100 caracteres")
    private String comuna;

    @Size(max = 100, message = "La ciudad debe tener máximo 100 caracteres")
    private String ciudad;

    @Size(max = 100, message = "La región debe tener máximo 100 caracteres")
    private String region;

    @Size(max = 10, message = "El código postal debe tener máximo 10 caracteres")
    private String codigoPostal;

    private LocalDate fechaNacimiento;
}
