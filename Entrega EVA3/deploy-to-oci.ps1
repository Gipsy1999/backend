# Script de deployment a OCI
# Uso: .\deploy-to-oci.ps1

param(
    [string]$OCI_IP = "144.22.43.202",
    [string]$SSH_KEY = "$HOME\.ssh\oci-levelup.pem"
)

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║   🚀 LevelUp Deployment to OCI       ║" -ForegroundColor Blue
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Blue

# Validar que existe la clave SSH
if (-not (Test-Path $SSH_KEY)) {
    Write-Host "❌ Error: No se encuentra la clave SSH en $SSH_KEY" -ForegroundColor Red
    exit 1
}

# Validar que se configuró la IP
if ($OCI_IP -eq "TU_IP_PUBLICA_AQUI") {
    Write-Host "❌ Error: Debes configurar la IP de tu instancia OCI" -ForegroundColor Red
    Write-Host "   Edita este script y cambia TU_IP_PUBLICA_AQUI por tu IP real" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n📦 Paso 1/6: Compilando servicios Java..." -ForegroundColor Yellow
& .\build-all.bat
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error compilando servicios" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎨 Paso 2/6: Compilando Frontend React..." -ForegroundColor Yellow
Push-Location level-up
npm ci
npm run build
Pop-Location

Write-Host "`n📁 Paso 3/6: Creando paquete de deployment..." -ForegroundColor Yellow
# Crear directorio temporal
$deployDir = "deploy-package"
if (Test-Path $deployDir) {
    Remove-Item -Recurse -Force $deployDir
}
New-Item -ItemType Directory -Path $deployDir | Out-Null

# Copiar archivos necesarios
Copy-Item docker-compose.yml $deployDir\
Copy-Item nginx.conf $deployDir\
Copy-Item .env $deployDir\
Copy-Item -Recurse BD_tablas $deployDir\

# Copiar JARs compilados
Get-ChildItem -Path . -Filter "LevelUp_*_service" -Directory | ForEach-Object {
    $serviceName = $_.Name
    $targetPath = Join-Path $_.FullName "target"
    if (Test-Path $targetPath) {
        $destPath = Join-Path $deployDir $serviceName
        New-Item -ItemType Directory -Path $destPath -Force | Out-Null
        Copy-Item -Path $targetPath -Destination $destPath -Recurse -Force
    }
}

# Copiar build del frontend
$frontendBuildSrc = "level-up\build"
$frontendBuildDest = "$deployDir\level-up\build"
if (Test-Path $frontendBuildSrc) {
    New-Item -ItemType Directory -Path (Split-Path $frontendBuildDest) -Force | Out-Null
    Copy-Item -Path $frontendBuildSrc -Destination $frontendBuildDest -Recurse -Force
}

Write-Host "`n☁️  Paso 4/6: Subiendo archivos a OCI..." -ForegroundColor Yellow
# Usar SCP para subir archivos
scp -i $SSH_KEY -r "$deployDir\*" "ubuntu@${OCI_IP}:/home/ubuntu/levelup/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error subiendo archivos a OCI" -ForegroundColor Red
    exit 1
}

Write-Host "`n🔧 Paso 5/6: Desplegando en servidor..." -ForegroundColor Yellow
# Ejecutar comandos en el servidor
ssh -i $SSH_KEY "ubuntu@${OCI_IP}" @"
cd /home/ubuntu/levelup
docker compose down
docker system prune -f
docker compose up -d
sleep 30
docker compose ps
echo '`n📋 Últimos logs:'
docker compose logs --tail=20
"@

Write-Host "`n✅ Paso 6/6: Limpiando archivos temporales..." -ForegroundColor Yellow
Remove-Item -Recurse -Force $deployDir

Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   ✅ Despliegue completado!           ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
Write-Host "🌐 Accede a tu aplicación en: http://$OCI_IP" -ForegroundColor Cyan
Write-Host "📊 API Gateway: http://${OCI_IP}:8080" -ForegroundColor Cyan
