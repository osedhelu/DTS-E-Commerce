# Google Sign-In en flutter-driver - Análisis Completo

## Resumen Ejecutivo

**Proyecto**: DTS Driver (flutter-driver)  
**Firebase Project**: dtsdrop-85330  
**Package**: com.osedhelu.dtsdriver  
**Estado**: Implementado y funcional en DEBUG  
**Paquete**: google_sign_in ^6.2.2

---

## 1. UBICACIÓN DEL LOGIN CON GOOGLE

### Archivo Principal
- **Ruta**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/lib/features/auth/presentation/screens/login_screen.dart`
- **Línea 78-79**: Método `_signInWithGoogle()`
- **Línea 247-251**: Widget `_GoogleSignInButton` (UI)
- **Línea 329-372**: Componente personalizado del botón

### Punto de Entrada del Flow
```dart
Future<void> _signInWithGoogle() async {
  await _afterAuth(() => ref.read(googleSignInUseCaseProvider).call());
}
```

---

## 2. CÓMO SE EJECUTA EL LOGIN

### Use Case (Lógica Core)
**Archivo**: `lib/features/auth/domain/usecases/google_sign_in_usecase.dart`

1. **Limpia sesiones previas** - Evita caché de sesiones
   - `FirebaseAuth.signOut()`
   - `GoogleSignIn.signOut()`
   - `GoogleSignIn.disconnect()` (especialmente en Android para forzar selector)

2. **Abre selector de cuentas** - `GoogleSignIn.signIn()`
   - Retorna: `GoogleSignInAccount` o `null` si usuario cancela

3. **Obtiene tokens de Google**
   - `account.authentication.accessToken`
   - `account.authentication.idToken` ← **CRÍTICO**: Debe validarse contra serverClientId

4. **Intercambia con Firebase**
   - Crea credencial: `GoogleAuthProvider.credential(accessToken, idToken)`
   - Autentica: `FirebaseAuth.signInWithCredential(credential)`

5. **Obtiene token de Firebase**
   - `FirebaseAuth.currentUser?.getIdToken()` ← Token enviado al backend

6. **Envía a backend DTS**
   - POST `/accounts/auth/google/` con `{ id_token, role: "driver" }`

### Configuración en Constructor
```dart
GoogleSignIn(
  scopes: const ['email'],
  clientId: Platform.isIOS 
    ? DefaultFirebaseOptions.ios.iosClientId  // iOS: OAuth Client ID
    : null,                                   // Android: usa google-services.json
  serverClientId: DefaultFirebaseOptions.googleServerClientId  // Web OAuth (REQUERIDO)
)
```

---

## 3. ARCHIVOS DE CONFIGURACIÓN

### Android: google-services.json
**Ubicación**: `/flutter-driver/android/app/google-services.json`

```json
{
  "project_info": {
    "project_id": "dtsdrop-85330",
    "project_number": "1015036938407"
  },
  "oauth_client": [
    {
      "client_type": 1,  // Native Android
      "client_id": "1015036938407-o1lurko8t3vchrta3qa6kbkg9i85usuf.apps.googleusercontent.com",
      "package_name": "com.osedhelu.dtsdriver",
      "certificate_hash": "69f247b9d146aa5268ac8c6e863bcf14a853ffa4"  // DEBUG SHA-1
    },
    {
      "client_type": 3,  // Web OAuth - REQUERIDO para idToken
      "client_id": "1015036938407-3b42tv87mauud225f3vfett7c5rtogof.apps.googleusercontent.com"
    }
  ]
}
```

### iOS: GoogleService-Info.plist
**Ubicación**: `/flutter-driver/ios/Runner/GoogleService-Info.plist`

```xml
<key>CLIENT_ID</key>
<string>1015036938407-8fvoe01ns93vce534lgseo9knquiqq68.apps.googleusercontent.com</string>
<key>BUNDLE_ID</key>
<string>com.osedhelu.dtsdriver</string>
<key>IS_SIGNIN_ENABLED</key>
<true/>
```

### iOS: Info.plist (URL Scheme)
**Ubicación**: `/flutter-driver/ios/Runner/Info.plist`

```xml
<key>GIDClientID</key>
<string>1015036938407-8fvoe01ns93vce534lgseo9knquiqq68.apps.googleusercontent.com</string>

