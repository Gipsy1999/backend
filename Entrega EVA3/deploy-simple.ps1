# Script simplificado de despliegue en OCI
# Asume que todos los servicios ya están compilados

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  DESPLIEGUE LEVELUP EN OCI" -ForegroundColor Cyan
Write-Host "  (Servicios pre-compilados)" -ForegroundColor Cyan
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

Write-Host "Usando clave SSH: $PPK_KEY" -ForegroundColor Green
Write-Host ""

Write-Host "1. Creando estructura de directorios en OCI..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray
& plink -batch -i $PPK_KEY ${OCI_USER}@${OCI_HOST} "mkdir -p ${PROJECT_DIR}/{LevelUp_Api_gateway,LevelUp_Auth_service,LevelUp_User_service,LevelUp_Product_service,LevelUp_Order_service,LevelUp_Analytics_service,LevelUp_Notification_service,LevelUp_File_service,LevelUp_Config_service}/target ${PROJECT_DIR}/level-up/build ${PROJECT_DIR}/BD_tablas"

Write-Host ""
Write-Host "2. Subiendo archivos de configuración..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

Write-Host "  - docker-compose.yml" -ForegroundColor Cyan
& pscp -batch -i $PPK_KEY docker-compose.yml ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/

Write-Host "  - nginx.conf" -ForegroundColor Cyan
& pscp -batch -i $PPK_KEY nginx.conf ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/

Write-Host "  - Scripts SQL" -ForegroundColor Cyan
& pscp -batch -r -i $PPK_KEY BD_tablas ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/

Write-Host ""
Write-Host "3. Subiendo JARs de microservicios..." -ForegroundColor Green
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
    Write-Host "  - $service" -ForegroundColor Cyan
    $jarFile = Get-ChildItem "${service}/target/*-SNAPSHOT.jar" -File | Where-Object { $_.Name -notlike "*original*" } | Select-Object -First 1
    if ($jarFile) {
        & pscp -batch -i $PPK_KEY $jarFile.FullName ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/${service}/target/
    } else {
        Write-Host "    ⚠ No se encontró JAR para $service" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "4. Subiendo frontend..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray
& pscp -batch -r -i $PPK_KEY level-up/build/* ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/level-up/build/

Write-Host ""
Write-Host "5. Iniciando servicios en OCI..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

& plink -batch -i $PPK_KEY ${OCI_USER}@${OCI_HOST} @"
cd ${PROJECT_DIR}

echo '=========================================='
echo 'Deteniendo contenedores existentes...'
echo '=========================================='
sudo docker-compose down -v 2>/dev/null || true

echo ''
echo '=========================================='
echo 'Limpiando imágenes antiguas...'
echo '=========================================='
sudo docker system prune -f

echo ''
echo '=========================================='
echo 'Iniciando servicios con Docker Compose...'
echo '=========================================='
export DB_PASSWORD='LevelUp2024!'
sudo -E docker-compose up -d

echo ''
echo '=========================================='
echo 'Esperando a que los servicios inicien...'
echo '=========================================='
sleep 30

echo ''
echo '=========================================='
echo 'Estado de los contenedores:'
echo '=========================================='
sudo docker-compose ps

echo ''
echo '=========================================='
echo 'Logs recientes del API Gateway:'
echo '=========================================='
sudo docker-compose logs --tail=30 api-gateway

echo ''
echo '=========================================='
echo 'Verificando servicios...'
echo '=========================================='
echo ''
echo 'Probando API Gateway health:'
curl -s http://localhost:8080/actuator/health || echo 'No disponible aún'

echo ''
echo '=========================================='
echo 'Despliegue completado'
echo '=========================================='
"@

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  ✓ DESPLIEGUE COMPLETADO" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Servicios disponibles:" -ForegroundColor Green
Write-Host "  🌐 Frontend:      http://${OCI_HOST}" -ForegroundColor White
Write-Host "  🔌 API Gateway:   http://${OCI_HOST}:8080" -ForegroundColor White
Write-Host "  🔐 Auth Service:  http://${OCI_HOST}:8081" -ForegroundColor White
Write-Host "  👤 User Service:  http://${OCI_HOST}:8082" -ForegroundColor White
Write-Host "  🛍️  Product:       http://${OCI_HOST}:8083" -ForegroundColor White
Write-Host "  📦 Order:         http://${OCI_HOST}:8084" -ForegroundColor White
Write-Host "  📊 Analytics:     http://${OCI_HOST}:8085" -ForegroundColor White
Write-Host ""
Write-Host "Comandos útiles:" -ForegroundColor Yellow
Write-Host "  Ver logs en OCI" -ForegroundColor Cyan
Write-Host "  Conectar con: plink -i $PPK_KEY ${OCI_USER}@${OCI_HOST}" -ForegroundColor Gray
Write-Host ""
