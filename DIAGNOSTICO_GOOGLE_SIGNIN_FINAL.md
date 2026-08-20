# Diagnóstico Final: Google Sign-In en DTS Driver Release

## 🔍 PROBLEMA IDENTIFICADO

**La raíz del error es una MISMATCH entre certificados:**

### Lo que pasó:

1. **google-services.json SOLO tiene SHA-1** (línea 89):
   ```json
   "certificate_hash": "aa4df0b8df3de533188ad4d5d5bec021cb4a61ec"  // SHA-1
   ```

2. **No hay SHA-256 en google-services.json** para la app `com.osedhelu.dtsdriver`

3. **La app fue compilada y firmada con AMBOS certificados**, pero Google Play Services solo reconoce el SHA-1 del `google-services.json`

4. **Cuando Firebase Auth intenta validar la app**, Google Cloud Console tiene AMBOS certificados registrados, pero `google-services.json` en Android solo menciona el SHA-1

5. **Resultado:** Conflicto de certificados → `Unknown calling package name 'com.google.android.gms'`

## 📋 Certificados Encontrados

### En google-services.json (android/app/google-services.json):
- ✅ SHA-1: `aa4df0b8df3de533188ad4d5d5bec021cb4a61ec` (línea 89)
- ❌ SHA-256: **FALTA**

### Obtenidos del keystore release:
- ✅ SHA-1: `AA4DF0B8DF3DE533188AD4D5D5BEC021CB4A61EC`
- ✅ SHA-256: `5D44068ADBAE4EA0F8BCEC81AA9515BD6F1D69695ABB598CA0931941A71C87CE`

### En Firebase Console (dtsdrop-85330):
- ✅ SHA-1: Registrado
- ✅ SHA-256: Registrado

## 🔧 Solución

Necesitas **agregar el SHA-256 al google-services.json**:

**Archivo:** `flutter-driver/android/app/google-services.json`

**En la sección de oauth_client para `com.osedhelu.dtsdriver` (línea ~75-95), agrega un nuevo objeto con el SHA-256:**

```json
{
  "client_id": "1015036938407-sk6ujgs2imm61resivhmlmpl4ku6ue16.apps.googleusercontent.com",
  "client_type": 1,
  "android_info": {
    "package_name": "com.osedhelu.dtsdriver",
    "certificate_hash": "5d44068adbae4ea0f8bcec81aa9515bd6f1d69695abb598ca0931941a71c87ce"
  }
}
```

### Pasos exactos:

1. Abre `flutter-driver/android/app/google-services.json`
2. Localiza el bloque `oauth_client` para `com.osedhelu.dtsdriver` (después de la línea 72)
3. Después del objeto SHA-1 (línea 76-91), agrega el SHA-256 **ANTES del objeto client_type 3**
4. Guarda el archivo
5. Reconstruye el APK release:
   ```bash
   cd flutter-driver
   flutter clean
   flutter build apk --release
   ```
6. Reinstala en el dispositivo:
   ```bash
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```
7. Prueba Google Sign-In nuevamente

## 📊 Estado Actual

| Elemento | Estado | Detalle |
|----------|--------|---------|
| SHA-1 en keystore | ✅ Correcto | `AA4DF0B8DF3DE533188AD4D5D5BEC021CB4A61EC` |
| SHA-256 en keystore | ✅ Correcto | `5D44068ADBAE4EA0F8BCEC81AA9515BD6F1D69695ABB598CA0931941A71C87CE` |
| SHA-1 en Firebase Console | ✅ Registrado | Verificado |
| SHA-256 en Firebase Console | ✅ Registrado | Verificado |
| SHA-1 en google-services.json | ✅ Presente | Línea 89 |
| SHA-256 en google-services.json | ❌ **FALTA** | **PROBLEMA** |
| APK release compilado | ✅ Correcto | 66.4MB, firmado correctamente |
| Arquitectura de Google Sign-In | ✅ Correcta | Usa serverClientId y GoogleAuthProvider |

## 🎯 Conclusión

**EL PROBLEMA ES QUE FALTA EL SHA-256 EN google-services.json**

Google Play Services descarga el `google-services.json` durante la ejecución de la app. Cuando usa Firebase Auth y Google Sign-In, valida que el certificado de la app coincida con los certificados declarados en `google-services.json`.

Como `google-services.json` **solo tiene SHA-1**, pero la app fue compilada y firmada con SHA-256, Google Play Services no puede validar el certificado y lanza el error:

```
SecurityException: Unknown calling package name 'com.google.android.gms'
```

**Una vez agregues el SHA-256 a google-services.json y recompiles, el error desaparecerá.**
