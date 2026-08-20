# Google Sign-In en flutter-driver - Documentación Completa

## Archivos de Análisis Generados

Este análisis exhaustivo de Google Sign-In en flutter-driver contiene 4 documentos complementarios:

### 1. **GOOGLE_SIGNIN_ANALYSIS.md** (Documento Principal)
- **Tipo**: Markdown (16 secciones)
- **Contenido**: Guía técnica completa y concisa
- **Secciones**:
  1. Ubicación del login con Google
  2. Cómo se ejecuta el login
  3. Archivos de configuración (Android/iOS)
  4. Configuración Android Build
  5. Configuración iOS Build
  6. Dependencias (pubspec.yaml)
  7. SHA Certificates (DEBUG & RELEASE)
  8. Diferencias DEBUG vs RELEASE
  9. Backend API Endpoint
  10. Errores comunes y soluciones
  11. Flujo completo visual
  12. Checklist de validación
  13. Rutas completas de archivos
  14. IDs y keys críticos
  15. Notas importantes
  16. Pasos para configurar RELEASE
- **Mejor para**: Referencia rápida y ejecución de tareas

### 2. **GOOGLE_SIGNIN_DETAILED.md** (Documentación Técnica Profunda)
- **Tipo**: Markdown (14 secciones)
- **Contenido**: Análisis exhaustivo con código
- **Secciones**:
  1. Ubicación del login
  2. Flujo de ejecución (con código)
  3. Configuración Firebase (Android/iOS)
  4. Configuración Android Build
  5. AndroidManifest.xml
  6. gradle.properties
  7. Configuración iOS Build
  8. Info.plist configuración
  9. Dependencias Pub
  10. SHA Certificates
  11. Diferencias DEBUG vs RELEASE
  12. Flujo completo
  13. Manejo de errores
  14. Inicialización de Firebase
  15. Resumen de IDs y keys
  16. Validaciones importantes
  17. Backend API endpoint
- **Mejor para**: Entender en profundidad el funcionamiento

### 3. **GOOGLE_SIGNIN_EXECUTIVE_SUMMARY.txt** (Resumen Ejecutivo)
- **Tipo**: Texto plano con formato
- **Contenido**: Información estructurada en tablas y listas
- **Secciones**:
  1. Ubicaciones clave de archivos
  2. Paquetes y dependencias
  3. Configuración Firebase (Android)
  4. Configuración Firebase (iOS)
  5. Configuración Android Build
  6. Configuración iOS Build
  7. Firebase Options (Dart)
  8. Flujo de ejecución
  9. SHA Certificates
  10. Permisos Android
  11. DEBUG vs RELEASE
  12. Errores comunes y soluciones
  13. Validación de configuración
  14. Rutas de archivos completas
- **Mejor para**: Verificación rápida y checklists

### 4. **GOOGLE_SIGNIN_ARCHITECTURE_DIAGRAMS.txt** (Diagramas y Flujos)
- **Tipo**: Texto ASCII art con diagramas
- **Contenido**: Visualización arquitectónica
- **Diagramas**:
  1. Flujo general de capas (Clean Architecture)
  2. Configuración Firebase (Múltiples Clientes OAuth)
  3. Firebase Mobile SDK Configuration
  4. Configuración Android Build System
  5. Configuración iOS Build System
  6. Permissioning & Manifests
  7. Flujo completo de tokens
  8. Error handling chain
  9. Diferencias DEBUG vs RELEASE
- **Mejor para**: Visualizar arquitectura y flujos

---

## Información Resumida

### Ubicación del Login con Google
- **Archivo**: `/flutter-driver/lib/features/auth/presentation/screens/login_screen.dart`
- **Método**: `_signInWithGoogle()` (línea 78)
- **Widget UI**: `_GoogleSignInButton` (líneas 329-372)

### Flujo Principal
1. **LoginScreen** → Llama a GoogleSignInUseCase via Riverpod
2. **GoogleSignInUseCase** → Ejecuta `call()` (limpia sesiones, abre selector, obtiene tokens)
3. **Firebase** → Intercambia tokens de Google por tokens de Firebase
4. **Backend DTS** → POST `/accounts/auth/google/` con idToken y role="driver"
5. **Respuesta** → Recibe access_token + refresh_token
6. **Almacenamiento** → Flutter Secure Storage guarda tokens
7. **Navegación** → Vai a home

### Paquetes Clave
- `google_sign_in: ^6.2.2` - Google Sign-In
- `firebase_auth: ^5.7.0` - Firebase Authentication
- `firebase_core: ^3.15.2` - Firebase Core
- `flutter_riverpod: ^2.5.1` - Inyección de dependencias

### Firebase Project
- **Project ID**: dtsdrop-85330
- **Project Number**: 1015036938407
- **Android Package**: com.osedhelu.dtsdriver
- **iOS Bundle ID**: com.osedhelu.dtsdriver

### SHA Certificates
- **Android DEBUG**: `69f247b9d146aa5268ac8c6e863bcf14a853ffa4` ✓
- **Android RELEASE**: `TODO - Generar keystore de release` ⚠️
- **iOS**: No usa SHA-1 (usa Bundle ID + URL Scheme)

