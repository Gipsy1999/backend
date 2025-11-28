package levelup.levelup_user_service.service;

import levelup.levelup_user_service.entity.Usuario;
import levelup.levelup_user_service.repository.UsuarioRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.Collections;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private static final Logger logger = LoggerFactory.getLogger(CustomUserDetailsService.class);

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        logger.info("loadUserByUsername llamado para: {}", email);

        Usuario usuario = usuarioRepository.findByCorreo(email)
                .orElseThrow(() -> {
                    logger.error("Usuario no encontrado: {}", email);
                    return new UsernameNotFoundException("Usuario no encontrado con email: " + email);
                });

        logger.info("Usuario encontrado - Email: {}, Activo: {}, Rol: {}",
            usuario.getCorreo(), usuario.getActivo(), usuario.getRol());
        logger.info("Hash de contraseña (primeros 30 chars): {}",
            usuario.getPassword().substring(0, Math.min(30, usuario.getPassword().length())));

        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                usuario.getCorreo(),
                usuario.getPassword(),
                usuario.getActivo(),
                true,
                true,
                true,
                getAuthorities(usuario)
        );

        logger.info("UserDetails creado exitosamente para: {}", email);
        return userDetails;
    }

    private Collection<? extends GrantedAuthority> getAuthorities(Usuario usuario) {
        Collection<? extends GrantedAuthority> authorities =
            Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + usuario.getRol()));
        logger.info("Authorities asignadas: {}", authorities);
        return authorities;
    }
}



