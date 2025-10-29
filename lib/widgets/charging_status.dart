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
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
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
  }
  
  void _stopAnimations() {
    _pulseController.stop();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
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
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isCharging ? _pulseAnimation.value : 1.0,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isCharging ? Icons.flash_on : Icons.power,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                );
              },
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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