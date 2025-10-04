import 'package:blyft/views/auth/signup.dart';
import 'package:flutter/material.dart';

import 'forgot_password.dart';
import 'login.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late List<Widget> _pages;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Background animation controller
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    _backgroundController.repeat();

    _pages = [
      LoginScreen(
        goToSignupPage: goToSignupPage,
        goToForgotPasswordPage: goToForgotPasswordPage,
      ),
      SignupScreen(goToLoginPage: goToLoginPage),
      ForgotPasswordScreen(goToLoginPage: goToLoginPage),
    ];
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void goToLoginPage() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void goToSignupPage() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void goToForgotPasswordPage() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: AnimatedBackgroundPainter(_backgroundAnimation.value),
                child: Container(),
              );
            },
          ),
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
        ],
      ),
    );
  }
}

class AnimatedBackgroundPainter extends CustomPainter {
  final double animationValue;

  AnimatedBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 4, 16, 54),
              Color.fromARGB(255, 20, 25, 78),
              Color.fromARGB(255, 27, 52, 105),
            ],
            stops: [0.0, 0.5, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Animated particles
    final particlePaint =
        Paint()
          ..color = const Color.fromARGB(30, 26, 175, 255)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i * 0.1 + animationValue * 0.3)) % size.width;
      final y = (size.height * (i * 0.05 + animationValue * 0.2)) % size.height;
      final radius = (2 + (i % 3)) * (0.5 + 0.5 * (animationValue * 2 % 1));

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }

    // Animated circuit lines
    final linePaint =
        Paint()
          ..color = const Color.fromARGB(40, 26, 175, 255)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    final path = Path();
    final offset = animationValue * 100;

    for (int i = 0; i < 5; i++) {
      final startX = (size.width * 0.2 * i + offset) % size.width;
      final startY = size.height * 0.1 * i;
      final endX = (startX + size.width * 0.3) % size.width;
      final endY = startY + size.height * 0.2;

      path.moveTo(startX, startY);
      path.lineTo(endX, endY);
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

