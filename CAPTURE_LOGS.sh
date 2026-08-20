#!/bin/bash

# Script para capturar logs de Firebase/Google Sign-In en RELEASE

PROJECT_DIR="/Volumes/Datos/dts-app-ecommerce/flutter-driver"
APK_PATH="$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"
PACKAGE_NAME="com.osedhelu.dtsdriver"
LOG_FILE="$PROJECT_DIR/release_debug_$(date +%Y%m%d_%H%M%S).log"

echo "🔍 Iniciando DEBUG de Google Sign-In en RELEASE..."
echo ""

# Paso 1: Instalar APK
echo "📱 Instalando APK release..."
adb uninstall "$PACKAGE_NAME" 2>/dev/null
adb install "$APK_PATH" > /dev/null 2>&1
echo "✓ Instalado"
echo ""

# Paso 2: Limpiar logs
echo "📋 Limpiando logs anteriores..."
adb logcat --clear
echo ""

# Paso 3: Capturar logs en tiempo real
echo "🚀 Capturando logs. Haz login con Google en la app (en otra terminal)..."
echo "📝 Los logs se guardarán en: $LOG_FILE"
echo ""
echo "Filtros activos:"
echo "  • Firebase"
echo "  • Google Sign-In"
echo "  • Auth errors"
echo ""
echo "Presiona Ctrl+C para detener"
echo ""
echo "------- LOGS -------"

# Capturar logs con filtros y guardar
adb logcat | tee "$LOG_FILE" | grep -i -E 'firebase|google|auth|error|exception|blocked' | while read line; do
    # Colorear según el nivel de log
    if [[ $line == *"E/"* ]] || [[ $line == *"ERROR"* ]]; then
        echo -e "\033[0;31m$line\033[0m"  # Rojo
    elif [[ $line == *"W/"* ]] || [[ $line == *"WARN"* ]]; then
        echo -e "\033[1;33m$line\033[0m"  # Amarillo
    else
        echo "$line"
    fi
done

echo ""
echo "------- FIN -------"
echo ""
echo "📁 Logs completos guardados en: $LOG_FILE"
