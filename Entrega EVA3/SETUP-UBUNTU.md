# Guía de Despliegue en OCI Ubuntu

## 📋 Pasos para desplegar en Ubuntu OCI

### 1️⃣ Conectarse al servidor OCI

```bash
# Desde Git Bash en Windows
ssh -i /c/Users/SoraR/Downloads/oracle_openssh ubuntu@144.22.43.202
```

### 2️⃣ Ejecutar el script de instalación

Una vez conectado al servidor Ubuntu:

```bash
# Descargar el script de setup
curl -O https://raw.githubusercontent.com/ClaudioFranciscoDelgadoGallardo/Front_level_up/ClaudioDev/setup-ubuntu.sh

# Dar permisos de ejecución
chmod +x setup-ubuntu.sh

# Ejecutar el script
./setup-ubuntu.sh
```

El script instalará automáticamente:
- ✅ Docker Engine
- ✅ Docker Compose
- ✅ Git
- ✅ Configuración de firewall (UFW)

### 3️⃣ Reconectar después de la instalación

```bash
# Salir del servidor
exit

# Reconectar (necesario para que los cambios de Docker surtan efecto)
ssh -i /c/Users/SoraR/Downloads/oracle_openssh ubuntu@144.22.43.202
```

### 4️⃣ Clonar el repositorio

```bash
# Crear directorio y clonar
mkdir -p ~/levelup
cd ~/levelup
git clone https://github.com/ClaudioFranciscoDelgadoGallardo/Front_level_up.git
cd Front_level_up
```

### 5️⃣ Subir archivos compilados

Desde tu máquina local (Git Bash), sube los JARs y el frontend:

```bash
cd /c/Users/SoraR/OneDrive/Escritorio/Codigo/Front_level_up/Entrega\ EVA3

# Subir todos los JARs compilados
for service in LevelUp_*_service LevelUp_*_gateway; do
    echo "Subiendo $service..."
    scp -i /c/Users/SoraR/Downloads/oracle_openssh \
        ${service}/target/*-SNAPSHOT.jar \
        ubuntu@144.22.43.202:~/levelup/Front_level_up/${service}/target/ 2>/dev/null || true
done

# Subir frontend compilado
scp -i /c/Users/SoraR/Downloads/oracle_openssh -r \
    level-up/build/* \
    ubuntu@144.22.43.202:~/levelup/Front_level_up/level-up/build/
```

### 6️⃣ Iniciar los servicios con Docker Compose

De vuelta en el servidor Ubuntu:

```bash
cd ~/levelup/Front_level_up

# Configurar variable de entorno
export DB_PASSWORD='LevelUp2024!'

# Iniciar servicios
docker-compose up -d

# Esperar 30 segundos
sleep 30

# Verificar estado
docker-compose ps
```

### 7️⃣ Ver logs

```bash
# Ver todos los logs
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f api-gateway
docker-compose logs -f auth-service

# Ver últimas 50 líneas
docker-compose logs --tail=50 api-gateway
```

### 8️⃣ Verificar el despliegue

```bash
# Verificar que los contenedores están corriendo
docker ps

# Probar el API Gateway
curl http://localhost:8080/actuator/health

# Probar el frontend (desde navegador)
# http://144.22.43.202
```

---

## 🔧 Comandos Útiles

### Gestión de servicios

```bash
# Ver estado
docker-compose ps

# Reiniciar todos los servicios
docker-compose restart

# Reiniciar un servicio específico
docker-compose restart api-gateway

# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v

# Ver logs en tiempo real
docker-compose logs -f

# Ver uso de recursos
docker stats
```

### Actualización del código

```bash
# Hacer pull de los últimos cambios
cd ~/levelup/Front_level_up
git pull origin ClaudioDev

# Reiniciar servicios
docker-compose restart
```

### Limpieza

```bash
# Limpiar contenedores detenidos
docker container prune -f

# Limpiar imágenes no usadas
docker image prune -a -f

# Limpiar todo (cuidado!)
docker system prune -a -f
```

---

## 🌐 URLs de Acceso

Una vez desplegado:

- **Frontend**: http://144.22.43.202
- **API Gateway**: http://144.22.43.202:8080
- **Health Check**: http://144.22.43.202:8080/actuator/health

---

## 🐛 Troubleshooting

### Problema: Servicios no inician

```bash
# Ver logs detallados
docker-compose logs api-gateway
docker-compose logs postgres

# Verificar que PostgreSQL está corriendo
docker-compose ps postgres
```

### Problema: Puerto ya en uso

```bash
# Ver qué está usando el puerto
sudo netstat -tulpn | grep :8080

# Matar el proceso
sudo kill -9 [PID]
```

### Problema: Sin memoria

```bash
# Ver uso de memoria
free -h
docker stats

# Limpiar Docker
docker system prune -a -f
```

### Problema: No puede conectarse a la base de datos

```bash
# Verificar configuración de Supabase en application.properties
# Asegurarse que las credenciales son correctas
```

---

## 📝 Notas

1. **Primera vez**: El script `setup-ubuntu.sh` solo necesita ejecutarse UNA vez
2. **Actualizaciones**: Solo necesitas hacer `git pull` y `docker-compose restart`
3. **Base de datos**: Usa Supabase PostgreSQL (configurado en application.properties)
4. **Memoria**: El servidor tiene límites de memoria configurados en docker-compose.yml
5. **Logs**: Siempre revisa los logs si algo no funciona: `docker-compose logs -f`

---

**Última actualización**: 27 de Noviembre de 2025