<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.1015036938407-8fvoe01ns93vce534lgseo9knquiqq68</string>
    </array>
  </dict>
</array>
```

### Firebase Options (Dart)
**Ubicación**: `/flutter-driver/lib/firebase_options.dart`

```dart
static const String googleServerClientId =
    '1015036938407-3b42tv87mauud225f3vfett7c5rtogof.apps.googleusercontent.com';
    // ↑ Web OAuth Client ID (type 3) - REQUERIDO para obtener idToken
```

---

## 4. CONFIGURACIÓN ANDROID BUILD

### build.gradle.kts (App)
**Ubicación**: `/flutter-driver/android/app/build.gradle.kts`

```kotlin
plugins {
  id("com.google.gms.google-services")  // ← Procesa google-services.json
}

android {
  namespace = "com.osedhelu.dtsdriver"
  
  buildTypes {
    release {
      signingConfig = signingConfigs.getByName("debug")  // TODO: cambiar a release
    }
  }
}
```

### build.gradle.kts (Root)
```kotlin
plugins {
  id("com.google.gms.google-services") version "4.4.2"
}
```

### AndroidManifest.xml
**Ubicación**: `/flutter-driver/android/app/src/main/AndroidManifest.xml`

```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="AIzaSyBj-DmYwHfG6kvSKoCF-kqC4tvt3v9pQBI" />
```

**Nota**: Los permisos de Google Sign-In son manejados automáticamente por el plugin.

---

## 5. CONFIGURACIÓN iOS BUILD

### Estructura
- **Bundle ID**: `com.osedhelu.dtsdriver` (en Xcode)
- **GoogleService-Info.plist**: Cargado automáticamente por Firebase SDK
- **Info.plist**: Contiene URL Scheme y Client ID
- **Provisioning**: Managed by Xcode (Development/Distribution)

---

## 6. DEPENDENCIAS (pubspec.yaml)

```yaml
dependencies:
  firebase_core: ^3.15.2
  firebase_auth: ^5.7.0
  google_sign_in: ^6.2.2          # ← Google Sign-In
  sign_in_with_apple: ^7.0.1      # ← Apple Sign-In (iOS)
  crypto: ^3.0.7                   # ← Para SHA-256 hash (Apple)
  flutter_riverpod: ^2.5.1
  dio: ^5.7.0
```

---

## 7. SHA CERTIFICATES

### Android DEBUG
```
69f247b9d146aa5268ac8c6e863bcf14a853ffa4
```
- **Registrado en**: google-services.json
- **Keystore**: ~/.android/debug.keystore (automático)
- **Estado**: Funciona completo

### Android RELEASE
```
⚠️ TODO: Generar
```
- **Requerido para producción**
- **Cómo obtener**:
  ```bash
  keytool -list -v -keystore /path/to/release.jks -alias release
  ```
- **Pasos**:
  1. Generar keystore de release
  2. Obtener SHA-1
  3. Registrar en Google Cloud Console
  4. Actualizar build.gradle.kts
  5. Crear nuevo google-services.json con SHA-1 de release

### iOS
- **No usa SHA-1**
- **Usa**: Bundle ID + URL Scheme (registrados en Info.plist)
- **Provisioning**: Managed by Xcode

---

## 8. DIFERENCIAS DEBUG vs RELEASE

### Android

| Aspecto | DEBUG | RELEASE |
|---------|-------|---------|
| SHA-1 | 69f247b9... | ⚠️ Diferente |
| Signing Config | debug keystore | release.jks (TODO) |
| Firebase Config | google-services.json | Mismo |
| Google Client ID | 1015036938407-o1lurko... | Mismo si SHA igual |
| Google Sign-In | Funciona | Falla si SHA no registrado |

### iOS

| Aspecto | DEBUG | RELEASE |
|---------|-------|---------|
| URL Scheme | com.googleusercontent.apps... | Mismo |
| Bundle ID | com.osedhelu.dtsdriver | Mismo |
| GoogleService-Info.plist | Mismo | Mismo |
| Provisioning Profile | Development | Distribution |
| Google Sign-In | Funciona | Debe funcionar |

---

## 9. BACKEND API ENDPOINT

### Endpoint: POST /accounts/auth/google/

**Ubicación**: Backend (Django) - `/backend/features/auth/`

**Request**:
```json
{
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjNjOTVkZ3NhZTM0MWFlczMxOGQwNjRhNDgyZTJkYWY4ZmY4YTg4MGIiLCJ0eXAiOiJKV1QifQ...",
  "role": "driver"
}
```

**Response**:
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 123,
    "username": "driver_user",
    "email": "driver@example.com",
    "user_role": "driver"
  }
}
```

