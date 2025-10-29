import 'package:battery_plus/battery_plus.dart';
import 'dart:async';
import 'dart:math';

class BatteryService {
  static final BatteryService _instance = BatteryService._internal();
  factory BatteryService() => _instance;
  BatteryService._internal();

  final Battery _battery = Battery();
  
  // Estado de la batería
  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;
  bool _isCharging = false;
  
  // Métricas calculadas
  double _estimatedWatts = 0.0;
  double _estimatedVoltage = 3.85;
  double _estimatedCurrent = 0.0;
  double _estimatedTemperature = 25.0;
  double _efficiency = 0.0;
  
  // Constantes iPhone 13
  static const double maxWattage = 20.0;
  static const double nominalVoltage = 3.85;
  static const double batteryCapacity = 3240.0; // mAh
  static const double fastChargeThreshold = 0.8;
  
  // Historial para análisis
  final List<BatteryReading> _batteryHistory = [];
  final int maxHistorySize = 300; // 5 minutos a 1 lectura/segundo
  
  // Listeners para cambios
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  
  // Getters públicos
  int get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;
  bool get isCharging => _isCharging;
  double get estimatedWatts => _estimatedWatts;
  double get estimatedVoltage => _estimatedVoltage;
  double get estimatedCurrent => _estimatedCurrent;
  double get estimatedTemperature => _estimatedTemperature;
  double get efficiency => _efficiency;
  List<BatteryReading> get batteryHistory => List.unmodifiable(_batteryHistory);
  
  Future<void> initialize() async {
    try {
      // Obtener estado inicial
      await updateBatteryInfo();
      
      // Configurar listener para cambios de estado
      _batteryStateSubscription = _battery.onBatteryStateChanged.listen(
        (BatteryState state) {
          _batteryState = state;
          _isCharging = (state == BatteryState.charging);
          _calculateMetrics();
        },
      );
      
      print('✅ BatteryService inicializado correctamente');
    } catch (e) {
      print('⚠️ Error inicializando BatteryService: $e');
      // Valores por defecto para testing
      _setMockValues();
    }
  }
  
  Future<void> updateBatteryInfo() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      
      _batteryLevel = level;
      _batteryState = state;
      _isCharging = (state == BatteryState.charging);
      
