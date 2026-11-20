import 'package:flutter/material.dart';

class AnimatedPulseRing extends StatefulWidget {
  final Widget child;
  final Color pulseColor;
  final double maxRadius;

  const AnimatedPulseRing({
    super.key,
    required this.child,
    this.pulseColor = const Color(0xFFEF4444),
    this.maxRadius = 130.0,
  });

  @override
  State<AnimatedPulseRing> createState() => _AnimatedPulseRingState();
}

class _AnimatedPulseRingState extends State<AnimatedPulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring 1
            CustomPaint(
              painter: _RingPainter(
                progress: _controller.value,
                color: widget.pulseColor,
                maxRadius: widget.maxRadius,
              ),
            ),
            // Outer Ring 2 (delayed)
            CustomPaint(
              painter: _RingPainter(
                progress: (_controller.value + 0.5) % 1.0,
                color: widget.pulseColor,
                maxRadius: widget.maxRadius * 0.8,
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double maxRadius;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity((1.0 - progress).clamp(0.0, 0.6))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * (1.0 - progress);

    final radius = progress * maxRadius;
    canvas.drawCircle(Offset.zero, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => true;
}
