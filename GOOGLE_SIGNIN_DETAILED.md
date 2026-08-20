# Google Sign-In en flutter-driver - Análisis Completo

## 1. UBICACIÓN DEL LOGIN CON GOOGLE

### Punto de entrada: Login Screen
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/lib/features/auth/presentation/screens/login_screen.dart`

- **Línea 78-79**: Método `_signInWithGoogle()`
  ```dart
  Future<void> _signInWithGoogle() async {
    await _afterAuth(() => ref.read(googleSignInUseCaseProvider).call());
  }
  ```

- **Línea 247-251**: Botón visual de Google Sign-In
  ```dart
  _GoogleSignInButton(
    key: const Key('login_google'),
    isLoading: _isLoading,
    onPressed: _signInWithGoogle,
  ),
  ```

- **Línea 329-372**: Widget `_GoogleSignInButton` personalizado con logo de Google

---

## 2. FLUJO DE EJECUCIÓN DEL LOGIN

### 2.1 Use Case (Domain Layer)
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/lib/features/auth/domain/usecases/google_sign_in_usecase.dart`

**Clase**: `GoogleSignInUseCase`

#### Constructor (líneas 11-23)
```dart
GoogleSignInUseCase(
  this._repository, {
  GoogleSignIn? googleSignIn,
  FirebaseAuth? firebaseAuth,
})  : _googleSignIn = googleSignIn ??
          GoogleSignIn(
            scopes: const ['email'],
            clientId: Platform.isIOS
                ? DefaultFirebaseOptions.ios.iosClientId
                : null,
            serverClientId: DefaultFirebaseOptions.googleServerClientId,
          ),
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
```

**Configuración clave**:
- **iOS**: Usa `iosClientId` de `firebase_options.dart`
- **Android**: No especifica clientId (usa el que está en `google-services.json`)
- **serverClientId** (ambas plataformas): Requerido para obtener `idToken`

#### Método principal: `call()` (líneas 29-56)

```dart
Future<AuthSession> call() async {
  // 1. Cierra sesión previa
  await _clearPreviousGoogleSession();

  // 2. Abre selector de cuentas de Google
  final account = await _googleSignIn.signIn();
  if (account == null) {
    throw StateError('Inicio de sesión con Google cancelado');
  }

  // 3. Obtiene tokens de Google
  final googleAuth = await account.authentication;
  if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
    throw StateError('Google no devolvió idToken (revisa serverClientId)');
  }

  // 4. Crea credencial de Firebase con tokens de Google
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // 5. Autentica en Firebase
  await _firebaseAuth.signInWithCredential(credential);

  // 6. Obtiene token de Firebase
  final idToken = await _firebaseAuth.currentUser?.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw StateError('No se pudo obtener el token de Firebase');
  }

  // 7. Envía token a backend DTS
  return _repository.signInWithGoogle(idToken: idToken);
}
```

**Manejo de sesiones previas** (líneas 58-69):
```dart
Future<void> _clearPreviousGoogleSession() async {
  try {
    await _firebaseAuth.signOut();
  } catch (_) {}
  try {
    await _googleSignIn.signOut();
  } catch (_) {}
  try {
    // En Android fuerza a volver a elegir cuenta (más agresivo que signOut).
    await _googleSignIn.disconnect();
  } catch (_) {}
}
```

---

### 2.2 Repository (Infrastructure Layer)
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/lib/features/auth/infrastructure/repositories/auth_repository_impl.dart`

**Método** (líneas 45-48):
```dart
@override
Future<AuthSession> signInWithGoogle({required String idToken}) async {
  final dto = await _remoteDataSource.signInWithGoogle(idToken: idToken);
  return _persist(dto.toSession());
}
```

**Persistencia** (líneas 67-73):
```dart
Future<AuthSession> _persist(AuthSession session) async {
  await _tokenStorage.saveTokens(
    access: session.accessToken,
    refresh: session.refreshToken,
  );
  return session;
}
```

---

### 2.3 Remote DataSource
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/lib/features/auth/infrastructure/datasources/auth_remote_datasource.dart`

