# Despliegue de LevelUp en Oracle Cloud Infrastructure (OCI)

## 📋 Pre-requisitos

### En tu máquina local (Windows):
- ✅ Java 21 JDK
- ✅ Node.js y npm
- ✅ PuTTY (plink y pscp) - Ya instalado
- ✅ Clave SSH de OCI (`oracle.ppk`) - Descargada en `C:\Users\SoraR\Downloads\`

### En el servidor OCI:
- 🖥️ **IP**: 144.22.43.202
- 👤 **Usuario**: ubuntu
- 🐧 **OS**: Ubuntu 22.04
- 🐳 **Docker** y **Docker Compose** instalados

## 🚀 Despliegue Automático

### Opción 1: Script PowerShell con PuTTY (Recomendado para Windows)

```powershell
cd "C:\Users\SoraR\OneDrive\Escritorio\Codigo\Front_level_up\Entrega EVA3"
.\deploy-oci-putty.ps1
```

Este script:
1. ✅ Compila todos los microservicios Spring Boot (9 servicios)
2. ✅ Compila el frontend React
3. ✅ Genera configuración de nginx
4. ✅ Sube archivos al servidor OCI vía SCP
5. ✅ Ejecuta Docker Compose en el servidor
6. ✅ Verifica el estado de los contenedores

**Tiempo estimado**: 10-15 minutos

### Opción 2: Script Bash (Si tienes WSL o Git Bash)

```bash
cd "/c/Users/SoraR/OneDrive/Escritorio/Codigo/Front_level_up/Entrega EVA3"
chmod +x deploy-oci.sh
./deploy-oci.sh
```

## 🏗️ Arquitectura del Despliegue

```
┌─────────────────────────────────────────────┐
│          Cliente (Navegador)                 │
│   http://144.22.43.202                      │
└─────────────┬───────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────┐
│    Nginx (Puerto 80)                         │
│    - Servidor de archivos estáticos (React) │
│    - Reverse proxy para /api/*              │
└─────────────┬───────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────┐
│    API Gateway (Puerto 8080)                 │
│    Spring Cloud Gateway                      │
└─────────────┬───────────────────────────────┘
              │
    ┌─────────┴─────────┬───────────────────┐
    ▼                   ▼                   ▼
┌──────────┐    ┌──────────────┐    ┌──────────────┐
│   Auth   │    │     User     │    │   Product    │
│ (8081)   │    │    (8082)    │    │    (8083)    │
└────┬─────┘    └──────┬───────┘    └──────┬───────┘
     │                 │                    │
     └─────────────────┼────────────────────┘
                       │
                       ▼
              ┌────────────────┐
              │   PostgreSQL   │
              │   (Supabase)   │
              └────────────────┘
```

## 🎯 Microservicios Desplegados

| Servicio | Puerto | Función |
|----------|--------|---------|
| **Nginx** | 80 | Servidor web y reverse proxy |
| **API Gateway** | 8080 | Enrutamiento de peticiones |
| **Auth Service** | 8081 | Autenticación y autorización |
| **User Service** | 8082 | Gestión de usuarios |
| **Product Service** | 8083 | Catálogo de productos |
| **Order Service** | 8084 | Gestión de órdenes |
| **Analytics Service** | 8085 | Analíticas y reportes |
| **Notification Service** | 8086 | Envío de notificaciones |
| **File Service** | 8087 | Gestión de archivos |
| **Config Service** | 8888 | Configuración centralizada |

## 🔧 Configuración

### Variables de Entorno

Las variables se configuran en el archivo `docker-compose.yml`:

```yaml
environment:
  SPRING_PROFILES_ACTIVE: prod
  SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/levelup_db
  SPRING_DATASOURCE_USERNAME: levelup
  SPRING_DATASOURCE_PASSWORD: ${DB_PASSWORD:-LevelUp2024!}
```

### Base de Datos

El sistema se conecta a **Supabase PostgreSQL**:
- 🌐 Host: `aws-0-us-west-1.pooler.supabase.com:6543`
- 📊 Database: `postgres`
- 👤 Usuario: `postgres.rfyswxkxcxyjnwelzyky`

## 📊 Monitoreo y Logs

### Ver logs de todos los servicios:
```powershell
plink -i "C:\Users\SoraR\Downloads\oracle.ppk" ubuntu@144.22.43.202 "cd /home/ubuntu/levelup && sudo docker-compose logs -f"
```

### Ver logs de un servicio específico:
```powershell
plink -i "C:\Users\SoraR\Downloads\oracle.ppk" ubuntu@144.22.43.202 "cd /home/ubuntu/levelup && sudo docker-compose logs -f api-gateway"
```

### Ver estado de contenedores:
```powershell
plink -i "C:\Users\SoraR\Downloads\oracle.ppk" ubuntu@144.22.43.202 "cd /home/ubuntu/levelup && sudo docker-compose ps"
```

## 🔄 Actualización del Despliegue

Para actualizar la aplicación:

1. **Hacer cambios en el código local**
2. **Ejecutar el script de despliegue nuevamente**:
   ```powershell
   .\deploy-oci-putty.ps1
   ```

El script:
- Recompila automáticamente los servicios modificados
- Sube solo los archivos nuevos
- Reinicia los contenedores con los cambios

## 🛠️ Comandos Útiles

### Acceder al servidor:
```powershell
plink -i "C:\Users\SoraR\Downloads\oracle.ppk" ubuntu@144.22.43.202
```

### Reiniciar un servicio:
```bash
cd /home/ubuntu/levelup
sudo docker-compose restart api-gateway
```

### Detener todos los servicios:
```bash
cd /home/ubuntu/levelup
sudo docker-compose down
```

### Iniciar todos los servicios:
```bash
cd /home/ubuntu/levelup
export DB_PASSWORD="LevelUp2024!"
sudo docker-compose up -d
```

### Ver uso de recursos:
```bash
sudo docker stats
```

## 🔍 Verificación del Despliegue

### 1. Verificar que los contenedores estén corriendo:
```bash
sudo docker-compose ps
```

Todos los servicios deben mostrar estado `Up`.

### 2. Probar el frontend:
Abre en el navegador: `http://144.22.43.202`

### 3. Probar el API Gateway:
```bash
curl http://144.22.43.202:8080/actuator/health
```

Debe responder: `{"status":"UP"}`

### 4. Verificar conectividad con la base de datos:
```bash
sudo docker-compose logs api-gateway | grep -i "postgres"
```

## ⚠️ Troubleshooting

### Problema: Servicios no inician
**Solución**:
```bash
cd /home/ubuntu/levelup
sudo docker-compose logs [servicio-con-error]
```

### Problema: Out of memory
**Solución**: Los límites de memoria están configurados en `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      memory: 140M
```

### Problema: Puerto ya en uso
**Solución**:
```bash
sudo netstat -tulpn | grep [puerto]
sudo kill -9 [PID]
```

### Problema: Base de datos no accesible
**Verificar**:
1. Credenciales de Supabase en `application.properties`
2. Firewall de Supabase permite la IP de OCI
3. Connection pooling configurado correctamente

## 📝 Notas Importantes

1. **Memoria del servidor**: Configurado para uso óptimo con 2GB RAM
2. **JVM Tuning**: Cada servicio usa:
   - `-Xmx110m -Xms64m`: Límites de heap
   - `-XX:+UseSerialGC`: Garbage collector eficiente
   - `-XX:MaxMetaspaceSize=64m`: Límite de metaspace

3. **Persistencia**: La base de datos PostgreSQL local usa un volumen:
   ```yaml
   volumes:
     - postgres_data:/var/lib/postgresql/data
   ```

4. **Healthchecks**: Configurados para reiniciar automáticamente servicios con problemas

## 🎉 URLs de Acceso

Una vez desplegado, accede a:

- 🌐 **Frontend**: http://144.22.43.202
- 🔌 **API Gateway**: http://144.22.43.202:8080
- 📊 **Health Check**: http://144.22.43.202:8080/actuator/health

## 📞 Soporte

Para problemas o consultas:
1. Revisar logs: `sudo docker-compose logs -f`
2. Verificar estado: `sudo docker-compose ps`
3. Reiniciar servicios problemáticos
4. Revisar métricas de recursos del servidor

---

**Última actualización**: 27 de Noviembre de 2025  
**Versión**: 1.0.0