### IDs y Keys Críticos
- **Web OAuth Client ID** (CRÍTICO): `1015036938407-3b42tv87mauud225f3vfett7c5rtogof.apps.googleusercontent.com`
- **Android Client ID**: `1015036938407-o1lurko8t3vchrta3qa6kbkg9i85usuf.apps.googleusercontent.com`
- **iOS Client ID**: `1015036938407-8fvoe01ns93vce534lgseo9knquiqq68.apps.googleusercontent.com`
- **iOS URL Scheme**: `com.googleusercontent.apps.1015036938407-8fvoe01ns93vce534lgseo9knquiqq68`
- **Android API Key**: `AIzaSyBj-DmYwHfG6kvSKoCF-kqC4tvt3v9pQBI`
- **iOS API Key**: `AIzaSyAy9TvSRYhYg83Gx9aBaafGNZaTzGTe1Z4`

---

## Archivos de Configuración

### Android
- `android/app/google-services.json` - Configuración Firebase
- `android/app/build.gradle.kts` - Build config con Google Services plugin
- `android/app/src/main/AndroidManifest.xml` - Permisos y metadata
- `android/gradle.properties` - Gradle properties

### iOS
- `ios/Runner/GoogleService-Info.plist` - Configuración Firebase
- `ios/Runner/Info.plist` - GIDClientID y CFBundleURLSchemes

### Dart
- `lib/firebase_options.dart` - Configuración multiplataforma
- `lib/features/auth/domain/usecases/google_sign_in_usecase.dart` - Lógica principal
- `lib/core/di/providers.dart` - Inyección de dependencias

---

## Estado de la Implementación

### DEBUG (Actual)
- **Android**: ✓ Funciona completo
- **iOS**: ✓ Funciona completo
- **Backend**: ✓ POST `/accounts/auth/google/` configurado

### RELEASE
- **Android**: ✗ Google Sign-In fallará (SHA-1 no registrado)
- **iOS**: ✓ Debe funcionar (URL Scheme + Bundle ID iguales)
- **Acción Requerida**: Generar keystore de release y registrar SHA-1

---

## Hallazgos Principales

1. **serverClientId es CRÍTICO**
   - Sin el Web OAuth Client ID (type 3), Google NO devuelve idToken
   - Debe estar en `firebase_options.dart`
   - Valor: `1015036938407-3b42tv87mauud225f3vfett7c5rtogof.apps.googleusercontent.com`

2. **Clean Architecture bien implementada**
   - Presentation: LoginScreen
   - Application: Riverpod providers
   - Domain: GoogleSignInUseCase (sin dependencias de framework)
   - Infrastructure: Repository + DataSource + Modelos

3. **Apple Sign-In también implementado**
   - `AppleSignInUseCase.dart` - Similar flow
   - Solo disponible en iOS

4. **Riverpod para DI**
   - `googleSignInUseCaseProvider` en `core/di/providers.dart`
   - Inyección limpia de dependencias

5. **PROBLEMA CONOCIDO**
   - `build.gradle.kts` usa debug signing para release builds
   - SHA-1 de release no está registrado en Google Cloud Console
   - Google Sign-In fallará en release

---

## Próximos Pasos Recomendados

### Para PRODUCTION
1. Generar keystore de release
2. Obtener SHA-1 del keystore de release
3. Registrar en Google Cloud Console
4. Descargar nuevo google-services.json
5. Actualizar `build.gradle.kts` con release signing config
6. Testear release build

### Comandos Útiles
```bash
# Obtener SHA-1 de release
keytool -list -v -keystore ~/dts_release.jks -alias release

# Testear debug build
flutter run

# Testear release build
flutter run --release
```

---

## Cómo Usar Esta Documentación

1. **Para una búsqueda rápida**
   → Lee GOOGLE_SIGNIN_EXECUTIVE_SUMMARY.txt

2. **Para entender el flujo**
   → Lee GOOGLE_SIGNIN_ARCHITECTURE_DIAGRAMS.txt

3. **Para referencia técnica**
   → Lee GOOGLE_SIGNIN_ANALYSIS.md

4. **Para análisis profundo**
   → Lee GOOGLE_SIGNIN_DETAILED.md

5. **Para checklist de validación**
   → Sección 12 en GOOGLE_SIGNIN_ANALYSIS.md

---

## Validación de Configuración

Checklist:
- [x] google-services.json en android/app/
- [x] GoogleService-Info.plist en ios/Runner/
- [x] firebase_options.dart generado
- [x] google_sign_in en pubspec.yaml
- [x] firebase_auth en pubspec.yaml
- [x] serverClientId configurado
- [x] iosClientId en firebase_options.dart
- [x] GIDClientID en ios/Runner/Info.plist
- [x] URL Scheme en ios/Runner/Info.plist
- [x] com.google.gms.google-services plugin
- [x] Firebase.initializeApp() en main.dart
- [x] Rol "driver" enviado a backend
- [⚠️] SHA-1 de release (TODO)

---

## Contacto

Estos documentos fueron generados mediante análisis exhaustivo del codebase.
Para actualizaciones o correcciones, regenerar con `/graphify` o análisis similar.

**Fecha de generación**: 12 de Agosto de 2026