**Backend valida**:
1. idToken contra Firebase Project
2. Que usuario sea conductor (role = "driver")
3. Crea o actualiza usuario en DTS
4. Genera JWT tokens (access + refresh)

---

## 10. ERRORES COMUNES

### Error 1: "Google no devolvió idToken"
- **Causa**: serverClientId no configurado o incorrecto
- **Solución**: Verificar `DefaultFirebaseOptions.googleServerClientId` es Web OAuth Client (type 3)

### Error 2: "Esta cuenta no es de conductor"
- **Causa**: Usuario existe en Firebase pero sin rol driver
- **Solución**: Backend rechaza - verificar configuración de usuario en Firebase

### Error 3: Google Sign-In falla en RELEASE
- **Causa**: SHA-1 de release no registrado en Google Cloud Console
- **Solución**: Ver sección "SHA Certificates" arriba

### Error 4: iOS URL Scheme error
- **Causa**: CFBundleURLSchemes incorrecto o no registrado
- **Solución**: Verificar Info.plist tiene URL Scheme correcto

### Error 5: Firebase no inicializa
- **Causa**: Firebase.initializeApp() no ejecutado antes de runApp()
- **Solución**: Verificar main.dart línea 34

---

## 11. FLUJO COMPLETO VISUAL

```
1. LoginScreen.build()
   └─ _GoogleSignInButton onPressed
      └─ _signInWithGoogle()

2. GoogleSignInUseCase.call()
   ├─ _clearPreviousGoogleSession()
   ├─ GoogleSignIn.signIn() → GoogleSignInAccount
   ├─ account.authentication → idToken
   ├─ GoogleAuthProvider.credential(accessToken, idToken)
   ├─ FirebaseAuth.signInWithCredential(credential)
   ├─ FirebaseAuth.currentUser?.getIdToken() → firebaseIdToken
   └─ return repository.signInWithGoogle(firebaseIdToken)

3. AuthRepositoryImpl.signInWithGoogle()
   ├─ remoteDataSource.signInWithGoogle(firebaseIdToken)
   └─ tokenStorage.saveTokens(access, refresh)

4. AuthRemoteDataSource.signInWithGoogle()
   └─ POST /accounts/auth/google/
      ├─ id_token: firebaseIdToken
      └─ role: "driver"

5. DTS Backend
   ├─ Verifica idToken contra Firebase
   ├─ Valida que sea conductor
   ├─ Crea/Actualiza usuario DTS
   └─ Retorna: { access_token, refresh_token, user }

6. Flutter Secure Storage
   └─ Guarda tokens localmente

7. PostAuthService.complete()
   └─ Navega a home
```

---

## 12. CHECKLIST DE VALIDACIÓN

- [x] google-services.json en android/app/
- [x] GoogleService-Info.plist en ios/Runner/
- [x] firebase_options.dart generado
- [x] google_sign_in en pubspec.yaml
- [x] firebase_auth en pubspec.yaml
- [x] serverClientId en GoogleSignInUseCase
- [x] iosClientId en firebase_options.dart
- [x] GIDClientID en ios/Runner/Info.plist
- [x] URL Scheme en ios/Runner/Info.plist
- [x] com.google.gms.google-services plugin en build.gradle.kts
- [x] Firebase.initializeApp() en main.dart
- [x] Rol "driver" enviado a backend
- [⚠️] SHA-1 de release en Google Cloud Console (TODO)

