package levelup.levelup_user_service.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "usuarios")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false, length = 12)
    private String run;

    @Column(nullable = false, length = 50)
    private String nombre;

    @Column(nullable = false, length = 100)
    private String apellidos;

    @Column(unique = true, nullable = false, length = 255)
    private String correo;

    @Column(nullable = false, length = 255)
    private String password;

    @Column(length = 15)
    private String telefono;

    @Column(columnDefinition = "TEXT")
    private String direccion;

    @Column(length = 100)
    private String comuna;

    @Column(length = 100)
    private String ciudad;

    @Column(length = 100)
    private String region;

    @Column(name = "codigo_postal", length = 10)
    private String codigoPostal;

    @Column(name = "fecha_nacimiento")
    private LocalDate fechaNacimiento;

    @Column(nullable = false, length = 20)
    private String rol = "CLIENTE";

    @Column(nullable = false)
    private Boolean activo = true;

    @Column(nullable = false)
    private Boolean verificado = false;

    @Column(name = "token_verificacion", length = 255)
    private String tokenVerificacion;

    @Column(name = "ultimo_acceso")
    private LocalDateTime ultimoAcceso;

    @Column(name = "intentos_fallidos")
    private Integer intentosFallidos = 0;

    @Column(name = "bloqueado_hasta")
    private LocalDateTime bloqueadoHasta;

    @Column(name = "fecha_registro", nullable = false, updatable = false)
    private LocalDateTime fechaRegistro;

    @Column(name = "fecha_actualizacion")
    private LocalDateTime fechaActualizacion;

    @PrePersist
    protected void onCreate() {
        fechaRegistro = LocalDateTime.now();
        fechaActualizacion = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        fechaActualizacion = LocalDateTime.now();
    }

    public enum RolUsuario {
        CLIENTE,
        ADMIN,
        VENDEDOR,
        BODEGUERO
    }

    public RolUsuario getRolEnum() {
        return RolUsuario.valueOf(rol);
    }

    public void setRolEnum(RolUsuario rolUsuario) {
        this.rol = rolUsuario.name();
    }
}

