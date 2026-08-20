# Google Sign-In en Release - Solución Completa

## El Problema
Google Sign-In se queda pensando en modo RELEASE en Android porque el SHA-1 certificate no está registrado en Firebase.

### Por qué sucede
- **Debug**: Usa `~/.android/debug.keystore` → SHA-1: `69F247B9D146AA5268AC8C6E863BCF14A853FFA4` ✓
- **Release**: Estaba configurado para usar DEBUG también (línea 39 de build.gradle.kts) → SHA-1 mismatch ✗

---

## Solución: 4 Pasos

### ✅ Paso 1: Keystore de Release (YA HECHO)

```bash
keytool -genkey -v -keystore ~/dts_release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias release \
  -storepass dtsapp2024 \
  -keypass dtsapp2024 \
  -dname "CN=DTS,OU=Engineering,O=DTS,L=Bogota,ST=Bogota,C=CO"
```

**Resultado:** `~/dts_release.jks` creado ✓

---

### ✅ Paso 2: SHA-1 del Release (YA GENERADO)

```
SHA-1: AA4DF0B8DF3DE533188AD4D5D5BEC021CB4A61EC
```

---

### ✅ Paso 3: build.gradle.kts Actualizado (YA HECHO)

**Archivo:** `flutter-driver/android/app/build.gradle.kts`

**Cambios:**
- Líneas 35-40: Agregada configuración `signingConfigs.release`
- Línea 39: Cambió de `debug` a `release`

**Nuevas líneas:**
```gradle
signingConfigs {
    release {
        storeFile = file(System.getenv("DTS_RELEASE_KEYSTORE") ?: System.getProperty("user.home") + "/dts_release.jks")
        storePassword = System.getenv("DTS_RELEASE_KEYSTORE_PASSWORD") ?: "dtsapp2024"
        keyAlias = "release"
        keyPassword = System.getenv("DTS_RELEASE_KEY_PASSWORD") ?: "dtsapp2024"
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

---

### ⏳ Paso 4: Registrar SHA-1 en Firebase Console (TU TURNO)

#### A. En Firebase Console:
1. Ve a: https://console.firebase.google.com/
2. Selecciona tu proyecto DTS
3. Ve a: **Project Settings** (engranaje) → **Settings**
4. Tab: **Android apps**
5. Busca: **com.osedhelu.dtsdriver**
6. En "SHA certificate fingerprints", presiona **Add fingerprint**
7. Pega este SHA-1:
   ```
   AA4DF0B8DF3DE533188AD4D5D5BEC021CB4A61EC
   ```
8. **Save** / Guardar

#### B. Descargar google-services.json
1. Haz clic en **Download google-services.json**
2. Reemplaza el archivo en:
   ```
   flutter-driver/android/app/google-services.json
   ```

---

## Paso 5: Compilar y Probar

```bash
cd flutter-driver

# Limpiar build anterior
flutter clean

# Compilar en release
flutter build apk --release

# O, para AAB (Google Play):
flutter build appbundle --release
```

---

## Contraseña del Keystore

Si necesitas en el futuro:

```
Keystore Path: ~/dts_release.jks
Storepass:     dtsapp2024
Keyalias:      release
Keypass:       dtsapp2024
```

---

## Verificar SHA-1 Registrado

Después de subir a Firebase, puedes verificar ejecutando:

```bash
keytool -list -v -keystore ~/dts_release.jks -alias release -storepass dtsapp2024 | grep SHA1
```

Debe aparecer exactamente: `AA:4D:F0:B8:DF:3D:E5:33:18:8A:D4:D5:D5:BE:C0:21:CB:4A:61:EC`

---

## Troubleshooting

### Google Sign-In sigue fallando
- ✓ Verificar que SHA-1 aparece en Firebase Console
- ✓ Esperar 5-10 minutos (Firebase puede tardar en propagar)
- ✓ Limpiar cache: `flutter clean` + rebuild
- ✓ Desinstalar app anterior del dispositivo

### Error: "Keystore password incorrect"
- Usa: `dtsapp2024`
- Si cambiaste, ejecuta: `keytool -list -keystore ~/dts_release.jks`

### APK compilado pero no instala
- Asegurate de desinstalar versión anterior en el dispositivo
- ```bash
  adb uninstall com.osedhelu.dtsdriver
  ```

---

## Diferencia: Debug vs Release

| Aspecto | Debug | Release |
|--------|-------|---------|
| Keystore | `~/.android/debug.keystore` | `~/dts_release.jks` |
| SHA-1 | `69F247B9D146AA5268AC8C6E863BCF14A853FFA4` | `AA4DF0B8DF3DE533188AD4D5D5BEC021CB4A61EC` |
| Compilar | `flutter run` | `flutter build apk --release` |
| Google Sign-In | ✓ Funciona | ✓ Funciona (después de paso 4) |
| Performance | Lento (debug info) | Rápido (optimizado) |

---

## Próximos Pasos

1. **Hoy:** Completa Paso 4 (Firebase Console)
2. **Mañana:** Compilar en release y probar
3. **Confirmar:** Google Sign-In funciona sin quedarse pensando

¡Listo! La app debería funcionar perfectamente en release.
