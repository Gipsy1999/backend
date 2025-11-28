package levelup.levelup_product_service.config;

import levelup.levelup_product_service.model.Producto;
import levelup.levelup_product_service.repository.ProductoRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);

    @Autowired
    private ProductoRepository productoRepository;

    @Override
    public void run(String... args) {
        if (productoRepository.count() == 0) {
            logger.info("Inicializando productos de ejemplo...");

            // Productos de Consolas
            productoRepository.save(Producto.builder()
                    .nombre("PlayStation 5")
                    .descripcion("Consola de videojuegos de última generación con gráficos en 4K y SSD ultrarrápido")
                    .precio(new BigDecimal("499990"))
                    .categoria("CONSOLAS")
                    .stock(50)
                    .imagenUrl("/images/ps5.jpg")
                    .destacado(true)
                    .activo(true)
                    .marca("Sony")
                    .descuento(BigDecimal.ZERO)
                    .build());

            productoRepository.save(Producto.builder()
                    .nombre("Xbox Series X")
                    .descripcion("La consola Xbox más potente con soporte para 4K nativo y ray tracing")
                    .precio(new BigDecimal("449990"))
                    .categoria("CONSOLAS")
                    .stock(35)
                    .imagenUrl("/images/xbox-series-x.jpg")
                    .destacado(true)
                    .activo(true)
                    .marca("Microsoft")
                    .descuento(BigDecimal.ZERO)
                    .build());

            productoRepository.save(Producto.builder()
                    .nombre("Nintendo Switch OLED")
                    .descripcion("Consola híbrida con pantalla OLED de 7 pulgadas")
                    .precio(new BigDecimal("349990"))
                    .categoria("CONSOLAS")
                    .stock(60)
                    .imagenUrl("/images/switch-oled.jpg")
                    .destacado(true)
                    .activo(true)
                    .marca("Nintendo")
                    .descuento(BigDecimal.ZERO)
                    .build());

            // Videojuegos PS5
            productoRepository.save(Producto.builder()
                    .nombre("God of War Ragnarök")
                    .descripcion("Continúa la épica aventura de Kratos y Atreus en los reinos nórdicos")
                    .precio(new BigDecimal("69990"))
                    .categoria("VIDEOJUEGOS")
                    .stock(100)
                    .imagenUrl("/images/god-of-war.jpg")
                    .destacado(true)
                    .activo(true)
                    .marca("Sony")
                    .descuento(BigDecimal.ZERO)
                    .build());

            productoRepository.save(Producto.builder()
                    .nombre("Spider-Man 2")
                    .descripcion("Los Spider-Men Peter Parker y Miles Morales se enfrentan a nuevas amenazas")
                    .precio(new BigDecimal("69990"))
                    .categoria("VIDEOJUEGOS")
                    .stock(80)
                    .imagenUrl("/images/spiderman2.jpg")
                    .destacado(true)
                    .activo(true)
                    .marca("Sony")
                    .descuento(new BigDecimal("10.00"))
                    .build());

            // Videojuegos Xbox
            productoRepository.save(Producto.builder()
                    .nombre("Halo Infinite")
                    .descripcion("La legendaria saga Halo continúa con una nueva aventura épica")
                    .precio(new BigDecimal("59990"))
                    .categoria("VIDEOJUEGOS")
                    .stock(70)
                    .imagenUrl("/images/halo-infinite.jpg")
                    .destacado(false)
                    .activo(true)
                    .marca("Microsoft")
                    .descuento(new BigDecimal("15.00"))
                    .build());

            productoRepository.save(Producto.builder()
                    .nombre("Forza Horizon 5")
                    .descripcion("Carreras de mundo abierto en los vibrantes paisajes de México")
                    .precio(new BigDecimal("59990"))
                    .categoria("VIDEOJUEGOS")
                    .stock(65)
                    .imagenUrl("/images/forza5.jpg")
                    .destacado(false)
                    .activo(true)
                    .marca("Microsoft")
                    .descuento(BigDecimal.ZERO)
                    .build());

            // Videojuegos Nintendo
            productoRepository.save(Producto.builder()
                    .nombre("The Legend of Zelda: Tears of the Kingdom")
                    .descripcion("Secuela de Breath of the Wild con nuevas mecánicas y aventuras")
                    .precio(new BigDecimal("59990"))
                    .categoria("VIDEOJUEGOS")
                    .stock(90)
                    .imagenUrl("/images/zelda-totk.jpg")
                    .destacado(true)
                    .activo(true)
                    .marca("Nintendo")
                    .descuento(BigDecimal.ZERO)
                    .build());

            productoRepository.save(Producto.builder()
                    .nombre("Super Mario Bros Wonder")
                    .descripcion("El nuevo juego de plataformas 2D de Mario con mecánicas innovadoras")
                    .precio(new BigDecimal("59990"))
                    .categoria("VIDEOJUEGOS")
                    .stock(75)
                    .imagenUrl("/images/mario-wonder.jpg")
                    .destacado(false)
                    .activo(true)
                    .marca("Nintendo")
                    .descuento(BigDecimal.ZERO)
                    .build());

            // Accesorios
            productoRepository.save(Producto.builder()
                    .nombre("DualSense Wireless Controller")
                    .descripcion("Control inalámbrico para PS5 con retroalimentación háptica")
                    .precio(new BigDecimal("69990"))
                    .categoria("ACCESORIOS")
                    .stock(120)
                    .imagenUrl("/images/dualsense.jpg")
                    .destacado(false)
                    .activo(true)
                    .marca("Sony")
                    .descuento(BigDecimal.ZERO)
                    .build());

            productoRepository.save(Producto.builder()
                    .nombre("Xbox Wireless Controller")
                    .descripcion("Control inalámbrico para Xbox Series X|S con diseño ergonómico")
                    .precio(new BigDecimal("59990"))
                    .categoria("ACCESORIOS")
                    .stock(100)
                    .imagenUrl("/images/xbox-controller.jpg")
                    .destacado(false)
                    .activo(true)
                    .marca("Microsoft")
                    .descuento(BigDecimal.ZERO)
                    .build());

            productoRepository.save(Producto.builder()
                    .nombre("Nintendo Switch Pro Controller")
                    .descripcion("Control Pro para Nintendo Switch con mayor duración de batería")
                    .precio(new BigDecimal("69990"))
                    .categoria("ACCESORIOS")
                    .stock(85)
                    .imagenUrl("/images/pro-controller.jpg")
                    .destacado(false)
                    .activo(true)
                    .marca("Nintendo")
                    .descuento(BigDecimal.ZERO)
                    .build());

            productoRepository.save(Producto.builder()
                    .nombre("Headset Pulse 3D")
                    .descripcion("Auriculares inalámbricos para PS5 con audio 3D tempest")
                    .precio(new BigDecimal("99990"))
                    .categoria("ACCESORIOS")
                    .stock(60)
                    .imagenUrl("/images/pulse-3d.jpg")
                    .destacado(false)
                    .activo(true)
                    .marca("Sony")
                    .descuento(BigDecimal.ZERO)
                    .build());

            logger.info("=".repeat(70));
            logger.info("✅ {} productos de ejemplo creados exitosamente", productoRepository.count());
            logger.info("Categorías: CONSOLAS, VIDEOJUEGOS, ACCESORIOS");
            logger.info("Productos destacados: {}", productoRepository.findByDestacadoTrueAndActivoTrue().size());
            logger.info("=".repeat(70));
        } else {
            logger.info("Productos ya existen en la base de datos. Total: {}", productoRepository.count());
        }
    }
}