**Método** (líneas 40-57):
```dart
Future<AuthTokensDto> signInWithGoogle({required String idToken}) async {
  try {
    final response = await _dio.post<Map<String, dynamic>>(
      '/accounts/auth/google/',
      data: {
        'id_token': idToken,
        'role': 'driver',  // Importante: especifica rol conductor
      },
    );
    return AuthTokensDto.fromJson(response.data!);
  } on DioException catch (e) {
    final detail = _extractDetail(e.response?.data);
    if (detail != null && detail.isNotEmpty) {
      throw StateError(detail);
    }
    rethrow;
  }
}
```

**Endpoint**: `POST /accounts/auth/google/`

---

### 2.4 Inyección de dependencias (Riverpod)
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/lib/core/di/providers.dart`

**Líneas 93-95**:
```dart
final googleSignInUseCaseProvider = Provider<GoogleSignInUseCase>((ref) {
  return GoogleSignInUseCase(ref.watch(authRepositoryProvider));
});
```

---

## 3. CONFIGURACIÓN FIREBASE

### 3.1 Android: google-services.json
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/android/app/google-services.json`

```json
{
  "project_info": {
    "project_number": "1015036938407",
    "project_id": "dtsdrop-85330",
    "storage_bucket": "dtsdrop-85330.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:1015036938407:android:041cc4084dd2a93008b382",
        "android_client_info": {
          "package_name": "com.osedhelu.dtsdriver"
        }
      },
      "oauth_client": [
        {
          "client_id": "1015036938407-o1lurko8t3vchrta3qa6kbkg9i85usuf.apps.googleusercontent.com",
          "client_type": 1,
          "android_info": {
            "package_name": "com.osedhelu.dtsdriver",
            "certificate_hash": "69f247b9d146aa5268ac8c6e863bcf14a853ffa4"
          }
        },
        {
          "client_id": "1015036938407-3b42tv87mauud225f3vfett7c5rtogof.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "AIzaSyBj-DmYwHfG6kvSKoCF-kqC4tvt3v9pQBI"
        }
      ]
    }
  ],
  "configuration_version": "1"
}
```

**Datos críticos**:
- **Project ID**: `dtsdrop-85330`
- **Project Number**: `1015036938407`
- **Package**: `com.osedhelu.dtsdriver`
- **Mobile SDK App ID**: `1:1015036938407:android:041cc4084dd2a93008b382`

---

### 3.2 Firebase Options (Dart)
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/lib/firebase_options.dart`

```dart
abstract final class DefaultFirebaseOptions {
  /// Web OAuth client (type 3) — required by google_sign_in for ID token.
  static const String googleServerClientId =
      '1015036938407-3b42tv87mauud225f3vfett7c5rtogof.apps.googleusercontent.com';

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBj-DmYwHfG6kvSKoCF-kqC4tvt3v9pQBI',
    appId: '1:1015036938407:android:041cc4084dd2a93008b382',
    messagingSenderId: '1015036938407',
    projectId: 'dtsdrop-85330',
    storageBucket: 'dtsdrop-85330.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAy9TvSRYhYg83Gx9aBaafGNZaTzGTe1Z4',
    appId: '1:1015036938407:ios:659a99afcda1b3cf08b382',
    messagingSenderId: '1015036938407',
    projectId: 'dtsdrop-85330',
    storageBucket: 'dtsdrop-85330.firebasestorage.app',
    iosBundleId: 'com.osedhelu.dtsdriver',
    iosClientId: '1015036938407-8fvoe01ns93vce534lgseo9knquiqq68.apps.googleusercontent.com',
  );
}
```

---

### 3.3 iOS: GoogleService-Info.plist
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/ios/Runner/GoogleService-Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>ANDROID_CLIENT_ID</key>
	<string>1015036938407-o1lurko8t3vchrta3qa6kbkg9i85usuf.apps.googleusercontent.com</string>
	<key>API_KEY</key>
	<string>AIzaSyAy9TvSRYhYg83Gx9aBaafGNZaTzGTe1Z4</string>
	<key>BUNDLE_ID</key>
	<string>com.osedhelu.dtsdriver</string>
	<key>CLIENT_ID</key>
	<string>1015036938407-8fvoe01ns93vce534lgseo9knquiqq68.apps.googleusercontent.com</string>
	<key>GCM_SENDER_ID</key>
	<string>1015036938407</string>
	<key>GOOGLE_APP_ID</key>
	<string>1:1015036938407:ios:659a99afcda1b3cf08b382</string>
	<key>IS_SIGNIN_ENABLED</key>
	<true/>
	<key>PROJECT_ID</key>
	<string>dtsdrop-85330</string>
	<key>REVERSED_CLIENT_ID</key>
	<string>com.googleusercontent.apps.1015036938407-8fvoe01ns93vce534lgseo9knquiqq68</string>
	<key>STORAGE_BUCKET</key>
	<string>dtsdrop-85330.firebasestorage.app</string>
</dict>
</plist>
```

