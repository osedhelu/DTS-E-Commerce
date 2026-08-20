# Google Sign-In en Release: Guía de Testing y Debugging

## TL;DR - Comienza aquí

Ejecuta este comando para diagnosticar automáticamente:

```bash
cd /Volumes/Datos/dts-app-ecommerce/flutter-driver
chmod +x diagnose_release.sh
./diagnose_release.sh
```

El script hará:
1. ✓ Verificar que el APK existe y está firmado
2. ✓ Verificar certificados en google-services.json
3. ✓ Conectar dispositivo Android
4. ✓ Instalar el APK release
5. ✓ Capturar logs en tiempo real

Luego de ejecutar, intenta hacer Google Sign-In en la app.

---

## Problema Actual

El error `firebase_auth/unknown: requests from this Android client application are blocked` persiste en release después de registrar:
- ✅ SHA-1 de release: `AA4DF0B8DF3DE533188AD4D5D5BEC021CB4A61EC`
- ✅ SHA-256 de release: `5D44068ADBAE4EA0F8BCEC81AA9515BD6F1D69695ABB598CA0931941A71C87CE`

---

## Causas Posibles (por probabilidad)

### 🔴 Causa #1: Propagación Firebase (70% probable)
Firebase toma 5-30 minutos en propagar certificados añadidos.
- **Solución:** Espera 15-30 min, luego reinstala e intenta de nuevo.
- **Test:** `./diagnose_release.sh` y espera.

### 🔴 Causa #2: OAuth Client ID incorrecto para Android (15% probable)
El `oauth_client` en google-services.json puede no tener el certificate_hash correcto.
- **Verificar:**
  ```bash
  grep -A 15 '"client_id": "1015036938407-o1lurko8t3vchrta3qa6kbkg9i85usuf"' \
    android/app/google-services.json
  ```
  Debe tener `"certificate_hash": "aa4df0b8df3de533188ad4d5d5bec021cb4a61ec"`

### 🔴 Causa #3: Descarga de google-services.json desactualizado (10% probable)
El archivo en el repositorio es viejo y no tiene los nuevos certificados.
- **Solución:** Descargar nuevo desde Firebase Console
- **Pasos:**
  1. Firebase Console → Project Settings → Android: com.osedhelu.dtsdriver
  2. "Download google-services.json"
  3. Reemplaza en `flutter-driver/android/app/google-services.json`
  4. `flutter clean && flutter build apk --release`

### 🟡 Causa #4: Caché de la app / dispositivo (5% probable)
- **Solución:**
  ```bash
  adb shell pm clear com.osedhelu.dtsdriver
  adb uninstall com.osedhelu.dtsdriver
  adb install build/app/outputs/flutter-apk/app-release.apk
  ```

---

## Paso a Paso: Debugging Completo

### PASO 1: Ejecutar diagnóstico automático (5 min)

```bash
cd /Volumes/Datos/dts-app-ecommerce/flutter-driver
chmod +x diagnose_release.sh
./diagnose_release.sh
```

Luego de que te diga "INICIANDO CAPTURA DE LOGS...":
1. Abre la app en el dispositivo
2. Ve a Login
3. Presiona Google
4. Espera 10 segundos
5. Presiona Ctrl+C para terminar

Revisa el output para saber qué error exacto ves.

### PASO 2: Analizar el mensaje de error (5 min)

Los logs se guardan en: `flutter-driver/debug_logs/google_signin_*.log`

**Si ves:** `requests from this Android client application are blocked`
→ Ir a PASO 3A (Propagación)

**Si ves:** `statusCode=12500`
→ Ir a PASO 3B (OAuth Client)

**Si ves:** `Google no devolvió idToken`
→ Ir a PASO 3C (serverClientId)

**Si ves:** `success` o `authenticated`
→ ¡Google Sign-In FUNCIONA! (problema resuelto)

### PASO 3A: Esperar Propagación Firebase

```bash
echo "Esperando propagación de Firebase..."
for i in {1..10}; do
  echo "Intento $i/10..."
  sleep 60
done

echo "¿Ya pasaron 10 minutos?"
echo "Reinstalando app..."
adb uninstall com.osedhelu.dtsdriver
adb install build/app/outputs/flutter-apk/app-release.apk

echo "Intenta Google Sign-In nuevamente"
```

### PASO 3B: Verificar OAuth Client en google-services.json

