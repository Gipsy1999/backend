package levelup.levelup_user_service.dto;

import levelup.levelup_user_service.entity.Usuario;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UsuarioResponse {

    private Long id;
    private String run;
    private String nombre;
    private String apellidos;
    private String correo;
    private String telefono;
    private String direccion;
    private String comuna;
    private String ciudad;
    private String region;
    private String codigoPostal;
    private LocalDate fechaNacimiento;
    private String rol;
    private Boolean activo;
    private Boolean verificado;
    private LocalDateTime ultimoAcceso;
    private LocalDateTime fechaRegistro;
    private LocalDateTime fechaActualizacion;

    public static UsuarioResponse fromEntity(Usuario usuario) {
        return UsuarioResponse.builder()
                .id(usuario.getId())
                .run(usuario.getRun())
                .nombre(usuario.getNombre())
                .apellidos(usuario.getApellidos())
                .correo(usuario.getCorreo())
                .telefono(usuario.getTelefono())
                .direccion(usuario.getDireccion())
                .comuna(usuario.getComuna())
                .ciudad(usuario.getCiudad())
                .region(usuario.getRegion())
                .codigoPostal(usuario.getCodigoPostal())
                .fechaNacimiento(usuario.getFechaNacimiento())
                .rol(usuario.getRol())
                .activo(usuario.getActivo())
                .verificado(usuario.getVerificado())
                .ultimoAcceso(usuario.getUltimoAcceso())
                .fechaRegistro(usuario.getFechaRegistro())
                .fechaActualizacion(usuario.getFechaActualizacion())
                .build();
    }
}

