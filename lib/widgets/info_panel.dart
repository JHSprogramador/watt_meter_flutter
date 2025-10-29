import 'package:flutter/material.dart';

class InfoPanel extends StatelessWidget {
  final int batteryLevel;
  final bool isCharging;
  final double estimatedWatts;
  final double temperature;
  final double efficiency;
  final String chargingTrend;
  final Duration? timeToFull;
  final double averagePower;
  
  const InfoPanel({
    Key? key,
    required this.batteryLevel,
    required this.isCharging,
    required this.estimatedWatts,
    required this.temperature,
    required this.efficiency,
    required this.chargingTrend,
    this.timeToFull,
    required this.averagePower,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del panel
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isCharging ? Colors.green[50] : Colors.grey[50],
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCharging ? Colors.green : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCharging ? Icons.battery_charging_full : Icons.battery_std,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCharging ? 'Cargando' : 'Desconectado',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCharging ? Colors.green[700] : Colors.grey[700],
                        ),
                      ),
                      Text(
                        'Batería: $batteryLevel%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCharging)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${estimatedWatts.toStringAsFixed(1)}W',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Información detallada
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Estadísticas principales
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Tendencia',
                        chargingTrend,
                        Icons.trending_up,
                        _getTrendColor(),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Eficiencia',
                        '${(efficiency * 100).toStringAsFixed(0)}%',
                        Icons.eco,
                        _getEfficiencyColor(),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Información térmica y tiempo
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Temperatura',
                        '${temperature.toStringAsFixed(1)}°C',
                        Icons.thermostat,
                        _getTemperatureColor(),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        isCharging ? 'Tiempo restante' : 'Promedio',
                        isCharging && timeToFull != null
                            ? _formatDuration(timeToFull!)
                            : '${averagePower.toStringAsFixed(1)}W',
                        isCharging ? Icons.schedule : Icons.analytics,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                
                if (isCharging) ...[
                  SizedBox(height: 20),
                  
                  // Barra de progreso de carga
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progreso de carga',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '$batteryLevel% / 100%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: batteryLevel / 100.0,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            batteryLevel < 20
                                ? Colors.red
                                : batteryLevel < 50
                                    ? Colors.orange
                                    : batteryLevel < 80
                                        ? Colors.blue
                                        : Colors.green,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ],
                
                SizedBox(height: 20),
                
                // Información del dispositivo
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.phone_iphone,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 8),
                          Text(
                            'iPhone 13',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      _buildDeviceInfo('Batería', '3240 mAh'),
                      _buildDeviceInfo('Carga máxima', '20W'),
                      _buildDeviceInfo('Tecnología', 'Li-ion'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeviceInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getTrendColor() {
    switch (chargingTrend.toLowerCase()) {
      case 'carga rápida':
        return Colors.green;
      case 'cargando':
        return Colors.blue;
      case 'descargando':
        return Colors.orange;
      case 'estable':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
  
  Color _getEfficiencyColor() {
    if (efficiency > 0.9) return Colors.green;
    if (efficiency > 0.8) return Colors.blue;
    if (efficiency > 0.7) return Colors.orange;
    return Colors.red;
  }
  
  Color _getTemperatureColor() {
    if (temperature < 25) return Colors.blue;
    if (temperature < 35) return Colors.green;
    if (temperature < 40) return Colors.orange;
    return Colors.red;
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}