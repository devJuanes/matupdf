import 'dart:math';

import 'package:flutter/material.dart';

/// Confeti ligero sin dependencias externas.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key, this.active = true});

  final bool active;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final _random = Random();

  static const _colors = [
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFDD835),
    Color(0xFF8E24AA),
    Color(0xFFFF7043),
  ];

  @override
  void initState() {
    super.initState();
    _particles = List.generate(72, (_) => _Particle.random(_random, _colors));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    if (widget.active) _controller.forward();
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ConfettiPainter(
              progress: _controller.value,
              particles: _particles,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.wobble,
    required this.rotation,
    required this.color,
    required this.size,
  });

  factory _Particle.random(Random random, List<Color> colors) {
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble() * -0.4,
      speed: 0.35 + random.nextDouble() * 0.65,
      wobble: random.nextDouble() * pi * 2,
      rotation: random.nextDouble() * pi * 2,
      color: colors[random.nextInt(colors.length)],
      size: 4 + random.nextDouble() * 6,
    );
  }

  final double x;
  final double y;
  final double speed;
  final double wobble;
  final double rotation;
  final Color color;
  final double size;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.particles});

  final double progress;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final top = (p.y + progress * p.speed * 1.4) * size.height;
      if (top > size.height + 20) continue;

      final left = (p.x + sin(progress * 6 + p.wobble) * 0.04) * size.width;
      final paint = Paint()..color = p.color.withValues(alpha: 0.9);

      canvas.save();
      canvas.translate(left, top);
      canvas.rotate(p.rotation + progress * 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
