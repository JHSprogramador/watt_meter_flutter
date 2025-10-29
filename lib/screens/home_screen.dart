import 'package:flutter/material.dart';
import '../services/battery_service.dart';
import '../widgets/circular_meter.dart';
import '../widgets/info_panel.dart';
import '../widgets/charging_status.dart';
import '../utils/theme.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  
  final BatteryService _batteryService = BatteryService();
  
  // Controladores de animación
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  
  // Timer para actualizaciones
  Timer? _updateTimer;
  
  // Estado de la aplicación
  bool _isMonitoring = false;
  
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initBatteryService();
    _startMonitoring();
  }
  
  void _initAnimations() {
    // Animación de pulso para el icono de carga
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Animación de rotación para elementos decorativos
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotationController);
    
    _rotationController.repeat();
  }
  
  Future<void> _initBatteryService() async {
    await _batteryService.initialize();
    if (mounted) {
      setState(() {});
    }
  }
  
  void _startMonitoring() {
    setState(() {
      _isMonitoring = true;
    });
    
    _pulseController.repeat(reverse: true);
    
    _updateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        await _batteryService.updateBatteryInfo();
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
  
  void _stopMonitoring() {
    setState(() {
      _isMonitoring = false;
    });
    
    _pulseController.stop();
    _updateTimer?.cancel();
  }
  
  void _toggleMonitoring() {
    if (_isMonitoring) {
      _stopMonitoring();
    } else {
      _startMonitoring();
    }
  }
  
  String _getChargingMode() {
    if (!_batteryService.isCharging) return 'N/A';
    
    final watts = _batteryService.estimatedWatts;
    if (watts > 15) return 'Rápido';
    if (watts > 10) return 'Normal';
    if (watts > 5) return 'Lento';
    return 'Mínimo';
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  const SizedBox(height: 30),
                  
                  // Medidor circular principal
                  CircularMeter(
                    value: _batteryService.estimatedWatts,
                    maxValue: 20.0,
                    unit: 'W',
                    label: 'Potencia',
                    color: _batteryService.isCharging 
                        ? AppTheme.secondaryGreen 
                        : AppTheme.textSecondary,
                    size: 200.0,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Estado de carga
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _batteryService.isCharging 
                            ? _pulseAnimation.value 
                            : 1.0,
                        child: ChargingStatus(
                          isCharging: _batteryService.isCharging,
                          currentPower: _batteryService.estimatedWatts,
                          batteryLevel: _batteryService.batteryLevel,
                          timeToFull: _batteryService.estimateTimeToFull(),
                          chargingMode: _getChargingMode(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Panel de información
                  InfoPanel(
                    batteryLevel: _batteryService.batteryLevel,
                    isCharging: _batteryService.isCharging,
                    estimatedWatts: _batteryService.estimatedWatts,
                    temperature: _batteryService.estimatedTemperature,
                    efficiency: _batteryService.efficiency,
                    chargingTrend: _batteryService.getChargingTrend(),
                    timeToFull: _batteryService.estimateTimeToFull(),
                    averagePower: _batteryService.getAverageChargingPower(),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Controles
                  _buildControls(),
                  
                  const SizedBox(height: 20),
                  
                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      children: [
        // Título principal
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
          child: const Text(
            '⚡ Watt Meter',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtítulo
        Text(
          'Monitor de Carga iPhone 13',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        
        const SizedBox(height: 12),
        
        // Indicador de desarrollo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.computer,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                'Desarrollado desde Windows',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryBlue,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildControls() {
    return Column(
      children: [
        // Botón principal de monitoreo
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _toggleMonitoring,
            icon: Icon(
              _isMonitoring ? Icons.pause : Icons.play_arrow,
              size: 24,
            ),
            label: Text(
              _isMonitoring ? 'Pausar Monitoreo' : 'Iniciar Monitoreo',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isMonitoring 
                  ? AppTheme.warningOrange 
                  : AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Botones secundarios
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Simular cambio de estado para testing
                  _batteryService.toggleChargingState();
                  setState(() {});
                },
                icon: const Icon(Icons.swap_horiz, size: 20),
                label: const Text('Simular'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.textSecondary),
                  foregroundColor: AppTheme.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Reset de estadísticas
                  _batteryService.resetStatistics();
                  setState(() {});
                },
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.textSecondary),
                  foregroundColor: AppTheme.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildFooter() {
    return Column(
      children: [
        // Disclaimer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warningOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.warningOrange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.warningOrange,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Valores estimados basados en algoritmos específicos del iPhone 13',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Información de versión
        Text(
          'Flutter v1.0 • Desarrollado desde Windows',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textTertiary,
          ),
        ),
      ],
    );
  }
}