---

### 3.4 Firebase JSON (Configuración local)
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/firebase.json`

```json
{
  "auth": {
    "providers": {
      "emailPassword": true,
      "googleSignIn": {
        "oAuthBrandDisplayName": "DTS Driver",
        "supportEmail": "osedhelu@gmail.com"
      }
    }
  }
}
```

---

## 4. CONFIGURACIÓN ANDROID

### 4.1 build.gradle.kts (App Module)
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/android/app/build.gradle.kts`

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // Plugin Firebase
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.osedhelu.dtsdriver"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.osedhelu.dtsdriver"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")  // TODO: cambiar en release
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

**Plugins clave**:
- `com.google.gms.google-services` (versión 4.4.2 en `settings.gradle.kts`)

---

### 4.2 build.gradle.kts (Root)
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/android/build.gradle.kts`

```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

---

### 4.3 AndroidManifest.xml (Main)
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <application
        android:label="DTS Driver"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Google Maps API Key (same as Firebase) -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="AIzaSyBj-DmYwHfG6kvSKoCF-kqC4tvt3v9pQBI" />
        
        <!-- MainActivity configuration -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            ...
        />
    </application>
</manifest>
```

**Permisos para Google Sign-In**:
- No se especifican directamente; `google_sign_in` plugin maneja esto automáticamente

---

### 4.4 gradle.properties
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/android/gradle.properties`

```
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
```

---

## 5. CONFIGURACIÓN iOS

### 5.1 Info.plist
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/ios/Runner/Info.plist`

**Configuración de Google Sign-In** (líneas 64-78):
```xml
<key>GMSApiKey</key>
<string>AIzaSyAy9TvSRYhYg83Gx9aBaafGNZaTzGTe1Z4</string>

<key>GIDClientID</key>
<string>1015036938407-8fvoe01ns93vce534lgseo9knquiqq68.apps.googleusercontent.com</string>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.1015036938407-8fvoe01ns93vce534lgseo9knquiqq68</string>
        </array>
    </dict>
</array>
```

**Bundle ID**: `com.osedhelu.dtsdriver`

**Configuraciones de permisos** (líneas 53-58):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para marcarte como conductor disponible...</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para el seguimiento de entregas...</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a tus fotos para actualizar tu foto de perfil...</string>
```

---

## 6. DEPENDENCIAS PUB

### pubspec.yaml
**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/pubspec.yaml`

```yaml
dependencies:
  firebase_core: ^3.15.2
  firebase_auth: ^5.7.0
  google_sign_in: ^6.2.2        # Google Sign-In
  sign_in_with_apple: ^7.0.1    # Apple Sign-In (iOS only)
  firebase_messaging: ^15.1.3
  dio: ^5.7.0
  flutter_riverpod: ^2.5.1
  crypto: ^3.0.7                # Para hash SHA-256 (Apple nonce)
