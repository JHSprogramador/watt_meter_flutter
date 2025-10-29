import 'package:flutter/material.dart';
import 'dart:math';

class CircularMeter extends StatefulWidget {
  final double value;
  final double maxValue;
  final String unit;
  final String label;
  final Color color;
  final double size;
  final bool showAnimation;
  
  const CircularMeter({
    Key? key,
    required this.value,
    this.maxValue = 100.0,
    this.unit = 'W',
    this.label = 'Potencia',
    this.color = Colors.blue,
    this.size = 200.0,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  State<CircularMeter> createState() => _CircularMeterState();
}

class _CircularMeterState extends State<CircularMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value / widget.maxValue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    if (widget.showAnimation) {
      _animationController.forward();
    }
  }
  
  @override
  void didUpdateWidget(CircularMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value / widget.maxValue,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      
      _animationController.reset();
      _animationController.forward();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Medidor circular animado
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: CircularMeterPainter(
                  progress: _animation.value,
                  color: widget.color,
                  strokeWidth: 12.0,
                ),
              );
            },
          ),
          
          // Contenido central
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Valor principal
              Text(
                widget.value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                  fontSize: widget.size * 0.15,
                ),
              ),
              
              // Unidad
              Text(
                widget.unit,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              SizedBox(height: 8),
              
              // Etiqueta
              Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  fontSize: widget.size * 0.06,
                ),
                textAlign: TextAlign.center,
              ),
              
              // Porcentaje del máximo
              if (widget.maxValue > 0)
                Text(
                  '${((widget.value / widget.maxValue) * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: widget.size * 0.05,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CircularMeterPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  
  CircularMeterPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Fondo del medidor
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progreso del medidor
    final progressPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    
    // Dibujar arco de progreso
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
    
    // Indicador de progreso (punto brillante)
    if (progress > 0) {
      final indicatorAngle = startAngle + sweepAngle;
      final indicatorX = center.dx + radius * cos(indicatorAngle);
      final indicatorY = center.dy + radius * sin(indicatorAngle);
      
      final indicatorPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(indicatorX, indicatorY),
        strokeWidth / 2 + 2,
        indicatorPaint,
      );
      
      canvas.drawCircle(
        Offset(indicatorX, indicatorY),
        strokeWidth / 2,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(CircularMeterPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}

// Widget auxiliar para medidores pequeños
class MiniMeter extends StatelessWidget {
  final double value;
  final double maxValue;
  final String unit;
  final String label;
  final Color color;
  
  const MiniMeter({
    Key? key,
    required this.value,
    this.maxValue = 100.0,
    this.unit = '',
    this.label = '',
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                _getIconForLabel(label),
                size: 20,
                color: color,
              ),
            ],
          ),
          
          SizedBox(height: 8),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(width: 4),
              Text(
                unit,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Barra de progreso
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'voltaje':
      case 'voltage':
        return Icons.flash_on;
      case 'corriente':
      case 'current':
        return Icons.electric_bolt;
      case 'temperatura':
      case 'temperature':
        return Icons.thermostat;
      case 'eficiencia':
      case 'efficiency':
        return Icons.eco;
      default:
        return Icons.analytics;
    }
  }
}