#!/bin/bash

# Script de despliegue en OCI
# VM: 144.22.43.202
# Usuario: ubuntu
# Ejecutar desde Git Bash

set -e

echo "=========================================="
echo "  DESPLIEGUE LEVELUP EN OCI"
echo "=========================================="

OCI_HOST="144.22.43.202"
OCI_USER="ubuntu"
PROJECT_DIR="/home/ubuntu/levelup"
SSH_KEY="/c/Users/SoraR/Downloads/oracle.ppk"

# Convertir clave PPK a formato OpenSSH si es necesario
if [ -f "$SSH_KEY" ] && ! grep -q "BEGIN OPENSSH PRIVATE KEY" "$SSH_KEY" 2>/dev/null; then
    echo "Nota: La clave está en formato PuTTY (.ppk)"
    echo "Necesitas convertirla a formato OpenSSH usando PuTTYgen:"
    echo "  1. Abre PuTTYgen"
    echo "  2. Load -> oracle.ppk"
    echo "  3. Conversions -> Export OpenSSH key"
    echo "  4. Guarda como: oracle_openssh"
    echo ""
    read -p "¿Ya tienes la clave en formato OpenSSH? (s/n): " respuesta
    if [ "$respuesta" != "s" ]; then
        echo "Por favor, convierte la clave y ejecuta el script nuevamente"
        exit 1
    fi
    read -p "Ingresa la ruta de la clave OpenSSH: " SSH_KEY
fi

echo ""
echo "NOTA: Los servicios ya están compilados"
echo "Si necesitas recompilar, ejecuta: ./build-all.bat"
echo ""

echo "1. Creando archivo de configuración nginx..."
echo "----------------------------------------"

cat > nginx.conf << 'EOF'
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
            try_files $uri $uri/ /index.html;
        }

        # API Gateway proxy
        location /api/ {
            proxy_pass http://api-gateway:8080/api/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
    }
}
EOF

echo ""
echo "2. Creando estructura en OCI..."
echo "----------------------------------------"

# Usar la clave SSH
SSH_OPTS="-i $SSH_KEY -o StrictHostKeyChecking=no"

echo "Creando directorios..."
ssh $SSH_OPTS ${OCI_USER}@${OCI_HOST} "mkdir -p ${PROJECT_DIR}/{LevelUp_Api_gateway,LevelUp_Auth_service,LevelUp_User_service,LevelUp_Product_service,LevelUp_Order_service,LevelUp_Analytics_service,LevelUp_Notification_service,LevelUp_File_service,LevelUp_Config_service}/target ${PROJECT_DIR}/level-up/build ${PROJECT_DIR}/BD_tablas"

echo ""
echo "3. Subiendo archivos a OCI..."
echo "----------------------------------------"

echo "  - docker-compose.yml"
scp $SSH_OPTS docker-compose.yml ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/

echo "  - nginx.conf"
scp $SSH_OPTS nginx.conf ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/

echo "  - Scripts SQL"
scp $SSH_OPTS -r BD_tablas/* ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/BD_tablas/

echo ""
echo "4. Subiendo microservicios..."
echo "----------------------------------------"

services=(
    "LevelUp_Api_gateway"
    "LevelUp_Auth_service"
    "LevelUp_User_service"
    "LevelUp_Product_service"
    "LevelUp_Order_service"
    "LevelUp_Analytics_service"
    "LevelUp_Notification_service"
    "LevelUp_File_service"
    "LevelUp_Config_service"
)

for service in "${services[@]}"; do
    echo "  - $service"
    jar_file=$(find ${service}/target -name "*-SNAPSHOT.jar" ! -name "*-original.jar" | head -n 1)
    if [ -n "$jar_file" ]; then
        scp $SSH_OPTS "$jar_file" ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/${service}/target/
    else
        echo "    ⚠ No se encontró JAR para $service"
    fi
done

echo ""
echo "5. Subiendo frontend..."
echo "----------------------------------------"
scp $SSH_OPTS -r level-up/build/* ${OCI_USER}@${OCI_HOST}:${PROJECT_DIR}/level-up/build/

echo ""
echo "6. Configurando y ejecutando en OCI..."
echo "----------------------------------------"

ssh $SSH_OPTS ${OCI_USER}@${OCI_HOST} << 'ENDSSH'
cd /home/ubuntu/levelup

# Detener contenedores existentes
echo "Deteniendo contenedores existentes..."
docker-compose down -v 2>/dev/null || true

# Limpiar imágenes antiguas
echo "Limpiando imágenes antiguas..."
docker system prune -f

# Configurar variables de entorno
export DB_PASSWORD="LevelUp2024!"

# Iniciar servicios
echo "Iniciando servicios con Docker Compose..."
docker-compose up -d

# Esperar a que los servicios estén listos
echo "Esperando a que los servicios inicien..."
sleep 30

# Verificar estado
echo ""
echo "Estado de los contenedores:"
docker-compose ps

echo ""
echo "Logs del API Gateway:"
docker-compose logs --tail=50 api-gateway

ENDSSH

echo ""
echo "=========================================="
echo "  DESPLIEGUE COMPLETADO"
echo "=========================================="
echo ""
echo "Servicios disponibles en:"
echo "  - Frontend: http://${OCI_HOST}"
echo "  - API Gateway: http://${OCI_HOST}:8080"
echo "  - Auth Service: http://${OCI_HOST}:8081"
echo "  - User Service: http://${OCI_HOST}:8082"
echo "  - Product Service: http://${OCI_HOST}:8083"
echo "  - Order Service: http://${OCI_HOST}:8084"
echo "  - Analytics Service: http://${OCI_HOST}:8085"
echo ""
echo "Comandos útiles:"
echo "  Conectar: ssh -i $SSH_KEY ${OCI_USER}@${OCI_HOST}"
echo "  Ver logs: ssh -i $SSH_KEY ${OCI_USER}@${OCI_HOST} 'cd ${PROJECT_DIR} && sudo docker-compose logs -f'"
echo "  Estado:   ssh -i $SSH_KEY ${OCI_USER}@${OCI_HOST} 'cd ${PROJECT_DIR} && sudo docker-compose ps'"
echo ""
