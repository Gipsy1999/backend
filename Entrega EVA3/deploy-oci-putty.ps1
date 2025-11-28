# Script de despliegue en OCI usando PuTTY (plink/pscp)
# VM: 144.22.43.202
# Usuario: ubuntu

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  DESPLIEGUE LEVELUP EN OCI" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$OCI_HOST = "144.22.43.202"
$OCI_USER = "ubuntu"
$PROJECT_DIR = "/home/ubuntu/levelup"
$PPK_KEY = "C:\Users\SoraR\Downloads\oracle.ppk"

# Verificar que la clave existe
if (!(Test-Path $PPK_KEY)) {
    Write-Host "Error: No se encontró la clave SSH en $PPK_KEY" -ForegroundColor Red
    exit 1
}

# Verificar que estamos en el directorio correcto
if (!(Test-Path "docker-compose.yml")) {
    Write-Host "Error: No se encontró docker-compose.yml" -ForegroundColor Red
    Write-Host "Asegúrate de estar en el directorio raíz del proyecto" -ForegroundColor Yellow
    exit 1
}

Write-Host "Usando clave SSH: $PPK_KEY" -ForegroundColor Green
Write-Host ""

Write-Host "1. Compilando servicios Spring Boot..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$services = @(
    "LevelUp_Api_gateway",
    "LevelUp_Auth_service",
    "LevelUp_User_service",
    "LevelUp_Product_service",
    "LevelUp_Order_service",
    "LevelUp_Analytics_service",
    "LevelUp_Notification_service",
    "LevelUp_File_service",
    "LevelUp_Config_service"
)

foreach ($service in $services) {
    Write-Host "Compilando $service..." -ForegroundColor Yellow
    Push-Location $service
    
    # Configurar Maven con menos memoria
    $env:MAVEN_OPTS="-Xmx512m -XX:MaxMetaspaceSize=256m"
    
    if (Test-Path "mvnw.cmd") {
        .\mvnw.cmd clean package -DskipTests -q 2>&1 | Out-Null
    } else {
        mvn clean package -DskipTests -q 2>&1 | Out-Null
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error compilando $service. Reintentando..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        .\mvnw.cmd clean package -DskipTests
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error compilando $service" -ForegroundColor Red
            Pop-Location
            exit 1
        }
    }
    Write-Host "  ✓ $service compilado exitosamente" -ForegroundColor Green
    Pop-Location
    
    # Dar tiempo para liberar memoria
    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host "2. Compilando frontend React..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray
Push-Location level-up
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error compilando frontend" -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location

Write-Host ""
Write-Host "3. Creando archivo de configuración nginx..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$nginxConf = @"
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;
    gzip  on;

    server {
        listen 80;
        server_name _;
        root /usr/share/nginx/html;
        index index.html;

        # Frontend React
        location / {
            try_files `$uri `$uri/ /index.html;
        }

        # API Gateway proxy
        location /api/ {
            proxy_pass http://api-gateway:8080/api/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade `$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
            proxy_cache_bypass `$http_upgrade;
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
    }
}
"@

$nginxConf | Out-File -FilePath "nginx.conf" -Encoding UTF8

Write-Host ""
Write-Host "4. Subiendo archivos a OCI..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

# Crear directorio en OCI
Write-Host "Creando directorio en OCI..." -ForegroundColor Yellow
& plink -batch -i $PPK_KEY ${OCI_USER}@${OCI_HOST} "mkdir -p ${PROJECT_DIR}"

# Subir archivos principales
Write-Host "Subiendo docker-compose.yml..." -ForegroundColor Yellow
& pscp -batch -i $PPK_KEY docker-compose.yml ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/

Write-Host "Subiendo nginx.conf..." -ForegroundColor Yellow
& pscp -batch -i $PPK_KEY nginx.conf ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/

Write-Host "Subiendo scripts SQL..." -ForegroundColor Yellow
& pscp -batch -r -i $PPK_KEY BD_tablas ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/

# Subir servicios compilados
Write-Host "Subiendo servicios compilados..." -ForegroundColor Yellow
foreach ($service in $services) {
    Write-Host "  - $service" -ForegroundColor Cyan
    & plink -batch -i $PPK_KEY ${OCI_USER}@${OCI_HOST} "mkdir -p ${PROJECT_DIR}/${service}/target"
    $jarFiles = Get-ChildItem "${service}/target/*.jar" -File | Where-Object { $_.Name -notlike "*-sources.jar" -and $_.Name -notlike "*-javadoc.jar" }
    foreach ($jar in $jarFiles) {
        & pscp -batch -i $PPK_KEY $jar.FullName ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/${service}/target/
    }
}

# Subir frontend
Write-Host "Subiendo frontend compilado..." -ForegroundColor Yellow
& plink -batch -i $PPK_KEY ${OCI_USER}@${OCI_HOST} "mkdir -p ${PROJECT_DIR}/level-up/build"
& pscp -batch -r -i $PPK_KEY level-up/build/* ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/level-up/build/

Write-Host ""
Write-Host "5. Configurando y ejecutando en OCI..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

& plink -batch -i $PPK_KEY ${OCI_USER}@${OCI_HOST} @"
cd /home/ubuntu/levelup

# Detener contenedores existentes
echo 'Deteniendo contenedores existentes...'
sudo docker-compose down -v 2>/dev/null || true

# Limpiar imágenes antiguas
echo 'Limpiando imágenes antiguas...'
sudo docker system prune -f

# Configurar variables de entorno
export DB_PASSWORD='LevelUp2024!'

# Iniciar servicios
echo 'Iniciando servicios con Docker Compose...'
sudo docker-compose up -d

# Esperar a que los servicios estén listos
echo 'Esperando a que los servicios inicien...'
sleep 30

# Verificar estado
echo ''
echo 'Estado de los contenedores:'
sudo docker-compose ps

echo ''
echo 'Logs del API Gateway:'
sudo docker-compose logs --tail=50 api-gateway
"@

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  DESPLIEGUE COMPLETADO" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Servicios disponibles en:" -ForegroundColor Green
Write-Host "  - Frontend: http://${OCI_HOST}" -ForegroundColor White
Write-Host "  - API Gateway: http://${OCI_HOST}:8080" -ForegroundColor White
Write-Host "  - Auth Service: http://${OCI_HOST}:8081" -ForegroundColor White
Write-Host "  - User Service: http://${OCI_HOST}:8082" -ForegroundColor White
Write-Host "  - Product Service: http://${OCI_HOST}:8083" -ForegroundColor White
Write-Host "  - Order Service: http://${OCI_HOST}:8084" -ForegroundColor White
Write-Host "  - Analytics Service: http://${OCI_HOST}:8085" -ForegroundColor White
Write-Host ""
Write-Host "Para ver los logs:" -ForegroundColor Yellow
Write-Host "  plink -i `"$PPK_KEY`" ${OCI_USER}@${OCI_HOST} 'cd ${PROJECT_DIR} && sudo docker-compose logs -f'" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para acceder al servidor:" -ForegroundColor Yellow
Write-Host "  plink -i `"$PPK_KEY`" ${OCI_USER}@${OCI_HOST}" -ForegroundColor Cyan
Write-Host ""