```bash
# Ver toda la configuración de oauth_client para dtsdriver
cat android/app/google-services.json | grep -A 50 '"client_id": "1015036938407-o1lurko8t3vchrta3qa6kbkg9i85usuf"' | head -20

# Debe haber una sección así:
# {
#   "client_id": "1015036938407-o1lurko8t3vchrta3qa6kbkg9i85usuf.apps.googleusercontent.com",
#   "client_type": 1,
#   "android_info": {
#     "package_name": "com.osedhelu.dtsdriver",
#     "certificate_hash": "aa4df0b8df3de533188ad4d5d5bec021cb4a61ec"   ← ← ← RELEASE SHA
#   }
# }
```

Si `certificate_hash` NO tiene `aa4df0b8...`:
1. Descarga nuevo google-services.json de Firebase Console
2. Reemplaza el archivo
3. Rebuild: `flutter clean && flutter build apk --release`

### PASO 3C: Verificar serverClientId

```bash
grep -i "googleserverclientid" lib/firebase_options.dart

# Debe ser (Web OAuth client):
# '1015036938407-3b42tv87mauud225f3vfett7c5rtogof.apps.googleusercontent.com'
```

Si es diferente o está vacío → tenemos un problema de configuración. Contacta al team de backend/Firebase.

---

## Comando Rápido: Test en Debug vs Release

Para descartar que sea un problema de certificado:

```bash
# 1. Compilar DEBUG
flutter clean
flutter build apk
adb uninstall com.osedhelu.dtsdriver
adb install build/app/outputs/flutter-apk/app-debug.apk

# 2. Probar Google Sign-In en DEBUG
# Si funciona → problema específico de RELEASE
# Si falla igual → problema de configuración Firebase

# 3. Compilar RELEASE de nuevo
flutter clean
flutter build apk --release
adb uninstall com.osedhelu.dtsdriver
adb install build/app/outputs/flutter-apk/app-release.apk

# 4. Probar Google Sign-In en RELEASE
```

---

## Archivos de Referencia

| Archivo | Ubicación | Función |
|---------|-----------|---------|
| **google-services.json** | `android/app/google-services.json` | Configuración Firebase (tiene los certificate_hash) |
| **firebase_options.dart** | `lib/firebase_options.dart` | Firebase config hardcoded (serverClientId, appId) |
| **GoogleSignInUseCase** | `lib/features/auth/domain/usecases/google_sign_in_usecase.dart` | Lógica de login con Google |
| **build.gradle.kts** | `android/app/build.gradle.kts` | Configuración Gradle (keystore, signing) |
| **Keystore Release** | `~/dts_release.jks` | Archivo que firma el APK (password: dtsapp2024) |

---

## Checklist Final

- [ ] APK release compilado: `flutter build apk --release`
- [ ] SHA-1 registrado en Firebase: `AA4DF0B8...`
- [ ] SHA-256 registrado en Firebase: `5D44068A...`
- [ ] google-services.json tiene ambos SHAs
- [ ] Ejecuté diagnose_release.sh y analicé los logs
- [ ] Esperé 15-30 min para propagación Firebase
- [ ] Reinstalé la app (uninstall + install)
- [ ] Probé Google Sign-In en release

---

## Contacto si nada funciona

Si después de todo esto sigue fallando:

1. Comparte los logs completos (archivo en `debug_logs/`)
2. Indica exactamente qué dice el error en la pantalla
3. Confirma que el APK está firmado correctamente:
   ```bash
   /Users/osedhelu/Library/Android/sdk/build-tools/35.0.0/apksigner verify -verbose \
     build/app/outputs/flutter-apk/app-release.apk
   ```

---

## Referencia: SHA Certificates Actuales

**Debug (funciona):**
- SHA-1: `69F247B9D146AA5268AC8C6E863BCF14A853FFA4`
- SHA-256: `58C84AE2403FD4C3B4AAAEABB99E0F02EB209DD01C0AA3F0813F5299C3487E15`

**Release (registrado recientemente):**
- SHA-1: `AA4DF0B8DF3DE533188AD4D5D5BEC021CB4A61EC` ✅
- SHA-256: `5D44068ADBAE4EA0F8BCEC81AA9515BD6F1D69695ABB598CA0931941A71C87CE` ✅

Ambos deben estar en Firebase Console → Project Settings → Android app → SHA certificate fingerprints
