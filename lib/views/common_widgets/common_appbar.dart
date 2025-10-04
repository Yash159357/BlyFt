import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubit/theme/theme_cubit.dart';
import '../../controller/cubit/theme/theme_state.dart';

class ParticlesHeader extends StatelessWidget {
  final String title;
  final Color themeColor;
  final Animation<double> particleAnimation;
  final Widget? child;
  final double height;

  const ParticlesHeader({
    super.key,
    required this.title,
    required this.themeColor,
    required this.particleAnimation,
    this.child,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        final currentTheme = themeState.currentTheme;
        return Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDarkMode
                    ? themeColor.withAlpha(100)
                    : currentTheme.primaryColor.withAlpha(35),
                isDarkMode
                    ? themeColor.withAlpha(25)
                    : currentTheme.primaryColor.withAlpha(65),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: particleAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ParticlesPainter(
                        isDarkMode ? themeColor : themeColor,
                        particleAnimation.value,
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 35, 0, 0),
                  child:
                      child ??
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          letterSpacing: 1.2,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black87
                                  : const Color.fromARGB(255, 223, 223, 223),
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                        ),
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnimatedPageTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const AnimatedPageTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final Color themeColor;
  final double animationValue;

  ParticlesPainter(this.themeColor, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withAlpha(50)
          ..style = PaintingStyle.fill;

    final random = 42;
    for (var i = 0; i < 30; i++) {
      final baseX = (random * i * 7) % size.width;
      final baseY = (random * i * 11) % size.height;
      final x = (baseX + (sin(animationValue * 3 + i) * 30)) % size.width;
      final y = (baseY + (cos(animationValue * 4 + i) * 25)) % size.height;
      final radius =
          ((random * i) % 4 + 1) * (0.8 + (sin(animationValue + i) * 0.2));
      final opacity =
          ((i % 5) * 0.1 + 0.1 + (sin(animationValue * 2 + i) * 0.05)) *
          255.toInt();
      canvas.drawCircle(
        Offset(x, y),
        radius.toDouble(),
        paint..color = themeColor.withAlpha(opacity.toInt()),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.themeColor != themeColor;
  }
}

class AppScaffold extends StatelessWidget {
  final Widget body;

  const AppScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
          ),
        ),
        child: body,
      ),
    );
  }
}