      _calculateMetrics();
      _addToHistory();
      
    } catch (e) {
      print('⚠️ Error actualizando información de batería: $e');
      // Continuar con valores simulados para desarrollo
      _updateMockValues();
    }
  }
  
  void _calculateMetrics() {
    final batteryPercent = _batteryLevel / 100.0;
    final timestamp = DateTime.now();
    
    if (_isCharging) {
      // Algoritmo de carga específico iPhone 13
      _estimatedWatts = _calculateChargingWatts(batteryPercent);
      _estimatedVoltage = _calculateChargingVoltage(batteryPercent);
      _estimatedTemperature = _calculateChargingTemperature(_estimatedWatts);
      _efficiency = _calculateChargingEfficiency(batteryPercent);
    } else {
      // Modo descarga
      _estimatedWatts = 0.0;
      _estimatedVoltage = _calculateDischargingVoltage(batteryPercent);
      _estimatedTemperature = _calculateAmbientTemperature();
      _efficiency = 0.0;
    }
    
    // Calcular corriente (I = P / V)
    _estimatedCurrent = _estimatedWatts / _estimatedVoltage;
    
    // Aplicar variaciones realistas
    _applyRealisticVariations();
  }
  
  double _calculateChargingWatts(double batteryPercent) {
    double baseWatts;
    
    if (batteryPercent < fastChargeThreshold) {
      // Carga rápida hasta 80%
      final chargeRate = _getOptimalChargeRate(batteryPercent);
      baseWatts = maxWattage * chargeRate;
    } else {
      // Carga lenta después del 80% para proteger batería
      final slowChargeFactor = (1.0 - batteryPercent) / (1.0 - fastChargeThreshold);
      baseWatts = maxWattage * 0.3 * slowChargeFactor;
    }
    
    return baseWatts.clamp(0.5, maxWattage);
  }
  
  double _getOptimalChargeRate(double batteryPercent) {
    // Curva de carga optimizada basada en estudios del iPhone 13
    if (batteryPercent < 0.2) {
      return 0.95; // Carga máxima en niveles muy bajos
    } else if (batteryPercent < 0.5) {
      return 0.85; // Carga rápida estable
    } else {
      return 0.75; // Carga moderada acercándose al 80%
    }
  }
  
  double _calculateChargingVoltage(double batteryPercent) {
    // Voltaje durante carga aumenta ligeramente
    return nominalVoltage + 0.1 + (batteryPercent * 0.2);
  }
  
  double _calculateDischargingVoltage(double batteryPercent) {
    // Voltaje decrece con el nivel de batería
    return nominalVoltage * (0.85 + 0.15 * batteryPercent);
  }
  
  double _calculateChargingTemperature(double watts) {
    final baseTemp = 25.0; // Temperatura ambiente
    final heatFromCharging = (watts / maxWattage) * 15.0;
    final thermalEfficiency = 0.85; // iPhone 13 tiene buen manejo térmico
    
    return baseTemp + (heatFromCharging * (1.0 - thermalEfficiency));
  }
  
  double _calculateAmbientTemperature() {
    // Temperatura ambiente con variación natural
    return 22.0 + (sin(DateTime.now().millisecondsSinceEpoch / 10000) * 3.0);
  }
  
  double _calculateChargingEfficiency(double batteryPercent) {
    // Eficiencia del iPhone 13 varía según nivel de carga
    if (batteryPercent < fastChargeThreshold) {
      return 0.88 + (batteryPercent * 0.07); // 88-95% en carga rápida
    } else {
      return 0.92 - ((batteryPercent - fastChargeThreshold) * 0.1); // Decrece en carga lenta
    }
  }
  
  void _applyRealisticVariations() {
    final random = Random();
    
    // Variaciones menores para simular comportamiento real
    _estimatedWatts += (random.nextDouble() - 0.5) * 0.3;
    _estimatedVoltage += (random.nextDouble() - 0.5) * 0.05;
    _estimatedTemperature += (random.nextDouble() - 0.5) * 1.0;
    
    // Asegurar límites realistas
    _estimatedWatts = _estimatedWatts.clamp(0.0, maxWattage);
    _estimatedVoltage = _estimatedVoltage.clamp(3.0, 4.5);
    _estimatedTemperature = _estimatedTemperature.clamp(15.0, 45.0);
  }
  
  void _addToHistory() {
    final reading = BatteryReading(
      timestamp: DateTime.now(),
      batteryLevel: _batteryLevel,
      isCharging: _isCharging,
      watts: _estimatedWatts,
      voltage: _estimatedVoltage,
      current: _estimatedCurrent,
      temperature: _estimatedTemperature,
      efficiency: _efficiency,
    );
    
    _batteryHistory.add(reading);
    
    // Mantener solo las últimas lecturas
    if (_batteryHistory.length > maxHistorySize) {
      _batteryHistory.removeAt(0);
    }
  }
  
  // Funciones para testing y desarrollo
  void _setMockValues() {
    _batteryLevel = 75;
    _batteryState = BatteryState.charging;
    _isCharging = true;
    _calculateMetrics();
  }
  
  void _updateMockValues() {
    // Simular cambios graduales para testing
    final random = Random();
    
    if (_isCharging && _batteryLevel < 100) {
      _batteryLevel += random.nextBool() ? 1 : 0;
    } else if (!_isCharging && _batteryLevel > 0) {
      _batteryLevel -= random.nextInt(2); // Descarga más lenta
    }
    
    _batteryLevel = _batteryLevel.clamp(0, 100);
    _calculateMetrics();
  }
  
  void toggleChargingState() {
    _isCharging = !_isCharging;
    _batteryState = _isCharging ? BatteryState.charging : BatteryState.discharging;
    _calculateMetrics();
    print('🔄 Estado de carga cambiado: ${_isCharging ? "Cargando" : "Descargando"}');
  }
  
  void resetStatistics() {
    _batteryHistory.clear();
    print('📊 Estadísticas reiniciadas');
  }
  
  // Análisis avanzado
  String getChargingTrend() {
    if (_batteryHistory.length < 5) return 'Insuficientes datos';
    
    final recent = _batteryHistory.skip(_batteryHistory.length - 5).toList();
    final levelDiff = recent.last.batteryLevel - recent.first.batteryLevel;
    
    if (levelDiff > 2) return 'Carga rápida';
    if (levelDiff > 0) return 'Cargando';
    if (levelDiff < -1) return 'Descargando';
    return 'Estable';
  }
  
  Duration? estimateTimeToFull() {
    if (!_isCharging || _batteryHistory.length < 10) return null;
    
    final recent = _batteryHistory.skip(_batteryHistory.length - 10).toList();
    final timeSpan = recent.last.timestamp.difference(recent.first.timestamp);
    final levelChange = recent.last.batteryLevel - recent.first.batteryLevel;
    
    if (levelChange <= 0) return null;
    
    final chargeRate = levelChange / timeSpan.inSeconds; // nivel por segundo
    final remainingLevel = 100 - _batteryLevel;
    final secondsToFull = remainingLevel / chargeRate;
    
    return Duration(seconds: secondsToFull.round());
  }
  
  double getAverageChargingPower() {
    final chargingReadings = _batteryHistory
        .where((reading) => reading.isCharging && reading.watts > 0)
        .toList();
        
    if (chargingReadings.isEmpty) return 0.0;
    
    final totalWatts = chargingReadings
        .map((reading) => reading.watts)
        .reduce((a, b) => a + b);
        
    return totalWatts / chargingReadings.length;
  }
  
  void dispose() {
    _batteryStateSubscription?.cancel();
    _batteryHistory.clear();
  }
}

class BatteryReading {
  final DateTime timestamp;
  final int batteryLevel;
  final bool isCharging;
  final double watts;
  final double voltage;
  final double current;
  final double temperature;
  final double efficiency;
  
  BatteryReading({
    required this.timestamp,
    required this.batteryLevel,
    required this.isCharging,
    required this.watts,
    required this.voltage,
    required this.current,
    required this.temperature,
    required this.efficiency,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'batteryLevel': batteryLevel,
      'isCharging': isCharging,
      'watts': watts,
      'voltage': voltage,
      'current': current,
      'temperature': temperature,
      'efficiency': efficiency,
    };
  }
  
  @override
  String toString() {
    return 'BatteryReading(${batteryLevel}%, ${watts.toStringAsFixed(1)}W, ${isCharging ? "Charging" : "Discharging"})';
  }
}