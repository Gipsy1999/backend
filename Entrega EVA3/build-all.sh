#!/bin/bash

# Script para compilar todos los microservicios de LevelUp
# Autor: Sistema de Deploy LevelUp
# Fecha: 2025

echo "======================================"
echo "  Compilando Microservicios LevelUp"
echo "======================================"
echo ""

# Función para compilar un servicio
compile_service() {
    local service_name=$1
    echo "→ Compilando $service_name..."
    cd "$service_name" || exit 1
    ./mvnw clean package -DskipTests
    local status=$?
    cd ..
    
    if [ $status -eq 0 ]; then
        echo "✓ $service_name compilado exitosamente"
        echo ""
    else
        echo "✗ Error compilando $service_name"
        exit 1
    fi
}

# Lista de servicios a compilar
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

# Compilar cada servicio
for service in "${services[@]}"; do
    compile_service "$service"
done

echo "======================================"
echo "  ✓ Compilación completada"
echo "======================================"
echo ""
echo "Archivos JAR generados:"
find . -name "*-SNAPSHOT.jar" -type f -not -path "*/original/*"
