# Google Sign-In en Android + Play Store

Checklist para **cada app Android nueva** (o cuando actives Play App Signing) que use Firebase Auth + Google Sign-In.

Incidente real (DTS Customer, jul 2026): la app de Internal testing fallaba con:

```text
firebase_auth/unknown
An internal error has occurred.
Request from this Android client application com.osedhelu.dts are blocked.
```

Causa: la **API key de Android** en Google Cloud solo tenía el SHA-1 de **debug**, no el de **Play App Signing**.

---

## Resumen (3 firmas distintas)

| Firma | Dónde se obtiene | Cuándo se usa |
|-------|------------------|---------------|
| **Debug** | `~/.android/debug.keystore` | `flutter run` (debug) |
| **Upload** | Tu `upload-keystore.jks` / keystore de subida | AAB firmado localmente / `flutter run --release` |
| **Play App Signing** | Play Console → Integridad de la app → Firma de aplicaciones | App instalada desde Play (Internal / producción) |

Google Play **vuelve a firmar** el AAB. El SHA del teléfono **no** es el del upload keystore.

Hay que registrar firmas en **dos sitios**:

1. **Firebase** (crea OAuth clients type 1)
2. **Google Cloud → API key Android** (restricciones de aplicación) ← el que suele olvidarse

---

## Paso 0 — Datos de la app

Anota:

- Package name (ej. `com.osedhelu.dts`)
- Proyecto Firebase (ej. `dtsdrop-85330`)
- Ruta del keystore de upload y alias

---

## Paso 1 — Obtener SHA-1 / SHA-256

### Debug

```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android -keypass android
```

### Upload (keystore de subida)

```bash
keytool -list -v \
  -keystore android/app/upload-keystore.jks \
  -alias upload
```

### Play App Signing (recomendado, desde Play Console)

1. [Google Play Console](https://play.google.com/console) → tu app  
2. **Proteger la app / Integridad de la app** → **Firma de aplicaciones**  
3. Copia **SHA-1** y **SHA-256** del  
   **Certificado de la clave de firma de aplicación** (no el de “clave de subida”)

### Alternativa: SHA desde una APK/XAPK instalada desde Play

```bash
# APK suelta
apksigner verify --print-certs /ruta/app.apk

# XAPK (es un ZIP con splits)
mkdir -p /tmp/app-xapk
unzip -o ~/Downloads/MiApp.xapk -d /tmp/app-xapk
apksigner verify --print-certs /tmp/app-xapk/com.tu.paquete.apk
```

`apksigner` suele estar en:

```text
~/Library/Android/sdk/build-tools/<version>/apksigner
```

Usa el **Signer #1** (DN suele ser `O=Google Inc.`).  
**No** registres el “Source Stamp Signer” en Firebase ni en la API key.

---

## Paso 2 — Firebase Console (OAuth)

1. Firebase → **Configuración del proyecto** → tu app Android  
2. **Agregar huella digital** para cada SHA-1 (y opcionalmente SHA-256):
   - Debug  
   - Upload  
   - Play App Signing  
3. Descarga de nuevo `google-services.json` y reemplázalo en  
   `android/app/google-services.json`
4. Confirma que aparece un `oauth_client` con `"client_type": 1` por cada SHA-1.

También:

- Authentication → **Método de acceso** → **Google** → Habilitado  
- Correo de asistencia del proyecto configurado  

---

## Paso 3 — Google Cloud API key (crítico)

Firebase registra los SHA, pero la **API key** de Identity Toolkit puede seguir bloqueando el cliente.

1. [Google Cloud Console](https://console.cloud.google.com/) → proyecto Firebase  
2. **APIs y servicios** → **Credenciales**  
3. Abre la clave tipo Android de esa app, p. ej.  
   `dtsdrop, for com.osedhelu.dts (auto created by Firebase)`  
   (debe coincidir con `api_key.current_key` de `google-services.json`)
4. **Restricciones de aplicaciones** → **Apps para Android**
5. **Agregar** una fila por cada combinación:

| Nombre del paquete | SHA-1 |
|--------------------|-------|
| `com.tu.paquete` | Debug |
| `com.tu.paquete` | Upload |
| `com.tu.paquete` | Play App Signing |

6. En **APIs a las que se puede acceder**, asegúrate de incluir al menos:
   - Identity Toolkit API  
   - Token Service API  
7. **Guardar**  
8. Esperar **hasta 5 minutos** (a veces más) antes de probar.

### Error típico si falta este paso

```text
Request from this Android client application com.xxx are blocked
```

---

## Paso 4 — Código Flutter (serverClientId)

En Android/iOS, `google_sign_in` debe usar el **Web client (type 3)** como `serverClientId` para obtener un `idToken` válido para Firebase:

```dart
GoogleSignIn(
  scopes: const ['email'],
  serverClientId: DefaultFirebaseOptions.googleServerClientId, // type 3
);
```

El Web client aparece en `google-services.json` como `"client_type": 3`.

Recomendación al crear la credential de Firebase:

```dart
// Preferible: solo idToken (evita algunos firebase_auth/unknown en iOS/Android)
GoogleAuthProvider.credential(idToken: googleIdToken);
```

---

## Paso 5 — Probar con la firma correcta

| Cómo instalas | Firma real | Debe estar en Firebase + API key |
|---------------|------------|-----------------------------------|
| `flutter run` | Debug | Debug |
| `flutter run --release` / APK firmado local | Upload | Upload |
| Play Internal / producción / XAPK de Play | Play App Signing | Play App Signing |

Tras cambiar API key o SHA:

1. Esperar ~5 min  
2. Desinstalar la app del dispositivo  
3. Reinstalar desde el mismo canal que vas a probar  
4. Probar Google Sign-In  

---

## Checklist rápido (copiar por app)

- [ ] Package name correcto en Firebase y en `applicationId`
- [ ] SHA-1 Debug en Firebase + API key
- [ ] SHA-1 Upload en Firebase + API key
- [ ] SHA-1 **Play App Signing** en Firebase + API key (después de crear la app en Play)
- [ ] `google-services.json` actualizado en el repo
- [ ] Google Sign-In habilitado en Firebase Auth
- [ ] `serverClientId` = Web client (type 3)
- [ ] Identity Toolkit API + Token Service API en la API key
- [ ] Probar install desde **Play Internal**, no solo `flutter run`

---

## Referencias DTS Customer

| Ítem | Valor |
|------|--------|
| Package | `com.osedhelu.dts` |
| Firebase | `dtsdrop-85330` |
| App ID Android | `1:1015036938407:android:987797af4288c33c08b382` |
| Play App Signing SHA-1 | `ba3c04fad06dce542d803aaa8b8dcaa0d022915d` |
| Upload SHA-1 | `2ed6518290753f7d1c6ad7882e1f63e9bf0e4e67` |
| API key Cloud | `dtsdrop, for com.osedhelu.dts (auto created by Firebase)` |

Privacidad / review: ver `docs/APP_STORE_CONNECT_REVIEW.md`  
Checklist general de tiendas: `docs/STORE_RELEASE_CHECKLIST.md`
