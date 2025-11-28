package levelup.levelup_auth_service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuthResponse {

    private String token;
    private String tipo;
    private Long id;
    private String nombre;
    private String apellidos;
    private String correo;
    private String rol;
    private String mensaje;
}

