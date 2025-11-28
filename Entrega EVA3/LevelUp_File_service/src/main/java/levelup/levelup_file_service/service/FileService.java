package levelup.levelup_file_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Service
public class FileService {

    private static final Logger logger = LoggerFactory.getLogger(FileService.class);

    @Value("${file.upload-dir:uploads}")
    private String uploadDir;

    @Value("${file.allowed-extensions:jpg,jpeg,png,gif,webp}")
    private String allowedExtensions;

    private Path fileStorageLocation;
    private Path productImageLocation;

    public FileService() {
        // Constructor vacío - la inicialización se hace en @PostConstruct si se necesita
    }

    private void initializeStorage() {
        if (fileStorageLocation == null) {
            this.fileStorageLocation = Paths.get(uploadDir).toAbsolutePath().normalize();
            this.productImageLocation = Paths.get(uploadDir, "productos").toAbsolutePath().normalize();

            try {
                Files.createDirectories(this.fileStorageLocation);
                Files.createDirectories(this.productImageLocation);
                logger.info("Directorios de almacenamiento creados: {}", fileStorageLocation);
            } catch (IOException e) {
                logger.error("Error al crear directorio de almacenamiento", e);
                throw new RuntimeException("No se pudo crear el directorio de almacenamiento", e);
            }
        }
    }

    public String storeFile(MultipartFile file) {
        initializeStorage();
        
        String originalFileName = StringUtils.cleanPath(file.getOriginalFilename());
        
        try {
            if (originalFileName.contains("..")) {
                throw new RuntimeException("Nombre de archivo inválido: " + originalFileName);
            }

            String fileExtension = getFileExtension(originalFileName);
            validateFileExtension(fileExtension);

            String fileName = UUID.randomUUID().toString() + "." + fileExtension;

            Path targetLocation = this.fileStorageLocation.resolve(fileName);
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

            logger.info("Archivo guardado: {}", fileName);
            return fileName;
        } catch (IOException e) {
            logger.error("Error al guardar archivo: {}", originalFileName, e);
            throw new RuntimeException("No se pudo guardar el archivo " + originalFileName, e);
        }
    }

    public String storeProductImage(MultipartFile file) {
        initializeStorage();
        
        String originalFileName = StringUtils.cleanPath(file.getOriginalFilename());
        
        try {
            if (originalFileName.contains("..")) {
                throw new RuntimeException("Nombre de archivo inválido");
            }

            String fileExtension = getFileExtension(originalFileName);
            validateFileExtension(fileExtension);

            String fileName = "producto_" + UUID.randomUUID().toString() + "." + fileExtension;

            Path targetLocation = this.productImageLocation.resolve(fileName);
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

            logger.info("Imagen de producto guardada: {}", fileName);
            return fileName;
        } catch (IOException e) {
            logger.error("Error al guardar imagen de producto", e);
            throw new RuntimeException("No se pudo guardar la imagen del producto", e);
        }
    }

    public Resource loadFileAsResource(String fileName) {
        initializeStorage();
        
        try {
            Path filePath = this.fileStorageLocation.resolve(fileName).normalize();
            Resource resource = new UrlResource(filePath.toUri());
            
            if (resource.exists()) {
                return resource;
            } else {
                throw new RuntimeException("Archivo no encontrado: " + fileName);
            }
        } catch (MalformedURLException e) {
            throw new RuntimeException("Archivo no encontrado: " + fileName, e);
        }
    }

    public Resource loadProductImage(String fileName) {
        initializeStorage();
        
        try {
            Path filePath = this.productImageLocation.resolve(fileName).normalize();
            Resource resource = new UrlResource(filePath.toUri());
            
            if (resource.exists()) {
                return resource;
            } else {
                throw new RuntimeException("Imagen no encontrada: " + fileName);
            }
        } catch (MalformedURLException e) {
            throw new RuntimeException("Imagen no encontrada: " + fileName, e);
        }
    }

    public void deleteFile(String fileName) {
        initializeStorage();
        
        try {
            Path filePath = this.fileStorageLocation.resolve(fileName).normalize();
            Files.deleteIfExists(filePath);
            logger.info("Archivo eliminado: {}", fileName);
        } catch (IOException e) {
            logger.error("Error al eliminar archivo: {}", fileName, e);
            throw new RuntimeException("No se pudo eliminar el archivo", e);
        }
    }

    private String getFileExtension(String fileName) {
        int dotIndex = fileName.lastIndexOf('.');
        return dotIndex > 0 ? fileName.substring(dotIndex + 1).toLowerCase() : "";
    }

    private void validateFileExtension(String extension) {
        List<String> allowed = Arrays.asList(allowedExtensions.split(","));
        if (!allowed.contains(extension.toLowerCase())) {
            throw new RuntimeException("Tipo de archivo no permitido: " + extension + 
                    ". Extensiones permitidas: " + allowedExtensions);
        }
    }
}
