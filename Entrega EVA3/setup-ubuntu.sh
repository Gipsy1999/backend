#!/bin/bash

# Script de instalación y configuración en Ubuntu (OCI)
# Ejecutar como usuario ubuntu (con sudo)

set -e

echo "=========================================="
echo "  SETUP LEVELUP EN UBUNTU OCI"
echo "=========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}1. Actualizando sistema...${NC}"
sudo apt-get update
sudo apt-get upgrade -y

echo ""
echo -e "${GREEN}2. Instalando Docker...${NC}"
# Desinstalar versiones antiguas
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Instalar dependencias
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Agregar Docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Configurar repositorio
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Agregar usuario actual a grupo docker
sudo usermod -aG docker $USER

echo ""
echo -e "${GREEN}3. Instalando Docker Compose...${NC}"
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Crear symlink para docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

echo ""
echo -e "${GREEN}4. Instalando Git...${NC}"
sudo apt-get install -y git

echo ""
echo -e "${GREEN}5. Configurando firewall (UFW)...${NC}"
sudo apt-get install -y ufw

# Permitir SSH
sudo ufw allow 22/tcp

# Permitir HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Permitir puertos de microservicios (opcional, solo para pruebas)
sudo ufw allow 8080:8088/tcp

# Habilitar firewall
sudo ufw --force enable

echo ""
echo -e "${GREEN}6. Creando estructura de directorios...${NC}"
mkdir -p ~/levelup
cd ~/levelup

echo ""
echo -e "${GREEN}7. Configuración de Git...${NC}"
git config --global user.name "Claudio Delgado"
git config --global user.email "tu-email@duoc.cl"

echo ""
echo "=========================================="
echo -e "${GREEN}✓ INSTALACIÓN COMPLETADA${NC}"
echo "=========================================="
echo ""
echo -e "${YELLOW}IMPORTANTE:${NC} Cierra sesión y vuelve a conectar para que los cambios de Docker surtan efecto:"
echo "  exit"
echo ""
echo "Luego, clona el repositorio:"
echo "  cd ~/levelup"
echo "  git clone https://github.com/ClaudioFranciscoDelgadoGallardo/Front_level_up.git"
echo "  cd Front_level_up"
echo ""
echo "Y ejecuta el docker-compose:"
echo "  export DB_PASSWORD='LevelUp2024!'"
echo "  docker-compose up -d"
echo ""
echo "Verificar estado:"
echo "  docker-compose ps"
echo "  docker-compose logs -f"
echo ""
