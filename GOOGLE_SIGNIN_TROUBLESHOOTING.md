# Troubleshooting: Google Sign-In Bloqueado en Release

## Paso 1: Instalar y Capturar Logs

### Opción A: Script automático (RECOMENDADO)

```bash
cd /Volumes/Datos/dts-app-ecommerce

# Hacer el script ejecutable
chmod +x CAPTURE_LOGS.sh

# Ejecutar
./CAPTURE_LOGS.sh
```

Esto:
1. Instala el APK release
2. Limpia logs anteriores
3. Inicia captura de logs en tiempo real

### Opción B: Manual con ADB

```bash
# 1. Desinstalar versión anterior
adb uninstall com.osedhelu.dtsdriver

# 2. Instalar el APK release
adb install /Volumes/Datos/dts-app-ecommerce/flutter-driver/build/app/outputs/flutter-apk/app-release.apk

# 3. Limpiar logs
adb logcat --clear

# 4. En UNA TERMINAL: capturar logs completos
adb logcat > release_logs.txt &

# 5. En OTRA TERMINAL: ver logs filtrados en tiempo real
adb logcat | grep -i "firebase\|google\|auth\|error\|blocked"

# 6. Abre la app y presiona el botón de Google Sign-In
# 7. Presiona Ctrl+C para detener los logs
```

---

## Paso 2: Analizar el Mensaje de Error Exacto

Después de capturar los logs, busca:

### Error típico si SHA falta:
```
E/FA    : User ID set to null
E/GoogleSignIn: Exception: Status{statusCode=12500, resolution=null}
```

### Error si hay problema con OAuth:
```
E/FirebaseAuth: An internal error has occurred. [ Requests from this Android client application are blocked ]
```

### Error si API Key está mal:
```
E/GoogleSignIn: Client tried to get multiple credentials
E/Credential: Invalid OAuth client ID
```

---

## Paso 3: Checklist de Debugging

Ejecuta estos comandos para verificar:

### A. Verificar que el APK está instalado correctamente
```bash
adb shell pm list packages | grep dtsdriver
# Debe mostrar: package:com.osedhelu.dtsdriver
```

### B. Verificar que el APK está firmado con la clave correcta
```bash
adb shell pm dump com.osedhelu.dtsdriver | grep -i "signature\|cert"
```

### C. Ver detalles del APK instalado
```bash
adb shell dumpsys package com.osedhelu.dtsdriver | head -20
```

### D. Capturar solo errores críticos
```bash
adb logcat *:E | grep -i "firebase\|google"
```

### E. Ver el logcat desde el principio
```bash
adb logcat -C
```

---

## Paso 4: Comparar Debug vs Release

Para confirmar que el problema es específico de Release:

### Compilar en debug:
```bash
cd /Volumes/Datos/dts-app-ecommerce/flutter-driver
flutter clean
flutter build apk    # (sin --release)
```

### Instalar y probar:
```bash
adb uninstall com.osedhelu.dtsdriver
adb install build/app/outputs/flutter-apk/app-debug.apk

# Capturar logs
adb logcat | grep -i "firebase\|google\|auth"

# Probar Google Sign-In en debug
```

Si funciona en debug pero no en release → problema de certificado (SHA-1/SHA-256)
Si falla en ambos → problema de configuración (OAuth client ID, API key, etc)

---

## Paso 5: Verificar Configuración Firebase

### A. Confirmar app ID correcto
```bash
grep -i "appid\|package" /Volumes/Datos/dts-app-ecommerce/flutter-driver/android/app/google-services.json
```

### B. Confirmar que google-services.json está en el lugar correcto
```bash
ls -la /Volumes/Datos/dts-app-ecommerce/flutter-driver/android/app/google-services.json
```

### C. Revisar firebase_options.dart
```bash
grep -i "appid\|serverClientId" /Volumes/Datos/dts-app-ecommerce/flutter-driver/lib/firebase_options.dart
```

---

## Paso 6: Soluciones Comunes

### Si aún dice "requests from this Android client application are blocked":

#### Opción 1: Esperar más (Firebase propaga en 15-30 min)
- Espera 15 minutos y reinicia la app
- Borra caché de la app: `adb shell pm clear com.osedhelu.dtsdriver`
- Reinstala

#### Opción 2: Verificar que AMBOS SHA-1 y SHA-256 están registrados
```bash
# Verificar en Firebase via MCP (necesita conexión)
# O en Firebase Console: Project Settings → com.osedhelu.dtsdriver → SHA certificates
```

#### Opción 3: Regenerar google-services.json desde Firebase
1. Ve a Firebase Console
2. Descarga nuevo google-services.json
3. Reemplaza en `flutter-driver/android/app/google-services.json`
4. `flutter clean`
5. `flutter build apk --release`
6. Instala y prueba

#### Opción 4: Verificar que el keystore está siendo usado
```bash
# Verificar que el APK está firmado
cd /Volumes/Datos/dts-app-ecommerce/flutter-driver/build/app/outputs/flutter-apk
jarsigner -verify -verbose app-release.apk | head -20
```

---

## Paso 7: Logs de Ejemplo para Buscar

### Logs BUENOS (éxito):
```
D/GoogleSignIn: Signing in with OAuth client ID: 1015036938407-o1lurko8t3vchrta3qa6kbkg9i85usuf.apps.googleusercontent.com
D/FirebaseAuth: Signing in with credentialwith provider GoogleAuthProvider
D/FA: Logging event: ... (signin event)
```

### Logs MALOS (bloqueo):
```
E/FirebaseAuth: An internal error has occurred. [ Requests from this Android client application are blocked ]
E/GoogleSignIn: Status{statusCode=12500, resolution=null}
```

---

## Comando Rápido para Todo

Ejecuta esto en terminal para diagnosticar todo:

```bash
#!/bin/bash
cd /Volumes/Datos/dts-app-ecommerce/flutter-driver

echo "=== VERIFICACIONES PREVIAS ==="
echo "APK existe?"
ls -lh build/app/outputs/flutter-apk/app-release.apk

echo ""
echo "google-services.json existe?"
ls -lh android/app/google-services.json

echo ""
echo "=== INSTALANDO APK ==="
adb uninstall com.osedhelu.dtsdriver
adb install build/app/outputs/flutter-apk/app-release.apk

echo ""
echo "=== VERIFICANDO INSTALACIÓN ==="
adb shell pm list packages | grep dtsdriver

echo ""
echo "=== LIMPIANDO LOGS ==="
adb logcat --clear

echo ""
echo "=== CAPTURANDO LOGS (Ctrl+C para detener) ==="
echo "Abre la app y presiona Google Sign-In en 3... 2... 1..."
sleep 3
adb logcat | grep -i "firebase\|google\|auth\|error\|blocked"
```

Guarda como `diagnose.sh` y ejecuta:
```bash
chmod +x diagnose.sh
./diagnose.sh
```
