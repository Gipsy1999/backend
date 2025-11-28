package levelup.levelup_config_service.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/config")
public class ConfigController {

    @Value("${spring.application.name}")
    private String appName;

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "Config Service");
        response.put("timestamp", String.valueOf(System.currentTimeMillis()));
        return ResponseEntity.ok(response);
    }

    @GetMapping("/info")
    public ResponseEntity<Map<String, String>> info() {
        Map<String, String> response = new HashMap<>();
        response.put("application", appName);
        response.put("version", "1.0.0");
        response.put("description", "Servicio de configuración centralizada");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/services")
    public ResponseEntity<Map<String, Object>> getServices() {
        Map<String, Object> services = new HashMap<>();
        
        Map<String, String> apiGateway = new HashMap<>();
        apiGateway.put("name", "API Gateway");
        apiGateway.put("port", "8080");
        apiGateway.put("url", "http://localhost:8080");
        services.put("api-gateway", apiGateway);
        
        Map<String, String> userService = new HashMap<>();
        userService.put("name", "User Service");
        userService.put("port", "8082");
        userService.put("url", "http://localhost:8082");
        services.put("user-service", userService);
        
        Map<String, String> productService = new HashMap<>();
        productService.put("name", "Product Service");
        productService.put("port", "8083");
        productService.put("url", "http://localhost:8083");
        services.put("product-service", productService);
        
        Map<String, String> orderService = new HashMap<>();
        orderService.put("name", "Order Service");
        orderService.put("port", "8084");
        orderService.put("url", "http://localhost:8084");
        services.put("order-service", orderService);
        
        Map<String, String> analyticsService = new HashMap<>();
        analyticsService.put("name", "Analytics Service");
        analyticsService.put("port", "8085");
        analyticsService.put("url", "http://localhost:8085");
        services.put("analytics-service", analyticsService);
        
        Map<String, String> notificationService = new HashMap<>();
        notificationService.put("name", "Notification Service");
        notificationService.put("port", "8086");
        notificationService.put("url", "http://localhost:8086");
        services.put("notification-service", notificationService);
        
        Map<String, String> fileService = new HashMap<>();
        fileService.put("name", "File Service");
        fileService.put("port", "8087");
        fileService.put("url", "http://localhost:8087");
        services.put("file-service", fileService);
        
        return ResponseEntity.ok(services);
    }
}
