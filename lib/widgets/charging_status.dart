import 'package:flutter/material.dart';

class ChargingStatus extends StatefulWidget {
  final bool isCharging;
  final double currentPower;
  final int batteryLevel;
  final Duration? timeToFull;
  final String chargingMode;
  
  const ChargingStatus({
    Key? key,
    required this.isCharging,
    required this.currentPower,
    required this.batteryLevel,
    this.timeToFull,
    this.chargingMode = 'Normal',
  }) : super(key: key);

  @override
  State<ChargingStatus> createState() => _ChargingStatusState();
}

class _ChargingStatusState extends State<ChargingStatus>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _sparkController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _sparkController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _sparkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkController,
      curve: Curves.easeOutCubic,
    ));
    
    if (widget.isCharging) {
      _startAnimations();
    }
  }
  
  @override
  void didUpdateWidget(ChargingStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isCharging && !oldWidget.isCharging) {
      _startAnimations();
    } else if (!widget.isCharging && oldWidget.isCharging) {
      _stopAnimations();
    }
  }
  
  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _sparkController.repeat();
  }
  
  void _stopAnimations() {
    _pulseController.stop();
    _sparkController.stop();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _sparkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isCharging
              ? [Colors.green[400]!, Colors.green[600]!]
              : [Colors.grey[300]!, Colors.grey[500]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (widget.isCharging ? Colors.green : Colors.grey)
                .withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Icono principal animado
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isCharging) ...[
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.flash_on,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 16),
                  // Chispas animadas
                  AnimatedBuilder(
                    animation: _sparkAnimation,
                    builder: (context, child) {
                      return Stack(
                        children: List.generate(3, (index) {
                          final offset = _sparkAnimation.value * (index + 1) * 10;
                          return Positioned(
                            left: offset,
                            child: Opacity(
                              opacity: 1.0 - _sparkAnimation.value,
                              child: Icon(
                                Icons.star,
                                size: 12 + index * 4,
                                color: Colors.yellow[300],
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ] else
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.power,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Estado principal
            Text(
              widget.isCharging ? 'Cargando' : 'Desconectado',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 8),
            
            // Información de potencia
            if (widget.isCharging) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.currentPower.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'W',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              Text(
                'Modo: ${widget.chargingMode}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              
              if (widget.timeToFull != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Completa en ${_formatDuration(widget.timeToFull!)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              Text(
                'Conecta tu cargador',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'para ver la potencia de carga',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
            
            SizedBox(height: 16),
            
            // Indicadores de estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusIndicator(
                  context,
                  'Batería',
                  '${widget.batteryLevel}%',
                  Icons.battery_std,
                  _getBatteryColor(),
                ),
                _buildStatusIndicator(
                  context,
                  'Estado',
                  widget.isCharging ? 'Activo' : 'Inactivo',
                  widget.isCharging ? Icons.check_circle : Icons.radio_button_unchecked,
                  widget.isCharging ? Colors.white : Colors.white.withOpacity(0.7),
                ),
                _buildStatusIndicator(
                  context,
                  'Modo',
                  _getChargingModeShort(),
                  Icons.speed,
                  Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusIndicator(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.caption?.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
  
  Color _getBatteryColor() {
    if (widget.batteryLevel < 20) return Colors.red[300]!;
    if (widget.batteryLevel < 50) return Colors.orange[300]!;
    if (widget.batteryLevel < 80) return Colors.white;
    return Colors.green[300]!;
  }
  
  String _getChargingModeShort() {
    if (!widget.isCharging) return 'N/A';
    
    if (widget.currentPower > 15) return 'Rápido';
    if (widget.currentPower > 10) return 'Normal';
    if (widget.currentPower > 5) return 'Lento';
    return 'Mínimo';
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}min';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}min';
    } else {
      return '<1min';
    }
  }
}

// Widget adicional para mostrar velocidad de carga
class ChargingSpeedIndicator extends StatelessWidget {
  final double currentPower;
  final double maxPower;
  
  const ChargingSpeedIndicator({
    Key? key,
    required this.currentPower,
    this.maxPower = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final speedRatio = currentPower / maxPower;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Velocidad de carga',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getSpeedText(speedRatio),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _getSpeedColor(speedRatio),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Barra de velocidad
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: speedRatio.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getSpeedColor(speedRatio),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0W',
                style: Theme.of(context).textTheme.caption,
              ),
              Text(
                '${maxPower.toInt()}W',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getSpeedText(double ratio) {
    if (ratio > 0.8) return 'Muy rápida';
    if (ratio > 0.6) return 'Rápida';
    if (ratio > 0.4) return 'Normal';
    if (ratio > 0.2) return 'Lenta';
    return 'Muy lenta';
  }
  
  Color _getSpeedColor(double ratio) {
    if (ratio > 0.8) return Colors.green;
    if (ratio > 0.6) return Colors.blue;
    if (ratio > 0.4) return Colors.orange;
    if (ratio > 0.2) return Colors.orange[300]!;
    return Colors.red;
  }
}