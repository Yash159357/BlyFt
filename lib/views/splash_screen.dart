import 'dart:math' as math;

import 'package:brevity/controller/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:brevity/l10n/app_localizations.dart';

// Enhanced Palette - matching login screen
const Color bgStart = Color(0xFF070B14);
const Color bgEnd = Color(0xFF0E1624);
const Color primaryA = Color(0xFF3D4DFF);
const Color primaryB = Color(0xFF29C0FF);
const Color mutedText = Color(0xFF9AA8BF);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _textController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _fadeAnim;
  late Animation<double> _particleAnim;
  late Animation<double> _pulseAnim;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;

  // Particle system
  final List<EnhancedParticle> _particles = [];
  final List<FloatingElement> _floatingElements = [];

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Setup animations
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _logoRotation = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _particleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);

    // Initialize particles and floating elements
    _initializeParticles();
    _initializeFloatingElements();

    // Start animation sequence
    _startAnimationSequence();
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < 25; i++) {
      _particles.add(
        EnhancedParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: random.nextDouble() * 3 + 1,
          speed: random.nextDouble() * 0.3 + 0.1,
          opacity: random.nextDouble() * 0.6 + 0.2,
          color: i % 3 == 0 ? primaryA : primaryB,
          angle: random.nextDouble() * 2 * math.pi,
        ),
      );
    }
  }

  void _initializeFloatingElements() {
    final random = math.Random();
    for (int i = 0; i < 8; i++) {
      _floatingElements.add(
        FloatingElement(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 120 + 60,
          speed: random.nextDouble() * 0.15 + 0.05,
          opacity: random.nextDouble() * 0.05 + 0.02,
          offset: random.nextDouble() * 2 * math.pi,
        ),
      );
    }
  }

  void _startAnimationSequence() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Start background animations
    _fadeController.forward();
    _particleController.repeat();
    _pulseController.repeat(reverse: true);

    // Delay for logo animation
    await Future.delayed(const Duration(milliseconds: 400));
    _logoController.forward();

    // Delay for text animation
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 2800));

    // Add final haptic feedback
    HapticFeedback.mediumImpact();

    // Navigate based on auth status
    _navigateBasedOnAuthStatus();
  }

  void _navigateBasedOnAuthStatus() {
    try {
      final authService = AuthService();
      final isSignedIn = authService.isAuthenticated;

      if (isSignedIn) {
        if (authService.isEmailVerified) {
          context.go('/home/0');
        } else {
          final user = authService.currentUser;
          if (user != null) {
            context.go(
              '/email-verification?email=${Uri.encodeComponent(user.email)}&isFromLogin=true',
            );
          } else {
            context.go('/auth');
          }
        }
      } else {
        context.go('/auth');
      }
    } catch (e) {
      // Fallback navigation
      context.go('/auth');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: Stack(
          children: [
            // Background floating elements
            _buildFloatingBackground(),

            // Particle system
            AnimatedBuilder(
              animation: _particleController,
              builder:
                  (context, _) => CustomPaint(
                    painter: EnhancedParticlePainter(
                      particles: _particles,
                      progress: _particleAnim.value,
                    ),
                  ),
            ),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedLogo(),
                    const SizedBox(height: 16),
                    _buildAnimatedText(),
                  ],
                ),
              ),
            ),

            // Loading indicator at bottom
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _buildLoadingIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBackground() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        return Stack(
          children:
              _floatingElements.map((element) {
                final t = _particleAnim.value;
                final yOffset = math.sin(t * 2 * math.pi + element.offset) * 30;
                final xOffset = math.cos(t * 2 * math.pi + element.offset) * 20;

                return Positioned(
                  left:
                      element.x * MediaQuery.of(context).size.width -
                      element.size / 2 +
                      xOffset,
                  top:
                      element.y * MediaQuery.of(context).size.height -
                      element.size / 2 +
                      yOffset,
                  child: Transform.rotate(
                    angle: t * 0.5 + element.offset,
                    child: Container(
                      width: element.size,
                      height: element.size,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(element.size / 2),
                        gradient: RadialGradient(
                          center: const Alignment(-0.3, -0.4),
                          radius: 1.2,
                          colors: [
                            primaryA.withAlpha((element.opacity * 255).toInt()),
                            primaryB.withAlpha((element.opacity / 2 * 255).toInt()),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseController]),
      builder: (context, _) {
        return Transform.scale(
          scale: _logoScale.value * _pulseAnim.value,
          child: Transform.rotate(
            angle: _logoRotation.value * math.pi,
            child: Image.asset(
              'assets/logos/Brevity_white.png',
              height: 150,
              width: 150,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryA, primaryB],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.flash_on_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return SlideTransition(
      position: _textSlide,
      child: FadeTransition(
        opacity: _textFade,
        child: Column(
          children: [
            ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryA, primaryB],
                    stops: const [0.0, 1.0],
                  ).createShader(bounds),
              child: Text(
                AppLocalizations.of(context)!.appTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                  height: 1.0,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            Text(
              AppLocalizations.of(context)!.yourSmartNewsCompanion,
              style: TextStyle(
                color: mutedText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        // Custom loading animation
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, _) {
            return Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white.withAlpha((0.1 * 255).toInt()),
              ),
              child: Stack(
                children: [
                  Container(
                    width: 200 * _particleAnim.value,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(colors: [primaryA, primaryB]),
                      boxShadow: [
                        BoxShadow(
                          color: primaryB.withAlpha((0.5 * 255).toInt()),
                          blurRadius: 8,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        Text(
          AppLocalizations.of(context)!.loading,
          style: TextStyle(
            color: mutedText.withAlpha((0.8 * 255).toInt()),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Enhanced Particle Class
class EnhancedParticle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double opacity;
  final Color color;
  final double angle;

  EnhancedParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.color,
    required this.angle,
  });
}

// Floating Element Class
class FloatingElement {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double offset;

  FloatingElement({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.offset,
  });
}

// Enhanced Particle Painter
class EnhancedParticlePainter extends CustomPainter {
  final List<EnhancedParticle> particles;
  final double progress;

  EnhancedParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint =
          Paint()
            ..color = particle.color.withAlpha(
              (particle.opacity * (1.0 - progress * 0.5) * 255).toInt(),
            )
            ..style = PaintingStyle.fill;

      // Create movement pattern
      final centerX = size.width * 0.5;
      final centerY = size.height * 0.5;

      final currentX = particle.x * size.width;
      final currentY = particle.y * size.height;

      // Calculate movement towards center with oscillation
      final moveX = (centerX - currentX) * progress * 0.3;
      final moveY = (centerY - currentY) * progress * 0.3;

      // Add oscillation
      final oscillationX =
          math.cos(progress * 4 * math.pi + particle.angle) * 20;
      final oscillationY =
          math.sin(progress * 4 * math.pi + particle.angle) * 20;

      final finalX = currentX + moveX + oscillationX;
      final finalY = currentY + moveY + oscillationY;

      // Draw particle with glow effect
      final glowPaint =
          Paint()
            ..color = particle.color.withAlpha((particle.opacity * 0.3 * 255).toInt())
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawCircle(Offset(finalX, finalY), particle.radius * 2, glowPaint);

      canvas.drawCircle(
        Offset(finalX, finalY),
        particle.radius * (1.0 + progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
