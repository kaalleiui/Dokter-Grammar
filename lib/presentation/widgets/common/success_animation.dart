import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/color_scheme.dart';

/// Success animation widget for test completion, badges, etc.
class SuccessAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAnimationComplete;
  final bool autoPlay;

  const SuccessAnimation({
    super.key,
    required this.child,
    this.onAnimationComplete,
    this.autoPlay = true,
  });

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Use a simple Tween with a safe curve to avoid TweenSequence assertion errors
    // Curves.easeOutCubic is safe and won't overshoot
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutCubic, // Safe curve that won't overshoot
      ),
    );

    if (widget.autoPlay) {
      _playAnimation();
    }
  }

  void _playAnimation() {
    _scaleController.forward().then((_) {
      // Ensure controller is at exactly 1.0 after animation
      _scaleController.value = 1.0;
      if (widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
    // Don't play rotation animation to avoid tilting
    // _rotationController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        // Clamp value as safety measure (shouldn't be needed with easeOutCubic, but just in case)
        final scaleValue = _scaleAnimation.value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: scaleValue,
          // Removed rotation to prevent tilting
          child: widget.child,
        );
      },
    );
  }
}

/// Celebration confetti effect
class ConfettiAnimation extends StatefulWidget {
  final int particleCount;
  final Duration duration;

  const ConfettiAnimation({
    super.key,
    this.particleCount = 50,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Generate particles
    final random = math.Random();
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: -0.1,
        color: [
          AppColors.primary,
          AppColors.primaryLight,
          AppColors.success,
          AppColors.warning,
        ][random.nextInt(4)],
        size: random.nextDouble() * 8 + 4,
        speed: random.nextDouble() * 2 + 1,
      ));
    }

    _controller.forward();
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
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  Color color;
  double size;
  double speed;

  Particle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()..color = particle.color.withOpacity(1 - progress);
      final y = particle.y + (particle.speed * progress);
      final x = particle.x + (math.sin(progress * math.pi * 2) * 0.1);

      if (y < 1.1) {
        canvas.drawCircle(
          Offset(x * size.width, y * size.height),
          particle.size,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

