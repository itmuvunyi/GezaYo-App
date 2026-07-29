import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SimulatedMapWidget extends StatefulWidget {
  final bool showRiderPins;
  final bool showRadarScan;
  final bool showRoute;
  final String? centerLabel;

  const SimulatedMapWidget({
    super.key,
    this.showRiderPins = true,
    this.showRadarScan = false,
    this.showRoute = false,
    this.centerLabel,
  });

  @override
  State<SimulatedMapWidget> createState() => _SimulatedMapWidgetState();
}

class _SimulatedMapWidgetState extends State<SimulatedMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: MapBackgroundPainter(),
          ),
          if (widget.showRadarScan)
            AnimatedBuilder(
              animation: _radarController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: RadarPainter(progress: _radarController.value),
                );
              },
            ),
          if (widget.showRiderPins) ...[
            const Positioned(
              left: 60,
              top: 80,
              child: _RiderMarker(),
            ),
            const Positioned(
              left: 120,
              bottom: 90,
              child: _RiderMarker(),
            ),
            const Positioned(
              right: 80,
              bottom: 110,
              child: _RiderMarker(),
            ),
          ],
          if (widget.showRoute)
            CustomPaint(
              size: Size.infinite,
              painter: RoutePolylinePainter(),
            ),
          if (widget.centerLabel != null)
            Positioned(
              top: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      widget.centerLabel!,
                      style: AppTypography.titleMedium(
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.statusSuccess,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final minorRoadPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    // Grid lines simulating map streets in Kigali
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.2, size.width, size.height * 0.4);

    path.moveTo(size.width * 0.2, 0);
    path.quadraticBezierTo(
        size.width * 0.4, size.height * 0.6, size.width * 0.8, size.height);

    canvas.drawPath(path, roadPaint);

    final minorPath = Path();
    minorPath.moveTo(0, size.height * 0.7);
    minorPath.lineTo(size.width, size.height * 0.7);
    canvas.drawPath(minorPath, minorRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RadarPainter extends CustomPainter {
  final double progress;

  RadarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.45;

    final paint = Paint()
      ..color =
          AppColors.primary.withValues(alpha: (1 - progress).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxRadius * progress, paint);

    final centerPinPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12, centerPinPaint);
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class RoutePolylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.75);
    path.lineTo(size.width * 0.55, size.height * 0.45);
    path.lineTo(size.width * 0.68, size.height * 0.25);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RiderMarker extends StatelessWidget {
  const _RiderMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6),
        ],
      ),
      child: const Icon(Icons.two_wheeler, color: Colors.white, size: 18),
    );
  }
}
