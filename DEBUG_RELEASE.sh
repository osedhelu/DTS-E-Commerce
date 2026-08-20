#!/bin/bash

# Script para debuguear Google Sign-In en modo RELEASE

set -e

PROJECT_DIR="/Volumes/Datos/dts-app-ecommerce/flutter-driver"
APK_PATH="$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"
PACKAGE_NAME="com.osedhelu.dtsdriver"

echo "================================"
echo "DEBUG: Google Sign-In en RELEASE"
echo "================================"
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Verificar si ADB está disponible
echo -e "${YELLOW}[1/5] Verificando ADB...${NC}"
if ! command -v adb &> /dev/null; then
    echo -e "${RED}ERROR: adb no encontrado. Instala Android SDK tools.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ ADB disponible${NC}"
echo ""

# 2. Verificar si el APK existe
echo -e "${YELLOW}[2/5] Verificando APK release...${NC}"
if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}ERROR: APK no encontrado en: $APK_PATH${NC}"
    echo "Ejecuta: cd $PROJECT_DIR && flutter build apk --release"
    exit 1
fi
echo -e "${GREEN}✓ APK encontrado: $(du -h "$APK_PATH" | cut -f1)${NC}"
echo ""

# 3. Desinstalar versión anterior
echo -e "${YELLOW}[3/5] Desinstalando versión anterior...${NC}"
adb uninstall "$PACKAGE_NAME" || echo "  (no había versión anterior)"
echo -e "${GREEN}✓ Desinstalado${NC}"
echo ""

# 4. Instalar APK release
echo -e "${YELLOW}[4/5] Instalando APK release...${NC}"
adb install "$APK_PATH"
if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Fallo al instalar APK${NC}"
    exit 1
fi
echo -e "${GREEN}✓ APK instalado${NC}"
echo ""

# 5. Limpiar logs anteriores
echo -e "${YELLOW}[5/5] Iniciando captura de logs...${NC}"
adb logcat --clear
echo -e "${GREEN}✓ Logs limpiados${NC}"
echo ""

echo "================================"
echo -e "${GREEN}LISTO PARA PRUEBAS${NC}"
echo "================================"
echo ""
echo "Pasos:"
echo "1. Abre la app en el dispositivo"
echo "2. Intenta hacer login con Google"
echo "3. En OTRA TERMINAL, ejecuta:"
echo "   adb logcat | grep -i 'firebase\|google\|auth\|error'"
echo ""
echo "O ejecuta este comando para capturar logs automáticamente:"
echo "   adb logcat | tee release_logs.txt &"
echo ""
echo "Presiona Ctrl+C cuando hayas terminado"
echo ""

# Iniciar captura de logs
adb logcat