```

---

## 7. SHA CERTIFICATES

### Android Debug SHA-1
**Ubicación**: En `google-services.json`

```
69f247b9d146aa5268ac8c6e863bcf14a853ffa4
```

**Nota**: El archivo `build.gradle.kts` usa:
```kotlin
signingConfig = signingConfigs.getByName("debug")
```

Para **release**, necesitas:
1. Generar keystore
2. Obtener SHA-1 del keystore
3. Registrar en Google Cloud Console
4. Actualizar `build.gradle.kts`

**Cómo obtener SHA-1 de release**:
```bash
keytool -list -v -keystore /path/to/release.jks
```

---

### iOS
No usa SHA certificates de la forma Android. Usa:
- **Bundle ID**: `com.osedhelu.dtsdriver`
- **URL Scheme**: `com.googleusercontent.apps.1015036938407-8fvoe01ns93vce534lgseo9knquiqq68`
- **Provisioning Profile**: Manejado por Xcode

---

## 8. DIFERENCIAS DEBUG vs RELEASE

### Android
| Aspecto | Debug | Release |
|--------|-------|---------|
| SHA Certificate | `69f247b9d146aa5268ac8c6e863bcf14a853ffa4` | ⚠️ Necesita generarse |
| Signing Config | `signingConfigs.getByName("debug")` | ⚠️ TODO en build.gradle.kts |
| Firebase Config | Mismo (google-services.json) | Mismo |
| Google Client ID | Mismo (1015036938407-o1lurko8t3vchrta3qa6kbkg9i85usuf...) | Mismo (si SHA es idéntica) |

### iOS
| Aspecto | Debug | Release |
|--------|-------|---------|
| Bundle ID | `com.osedhelu.dtsdriver` | `com.osedhelu.dtsdriver` |
| URL Scheme | `com.googleusercontent.apps...` | `com.googleusercontent.apps...` |
| GoogleService-Info.plist | Mismo | Mismo |
| Provisioning Profile | Development | Distribution |

---

## 9. FLUJO COMPLETO DEL SIGNIN

```
┌─ Login Screen (_signInWithGoogle) ─┐
│                                     │
├─ GoogleSignInUseCase.call()         │
│  ├─ _clearPreviousGoogleSession()   │
│  │  ├─ FirebaseAuth.signOut()       │
│  │  ├─ GoogleSignIn.signOut()       │
│  │  └─ GoogleSignIn.disconnect()    │
│  │                                   │
│  ├─ GoogleSignIn.signIn()           │ ← Abre selector de cuentas
│  │  └─ Devuelve: GoogleSignInAccount│
│  │                                   │
│  ├─ account.authentication          │ ← Obtiene tokens de Google
│  │  ├─ accessToken                  │
│  │  └─ idToken (validar con serverClientId)
│  │                                   │
│  ├─ GoogleAuthProvider.credential() │ ← Crea credencial
│  │  └─ FirebaseAuth.signInWithCredential()
│  │                                   │
│  ├─ FirebaseAuth.currentUser?.getIdToken()
│  │  └─ idToken de Firebase          │
│  │                                   │
│  └─ AuthRepository.signInWithGoogle(idToken)
│     │                                │
│     ├─ AuthRemoteDataSource         │
│     │  └─ POST /accounts/auth/google/
│     │     Datos: {                  │
│     │       "id_token": idToken,    │
│     │       "role": "driver"        │
│     │     }                         │
│     │                                │
│     ├─ Backend valida idToken       │
│     │  ├─ Verifica Firebase         │
│     │  ├─ Valida que sea conductor  │
│     │  └─ Devuelve access + refresh │
│     │                                │
│     └─ TokenStorage.saveTokens()    │ ← Guarda localmente
│        └─ Flutter Secure Storage    │
│                                     │
└─ PostAuthService.complete()         │ ← Navega a home
```

---

## 10. MANEJO DE ERRORES

### En GoogleSignInUseCase

```dart
// 1. Usuario canceló login
if (account == null) {
  throw StateError('Inicio de sesión con Google cancelado');
}

// 2. No devolvió idToken (problema con serverClientId)
if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
  throw StateError('Google no devolvió idToken (revisa serverClientId)');
}

