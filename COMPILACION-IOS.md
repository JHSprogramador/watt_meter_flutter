# Compilación Flutter para iOS desde Windows

Este documento explica cómo compilar y distribuir tu app Flutter de WattMeter para iOS desde Windows utilizando servicios de compilación en la nube.

## 🎯 Opciones de Compilación en la Nube

### 1. Codemagic (Recomendado)
**✅ Ventajas:**
- 500 minutos gratis por mes
- Especializado en Flutter
- Configuración automática
- Soporte completo para iOS

**📋 Pasos:**
1. Ve a [codemagic.io](https://codemagic.io)
2. Conecta tu repositorio de GitHub
3. Selecciona el proyecto Flutter
4. Configura el workflow automáticamente

### 2. GitHub Actions
**✅ Ventajas:**
- 2000 minutos gratis por mes
- Integración completa con GitHub
- Control total del proceso

### 3. Bitrise
**✅ Ventajas:**
- Plan gratuito disponible
- Interfaz muy intuitiva
- Excelente para principiantes

## 🚀 Configuración Paso a Paso

### Preparación del Proyecto

1. **Inicializar Git (si no lo has hecho):**
```bash
cd watt_meter_flutter
git init
git add .
git commit -m "Initial Flutter WattMeter app"
```

2. **Subir a GitHub:**
```bash
# Crear repositorio en GitHub y luego:
git remote add origin https://github.com/tu-usuario/watt-meter-flutter.git
git push -u origin main
```

### Configuración en Codemagic

1. **Registro y Conexión:**
   - Regístrate en [codemagic.io](https://codemagic.io)
   - Conecta tu cuenta de GitHub
   - Selecciona el repositorio `watt-meter-flutter`

2. **Configuración Automática:**
   - Codemagic detectará automáticamente que es un proyecto Flutter
   - Selecciona "iOS" como plataforma objetivo
   - Acepta la configuración por defecto

3. **Configuración iOS (Importante):**
   ```yaml
   # codemagic.yaml (se crea automáticamente)
   workflows:
     ios-workflow:
       name: iOS Workflow
       max_build_duration: 120
       environment:
         flutter: stable
         xcode: latest
         cocoapods: default
       scripts:
         - name: Get Flutter packages
           script: flutter packages get
         - name: Flutter analyze
           script: flutter analyze
         - name: Flutter unit tests
           script: flutter test
         - name: Build iOS
           script: |
             flutter build ios --release --no-codesign
       artifacts:
         - build/ios/iphoneos/*.app
         - /tmp/xcodebuild_logs/*.log
       publishing:
         app_store_connect:
           api_key: $APP_STORE_CONNECT_PRIVATE_KEY
           key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
           issuer_id: $APP_STORE_CONNECT_ISSUER_ID
   ```

### Instalación en iPhone (Sin App Store)

#### Opción 1: TestFlight (Recomendado)
1. **Requisitos:**
   - Apple Developer Account ($99/año)
   - Configurar certificados en Codemagic

2. **Proceso:**
   - Codemagic compilará y subirá automáticamente a TestFlight
   - Invita tu email para testing
   - Instala desde TestFlight en tu iPhone

#### Opción 2: Instalación Directa (Gratis)
1. **AltStore (Recomendado para uso personal):**
   ```bash
   # Descargar AltStore en tu PC
   # Conectar iPhone por USB
   # Instalar el archivo .ipa generado por Codemagic
   ```

2. **Sideloadly:**
   ```bash
   # Descargar Sideloadly
   # Usar tu Apple ID gratuito
   # Firmar e instalar la app (válida 7 días)
   ```

## 📱 Configuración del Proyecto iOS

### Bundle Identifier
Edita `ios/Runner/Info.plist`:
```xml
<key>CFBundleIdentifier</key>
<string>com.tudominio.wattmeter</string>
<key>CFBundleName</key>
<string>WattMeter</string>
<key>CFBundleDisplayName</key>
<string>WattMeter iPhone</string>
```

### Permisos de Batería
Agrega en `ios/Runner/Info.plist`:
```xml
<key>NSBatteryLevelUsageDescription</key>
<string>Esta app necesita acceso al nivel de batería para mostrar información de carga en tiempo real.</string>
```

## ⚡ Comandos Útiles

### Preparación Local
```bash
# Verificar configuración
flutter doctor

# Actualizar dependencias
flutter pub get

# Verificar errores
flutter analyze

# Ejecutar tests
flutter test

# Build local (solo para verificar)
flutter build ios --release --no-codesign
```

### Configuración de Iconos
```bash
# Instalar flutter_launcher_icons
flutter pub add dev:flutter_launcher_icons

# Configurar en pubspec.yaml y ejecutar:
flutter pub get
flutter pub run flutter_launcher_icons:main
```

## 🔧 Configuración Avanzada

### Para Codemagic con Apple Developer Account

1. **Crear certificados:**
   - Developer Certificate
   - Distribution Certificate
   - Provisioning Profiles

2. **Configurar en Codemagic:**
   ```yaml
   environment:
     ios_signing:
       distribution_type: app_store
       bundle_identifier: com.tudominio.wattmeter
   ```

### Variables de Entorno
En Codemagic, configura:
```
APP_STORE_CONNECT_ISSUER_ID=tu-issuer-id
APP_STORE_CONNECT_KEY_IDENTIFIER=tu-key-id
APP_STORE_CONNECT_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----...
```

## 📦 Distribución

### Instalación Manual (Gratis)
1. **Descarga el .ipa** de Codemagic
2. **Instala AltStore** en tu PC
3. **Conecta iPhone** por USB
4. **Arrastra .ipa** a AltStore
5. **Confía en el perfil** en Configuración → General → Gestión de dispositivos

### Distribución TestFlight
1. **Configuración automática** en Codemagic
2. **Build automático** push a GitHub
3. **Invitación automática** por email
4. **Instalación** desde TestFlight app

## 🚨 Troubleshooting

### Error: "Untrusted Developer"
```
1. Ve a Configuración → General
2. Gestión de dispositivos
3. Confía en el perfil de desarrollador
```

### Error: "App no verificada"
```
1. Configuración → Privacidad y seguridad
2. Ejecutar de desarrollador no verificado
3. Permitir aplicación específica
```

### Build falla en Codemagic
```bash
# Verificar logs de build
# Revisar configuración de dependencias
# Verificar permisos en Info.plist
```

## 💡 Consejos

1. **Desarrollo iterativo:** Usa el simulador iOS en Codemagic para pruebas rápidas
2. **Versionado:** Incrementa version en `pubspec.yaml` para cada build
3. **Testing:** Configura tests automáticos en el workflow
4. **Monitoring:** Usa Codemagic webhooks para notificaciones

## 📚 Recursos Útiles

- [Documentación Codemagic Flutter](https://docs.codemagic.io/flutter/flutter-projects/)
- [Flutter iOS Deployment](https://flutter.dev/docs/deployment/ios)
- [AltStore](https://altstore.io/)
- [Sideloadly](https://sideloadly.io/)

¡Con esta configuración podrás tener tu app WattMeter funcionando en tu iPhone 13 directamente desde Windows! 🎉