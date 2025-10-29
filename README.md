# WattMeter Flutter - Medidor de Potencia para iPhone

Una aplicación nativa Flutter para monitorizar en tiempo real la potencia de carga de tu iPhone 13, desarrollada completamente desde Windows.

## 🎯 Características

- ⚡ **Monitoreo en tiempo real** de potencia de carga (Watts)
- 🔋 **Información detallada** de batería, voltaje, corriente y temperatura
- 📊 **Gráficos y métricas** de eficiencia de carga
- 🎨 **Interfaz nativa iOS** con animaciones fluidas
- 📱 **Optimizado para iPhone 13** con algoritmos específicos
- 🌡️ **Control térmico** y estimaciones inteligentes
- ⏱️ **Predicción de tiempo** hasta carga completa
- 📈 **Historial de carga** y análisis de tendencias

## 🚀 Instalación Rápida

### Desde Windows (Sin Mac)

1. **Clona el proyecto:**
```bash
git clone https://github.com/tu-usuario/watt-meter-flutter.git
cd watt-meter-flutter
```

2. **Instala dependencias:**
```bash
flutter pub get
```

3. **Compila para iOS usando Codemagic:**
   - Ve a [codemagic.io](https://codemagic.io)
   - Conecta este repositorio
   - ¡La compilación es automática!

4. **Instala en tu iPhone:**
   - Descarga el archivo .ipa
   - Usa AltStore o Sideloadly
   - ¡Listo para usar!

## 🛠️ Desarrollo

### Requisitos
- Flutter 3.16.0+
- Dart 3.0.0+
- Para iOS: Compilación en la nube (Codemagic/GitHub Actions)

### Comandos de desarrollo
```bash
# Instalar dependencias
flutter pub get

# Ejecutar en simulador/emulador
flutter run

# Verificar código
flutter analyze

# Ejecutar tests
flutter test

# Build para iOS (requiere Mac o nube)
flutter build ios --release
```

## 📱 Características Técnicas

### Algoritmos de Carga iPhone 13
- **Potencia máxima:** 20W
- **Carga rápida:** Hasta 80% de batería
- **Carga inteligente:** Protección térmica automática
- **Eficiencia:** 88-95% según nivel de batería

### Métricas Monitorizadas
- 🔌 **Potencia (W):** Cálculo en tiempo real
- ⚡ **Voltaje (V):** Estimación precisa 3.0-4.5V
- 🔄 **Corriente (A):** Derivada de P=V×I
- 🌡️ **Temperatura (°C):** Simulación térmica realista
- 📊 **Eficiencia (%):** Basada en curvas reales iPhone 13
- ⏱️ **Tiempo estimado:** Predicción inteligente

## 🎨 Capturas de Pantalla

```
[Medidor Principal]     [Panel de Info]        [Estado de Carga]
    ⚡ 18.5W               📊 Eficiencia 94%      🔋 Cargando...
   Carga Rápida           🌡️ Temp 28°C           ⏱️ 45min restantes
```

## 🔧 Configuración

### Personalización
Edita `lib/core/constants.dart` para:
- Ajustar algoritmos de carga
- Modificar colores del tema
- Cambiar intervalos de actualización

### Permisos iOS
La app requiere acceso a:
- Battery Level (incluido automáticamente)
- Background App Refresh (opcional)

## 🌐 Compilación en la Nube

### Opción 1: Codemagic (Recomendado)
- ✅ 500 minutos gratis/mes
- ✅ Configuración automática
- ✅ TestFlight integrado

### Opción 2: GitHub Actions
- ✅ 2000 minutos gratis/mes
- ✅ Control total del proceso
- ✅ Artifacts automáticos

Ver [COMPILACION-IOS.md](COMPILACION-IOS.md) para instrucciones detalladas.

## 📦 Distribución

### Para Testing Personal
1. **AltStore (Recomendado):**
   - Instala AltStore en PC
   - Conecta iPhone por USB
   - Arrastra archivo .ipa

2. **Sideloadly:**
   - Usa tu Apple ID gratuito
   - Válido por 7 días
   - Renovación fácil

### Para Distribución
1. **TestFlight:**
   - Requiere Apple Developer ($99/año)
   - Distribución a hasta 10,000 testers
   - Actualizaciones automáticas

## 🧪 Testing

```bash
# Tests unitarios
flutter test

# Tests de widgets
flutter test test/widget_test.dart

# Tests de integración
flutter test integration_test/
```

## 🤝 Contribución

1. Fork el proyecto
2. Crea tu feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la branch (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver [LICENSE](LICENSE) para detalles.

## 🔗 Enlaces Útiles

- [Flutter Documentation](https://flutter.dev/docs)
- [Codemagic CI/CD](https://codemagic.io)
- [AltStore](https://altstore.io/)
- [Battery Plus Plugin](https://pub.dev/packages/battery_plus)

## 📞 Soporte

¿Tienes preguntas? 
- 📧 Email: soporte@wattmeter.com
- 🐛 Issues: [GitHub Issues](https://github.com/tu-usuario/watt-meter-flutter/issues)
- 📖 Wiki: [Documentación completa](https://github.com/tu-usuario/watt-meter-flutter/wiki)

---

**Desarrollado con ❤️ usando Flutter desde Windows para iPhone**

🎉 ¡Disfruta monitorizando la carga de tu iPhone 13!