// 3. Firebase no devolvió token
if (idToken == null || idToken.isEmpty) {
  throw StateError('No se pudo obtener el token de Firebase');
}
```

### En Auth Remote DataSource

```dart
try {
  // POST a /accounts/auth/google/
} on DioException catch (e) {
  final detail = _extractDetail(e.response?.data);
  if (detail != null && detail.isNotEmpty) {
    throw StateError(detail);  // Ej: "Esta cuenta no es de conductor"
  }
  rethrow;
}
```

### En Login Screen

```dart
try {
  await action();
  await ref.read(postAuthServiceProvider).complete(ref);
} on NotADriverException {
  setState(() {
    _error = 'Esta cuenta no es de conductor';
  });
} catch (e) {
  setState(() {
    _error = _friendlyAuthError(e);
  });
}
```

---

## 11. INICIALIZACIÓN DE FIREBASE EN MAIN

**Archivo**: `/Volumes/Datos/dts-app-ecommerce/flutter-driver/lib/main.dart`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  runApp(const ProviderScope(child: DtsDriverApp()));
}
```

---

## 12. RESUMEN DE IDS Y KEYS

| Concepto | Valor |
|----------|-------|
| **Firebase Project ID** | `dtsdrop-85330` |
| **Firebase Project Number** | `1015036938407` |
| **Android Package** | `com.osedhelu.dtsdriver` |
| **iOS Bundle ID** | `com.osedhelu.dtsdriver` |
| **Android App ID (Firebase)** | `1:1015036938407:android:041cc4084dd2a93008b382` |
| **iOS App ID (Firebase)** | `1:1015036938407:ios:659a99afcda1b3cf08b382` |
| **Android Google Client ID (OAuth 2.0)** | `1015036938407-o1lurko8t3vchrta3qa6kbkg9i85usuf.apps.googleusercontent.com` |
| **iOS Google Client ID (OAuth 2.0)** | `1015036938407-8fvoe01ns93vce534lgseo9knquiqq68.apps.googleusercontent.com` |
| **Google Server Client ID (Web/Type 3)** | `1015036938407-3b42tv87mauud225f3vfett7c5rtogof.apps.googleusercontent.com` |
| **Android SHA-1 Certificate (Debug)** | `69f247b9d146aa5268ac8c6e863bcf14a853ffa4` |
| **API Key (Android)** | `AIzaSyBj-DmYwHfG6kvSKoCF-kqC4tvt3v9pQBI` |
| **API Key (iOS)** | `AIzaSyAy9TvSRYhYg83Gx9aBaafGNZaTzGTe1Z4` |
| **iOS URL Scheme** | `com.googleusercontent.apps.1015036938407-8fvoe01ns93vce534lgseo9knquiqq68` |

---

## 13. VALIDACIONES IMPORTANTES

### Checklist de configuración:

- ✅ `google-services.json` copiado en `android/app/`
- ✅ `GoogleService-Info.plist` copiado en `ios/Runner/`
- ✅ `serverClientId` en `GoogleSignInUseCase` (Web OAuth client)
- ✅ `iosClientId` en `firebase_options.dart` para iOS
- ✅ `GIDClientID` en `ios/Runner/Info.plist`
- ✅ URL Scheme en `ios/Runner/Info.plist` (`com.googleusercontent.apps...`)
- ✅ `com.google.gms.google-services` plugin en `build.gradle.kts`
- ✅ Firebase inicializado en `main.dart` ANTES de runApp
- ✅ Rol `driver` enviado en POST a `/accounts/auth/google/`
- ⚠️ SHA-1 de release actualizado en Google Cloud Console

---

## 14. BACKEND API ENDPOINT

### POST /accounts/auth/google/

**Ubicación**: Backend (Django) - `/backend/features/auth/...`

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

**Errores comunes**:
- `"Esta cuenta no es de conductor"` → Firebase user existe pero no tiene rol driver
- `"Token inválido"` → idToken expirado o corrupto
- `401` → idToken no verificado contra Firebase