---

## 13. RUTAS COMPLETAS DE ARCHIVOS

```
/Volumes/Datos/dts-app-ecommerce/flutter-driver/

CÓDIGO DART:
├─ lib/features/auth/
│  ├─ presentation/screens/login_screen.dart
│  ├─ domain/usecases/google_sign_in_usecase.dart
│  ├─ domain/usecases/apple_sign_in_usecase.dart
│  ├─ infrastructure/repositories/auth_repository_impl.dart
│  └─ infrastructure/datasources/auth_remote_datasource.dart
├─ lib/firebase_options.dart
├─ lib/core/di/providers.dart
└─ lib/main.dart

ANDROID:
├─ android/app/google-services.json
├─ android/app/build.gradle.kts
├─ android/build.gradle.kts
├─ android/app/src/main/AndroidManifest.xml
└─ android/gradle.properties

iOS:
├─ ios/Runner/GoogleService-Info.plist
└─ ios/Runner/Info.plist

CONFIGURACIÓN:
├─ firebase.json
└─ pubspec.yaml
```

---

## 14. IDS Y KEYS CRÍTICOS

| Concepto | Valor |
|----------|-------|
| Firebase Project ID | dtsdrop-85330 |
| Firebase Project Number | 1015036938407 |
| Android Package | com.osedhelu.dtsdriver |
| iOS Bundle ID | com.osedhelu.dtsdriver |
| Android Client ID (type 1) | 1015036938407-o1lurko8t3vchrta3qa6kbkg9i85usuf.apps.googleusercontent.com |
| iOS Client ID (type 1) | 1015036938407-8fvoe01ns93vce534lgseo9knquiqq68.apps.googleusercontent.com |
| **Web Client ID (type 3)** | **1015036938407-3b42tv87mauud225f3vfett7c5rtogof.apps.googleusercontent.com** |
| Android SHA-1 (DEBUG) | 69f247b9d146aa5268ac8c6e863bcf14a853ffa4 |
| iOS URL Scheme | com.googleusercontent.apps.1015036938407-8fvoe01ns93vce534lgseo9knquiqq68 |
| API Key (Android) | AIzaSyBj-DmYwHfG6kvSKoCF-kqC4tvt3v9pQBI |
| API Key (iOS) | AIzaSyAy9TvSRYhYg83Gx9aBaafGNZaTzGTe1Z4 |

---

## 15. NOTAS IMPORTANTES

1. **serverClientId es CRÍTICO**: Sin el Web OAuth Client ID (type 3), Google no devuelve idToken
2. **iOS URL Scheme**: Debe registrarse en Info.plist para que Google pueda retornar al app
3. **SHA-1 de release**: Google Sign-In falla en release si SHA-1 no está registrado
4. **Rol driver**: Backend valida que usuario sea conductor - el frontend envía role="driver"
5. **Flutter Secure Storage**: Los tokens se guardan en KeyChain (iOS) o KeyStore (Android)

---

## 16. PASOS PARA CONFIGURAR RELEASE

1. Generar keystore:
   ```bash
   keytool -genkey -v -keystore ~/dts_release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
   ```

2. Obtener SHA-1:
   ```bash
   keytool -list -v -keystore ~/dts_release.jks -alias release
   ```

3. Registrar en Google Cloud Console:
   - Ir a Credentials
   - Editar Android Client (type 1)
   - Agregar SHA-1 de release
   - Descargar nuevo google-services.json

4. Actualizar build.gradle.kts:
   ```kotlin
   buildTypes {
     release {
       signingConfig = signingConfigs.release
     }
   }
   ```

5. Crear signing config:
   ```kotlin
   signingConfigs {
     release {
       keyStore file("path/to/dts_release.jks")
       keyStorePassword "password"
       keyAlias "release"
       keyPassword "password"
     }
   }
   ```

