import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:brevity/controller/services/auth_service.dart';
import '../../l10n/app_localizations.dart';

import '../common_widgets/auth_header.dart';

// Enhanced Palette (consistent with login/signup)
const Color bgStart = Color(0xFF070B14);
const Color bgEnd = Color(0xFF0E1624);

const Color primaryA = Color(0xFF3D4DFF);
const Color primaryB = Color(0xFF29C0FF);

const Color panelTop = Color(0xFF0F1724);
const Color panelBottom = Color(0xFF111827);
const Color mutedText = Color(0xFF9AA8BF);
const Color successColor = Color(0xFF10B981);
const Color warningColor = Color(0xFFF59E0B);
const Color errorColor = Color(0xFFEF4444);

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final bool isFromLogin;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.isFromLogin = false,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with TickerProviderStateMixin {
  bool _isCheckingVerification = false;
  bool _isResendingEmail = false;

  // Timer related variables
  Timer? _resendTimer;
  Timer? _autoCheckTimer;
  int _resendCooldown = 0;
  int _resendAttempts = 0;
  static const List<int> _cooldownDurations = [30, 60, 120, 300]; // 30s, 1m, 2m, 5m

  // Animations (consistent with login/signup)
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _floatController;
  late final AnimationController _pulseController;
  late final AnimationController _shakeController;

  late final Animation<double> _floatAnim;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _floatAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    _floatController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);

    // Start entrance animations
    Future.delayed(
      const Duration(milliseconds: 160),
          () => _fadeController.forward(),
    );
    Future.delayed(
      const Duration(milliseconds: 300),
          () => _slideController.forward(),
    );

    // Start periodic check for email verification (every 10 seconds)
    if (AuthService().isAuthenticated) {
      _startPeriodicCheck();
    }
  }

  void _startPeriodicCheck() {
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!mounted || _isCheckingVerification) return;

      try {
        await AuthService().refreshUser();
        final user = AuthService().currentUser;

        if (user != null && user.emailVerified) {
          timer.cancel();
          if (!mounted) return;

          _showSuccessMessage('Email verified successfully!');

          // Navigate based on where user came from
          if (widget.isFromLogin) {
            context.go('/home/0');
          } else {
            context.go('/intro');
          }
        }
      } catch (e) {
        // Silently fail for auto-checks, user can manually check if needed
        if (e.toString().contains('Token expired')) {
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _autoCheckTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    // Get cooldown duration based on attempts, with a maximum
    final duration = _resendAttempts < _cooldownDurations.length
        ? _cooldownDurations[_resendAttempts]
        : _cooldownDurations.last;

    setState(() {
      _resendCooldown = duration;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldown--;
      });

      if (_resendCooldown <= 0) {
        timer.cancel();
        _resendTimer = null;
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: successColor, size: 20),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1F2937),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: errorColor, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            )),
          ],
        ),
        backgroundColor: const Color(0xFF1F2937),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showWarningMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_rounded, color: warningColor, size: 20),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1F2937),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 16,
      left: 16,
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _autoCheckTimer?.cancel();
            context.go('/auth');
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.3 * 255).toInt()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withAlpha((0.1 * 255).toInt()),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.2 * 255).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkVerification() async {
    HapticFeedback.lightImpact();
    setState(() => _isCheckingVerification = true);

    try {
      // Refresh user data from server
      await AuthService().refreshUser();
      final user = AuthService().currentUser;

      if (user != null && user.emailVerified) {
        if (!mounted) return;
        HapticFeedback.mediumImpact();

        _showSuccessMessage('Email verified successfully!');

        // Navigate based on where user came from
        if (widget.isFromLogin) {
          context.go('/home/0');
        } else {
          context.go('/intro');
        }
      } else {
        if (!mounted) return;
        HapticFeedback.lightImpact();
        _showWarningMessage('Email not yet verified. Please check your\nemail and click the verification link.');
      }
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      _shakeController.forward().then((_) => _shakeController.reset());

      // More specific error handling
      String errorMessage = 'Error checking verification';
      if (e.toString().contains('Token expired') || e.toString().contains('401')) {
        errorMessage = 'Session expired. Please log in again.';
        // Clear auth state and redirect to login
        await AuthService().signOut(context: context);
        return;
      } else if (e.toString().contains('Network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      }

      _showErrorMessage(errorMessage);
    } finally {
      if (mounted) setState(() => _isCheckingVerification = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    HapticFeedback.lightImpact();

    // Check if cooldown is active
    if (_resendCooldown > 0) {
      _showWarningMessage('Please wait ${_formatTime(_resendCooldown)} before resending');
      return;
    }

    setState(() => _isResendingEmail = true);

    try {
      await AuthService().resendVerificationEmail(widget.email);

      // Increment attempts and start cooldown
      _resendAttempts++;
      _startResendCooldown();

      if (!mounted) return;
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.send_rounded, color: primaryB, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Verification email sent! Please check your\ninbox and spam folder.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1F2937),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      _shakeController.forward().then((_) => _shakeController.reset());

      String errorMessage = 'Error sending email';
      if (e.toString().contains('already verified')) {
        errorMessage = 'Email is already verified! Try refreshing or logging in again.';
        // Auto-check verification status
        Future.delayed(const Duration(seconds: 1), () => _checkVerification());
      } else if (e.toString().contains('User not found')) {
        errorMessage = 'User not found. Please contact support.';
      } else if (e.toString().contains('Server error')) {
        errorMessage = 'Server error. Please try again later.';
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = 'Error sending email. Please try again.';
      }

      _showErrorMessage(errorMessage);
    } finally {
      if (mounted) setState(() => _isResendingEmail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgStart,
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackground(size)),
          SafeArea(child: _buildPortraitLayout(size)),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(Size size) {
    final isSmallScreen = size.height < 700;
    final isTinyScreen = size.height < 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Responsive header height based on screen size
            SizedBox(
              height: isTinyScreen ? constraints.maxHeight * 0.25 :
              isSmallScreen ? constraints.maxHeight * 0.3 :
              constraints.maxHeight * 0.35,
              child: AnimatedHeader(
                title: AppLocalizations.of(context)!.verifyYourEmail,
                subtitle: widget.isFromLogin
                    ? AppLocalizations.of(context)!.checkYourEmailToContinue
                    : AppLocalizations.of(context)!.activateYourBrevityAccount,
                logoAssetPath: 'assets/logos/Brevity_white.png',
                screenSize: size,
                isLandscape: false,
              ),
            ),
            Expanded(child: _buildFormPanel()),
          ],
        );
      },
    );
  }

  Widget _buildBackground(Size size) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgStart, bgEnd],
        ),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (context, _) {
              final t = _floatAnim.value;
              final yOsc = math.sin(t * 2 * math.pi) * 20;
              final xOsc = math.cos(t * 2 * math.pi) * 12;
              return Positioned(
                left: -40 + xOsc,
                top: 80 + yOsc,
                child: Transform.rotate(
                  angle: 0.15 * math.sin(t * 2 * math.pi),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.4),
                        radius: 1.2,
                        colors: [
                          primaryA.withAlpha((0.08 * 255).toInt()),
                          primaryB.withAlpha((0.02 * 255).toInt()),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: Listenable.merge([_floatAnim, _pulseAnim]),
            builder: (context, _) {
              final f = _floatAnim.value;
              final p = _pulseAnim.value;
              final y = math.cos(f * 2 * math.pi + math.pi / 3) * 15;
              final x = math.sin(f * 2 * math.pi + math.pi / 3) * 10;
              return Positioned(
                right: -20 + x,
                top: 140 + y,
                child: Transform.scale(
                  scale: p,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                      gradient: RadialGradient(
                        center: const Alignment(0.4, -0.2),
                        radius: 1.0,
                        colors: [
                          primaryB.withAlpha((0.06 * 255).toInt()),
                          primaryA.withAlpha((0.01 * 255).toInt()),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          ...List.generate(6, (i) {
            return AnimatedBuilder(
              animation: _floatAnim,
              builder: (context, _) {
                final offset = (i * math.pi / 3);
                final x =
                    50 + math.cos(_floatAnim.value * 2 * math.pi + offset) * 30;
                final y =
                    200 +
                        math.sin(_floatAnim.value * 2 * math.pi + offset) * 20;
                final opacity =
                    (math.sin(_floatAnim.value * 2 * math.pi + offset) + 1) *
                        0.02;

                return Positioned(
                  left: x,
                  top: y,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryB.withAlpha((opacity * 255).toInt()),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFormPanel() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTinyScreen = MediaQuery.of(context).size.height < 600;

        return AnimatedBuilder(
          animation: _shakeAnim,
          builder: (context, child) {
            final shakeOffset = math.sin(_shakeAnim.value * math.pi * 8) * 2;
            return Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [panelTop, panelBottom],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTinyScreen ? 16 : 24,
                    vertical: isTinyScreen ? 8 : 4,
                  ),
                  child: Column(
                    children: [
                      // Progress indicator
                      LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: Colors.white.withAlpha((0.1 * 255).toInt()),
                        valueColor: AlwaysStoppedAnimation(primaryB),
                        minHeight: 2,
                      ),

                      SizedBox(height: isTinyScreen ? 12 : 20),

                      // Status section - made more compact
                      Flexible(
                        flex: isTinyScreen ? 3 : 4,
                        child: FadeTransition(
                          opacity: _fadeController,
                          child: AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (context, _) {
                              return Transform.scale(
                                scale: 1.0 + (_pulseAnim.value - 1.0) * 0.02,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(isTinyScreen ? 12 : 20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        primaryA.withAlpha((0.08 * 255).toInt()),
                                        primaryB.withAlpha((0.04 * 255).toInt()),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: primaryB.withAlpha((0.2 * 255).toInt()),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryA.withAlpha((0.1 * 255).toInt()),
                                        blurRadius: 20,
                                        spreadRadius: -5,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Status icon - responsive size
                                      Container(
                                        width: isTinyScreen ? 40 : 56,
                                        height: isTinyScreen ? 40 : 56,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [primaryA, primaryB],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryB.withAlpha((0.3 * 255).toInt()),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.schedule_rounded,
                                          size: isTinyScreen ? 20 : 28,
                                          color: Colors.white,
                                        ),
                                      ),

                                      SizedBox(height: isTinyScreen ? 8 : 16),

                                      Text(
                                        AppLocalizations.of(context)!.verificationPending,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTinyScreen ? 16 : 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),

                                      SizedBox(height: isTinyScreen ? 4 : 8),

                                      Text(
                                        'Almost there! Just one more step',
                                        style: TextStyle(
                                          color: mutedText,
                                          fontSize: isTinyScreen ? 12 : 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: isTinyScreen ? 8 : 16),

                      // Email display - more compact
                      FadeTransition(
                        opacity: _fadeController,
                        child: Container(
                          padding: EdgeInsets.all(isTinyScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B131A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primaryB.withAlpha((0.3 * 255).toInt()),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: primaryB,
                                size: isTinyScreen ? 16 : 20,
                              ),
                              SizedBox(width: isTinyScreen ? 8 : 12),
                              Expanded(
                                child: Text(
                                  widget.email,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTinyScreen ? 13 : 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isTinyScreen ? 8 : 12),

                      // Description - more compact
                      FadeTransition(
                        opacity: _fadeController,
                        child: Text(
                          widget.isFromLogin
                              ? 'Check your email and click the verification link, then try logging in again.'
                              : 'We\'ve sent a verification link to your email. Check your inbox and spam folder.',
                          style: TextStyle(
                            fontSize: isTinyScreen ? 12 : 14,
                            color: mutedText,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: isTinyScreen ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const Spacer(),

                      // Buttons section
                      Column(
                        children: [
                          // Check Verification Button
                          if (AuthService().isAuthenticated) ...[
                            FadeTransition(
                              opacity: _fadeController,
                              child: SizedBox(
                                height: isTinyScreen ? 44 : 52,
                                child: EnhancedButton(
                                  onPressed: _isCheckingVerification ? null : _checkVerification,
                                  isLoading: _isCheckingVerification,
                                  text: AppLocalizations.of(context)!.checkVerification,
                                  enabled: !_isCheckingVerification,
                                  loadingText: 'Checking...',
                                ),
                              ),
                            ),
                            SizedBox(height: isTinyScreen ? 8 : 12),
                          ],

                          // Resend Email Button
                          FadeTransition(
                            opacity: _fadeController,
                            child: SizedBox(
                              height: isTinyScreen ? 44 : 52,
                              child: EnhancedOutlinedButton(
                                onPressed: (_isResendingEmail || _resendCooldown > 0) ? null : _resendVerificationEmail,
                                isLoading: _isResendingEmail,
                                text: _resendCooldown > 0
                                    ? 'RESEND IN ${_formatTime(_resendCooldown).toUpperCase()}'
                                    : AppLocalizations.of(context)!.resendEmail,
                                loadingText: 'Sending...',
                                enabled: !_isResendingEmail && _resendCooldown == 0,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isTinyScreen ? 8 : 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Enhanced Button (consistent with login/signup)
class EnhancedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final bool enabled;
  final String loadingText;

  const EnhancedButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.enabled = true,
    this.loadingText = 'Loading...',
  });

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _glowAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTinyScreen = screenSize.height < 600;

    return GestureDetector(
      onTapDown: widget.enabled && !widget.isLoading ? (_) => _animController.forward() : null,
      onTapUp: widget.enabled && !widget.isLoading ? (_) => _animController.reverse() : null,
      onTapCancel: widget.enabled && !widget.isLoading ? () => _animController.reverse() : null,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: widget.enabled && !widget.isLoading
                    ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryA, primaryB],
                )
                    : LinearGradient(
                  colors: [
                    Colors.grey.withAlpha((0.3 * 255).toInt()),
                    Colors.grey.withAlpha((0.2 * 255).toInt()),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.enabled && !widget.isLoading
                    ? [
                  BoxShadow(
                    color: primaryA.withAlpha(
                      ((0.3 + (_glowAnim.value * 0.2)) * 255).toInt(),
                    ),
                    blurRadius: 12 + (_glowAnim.value * 8),
                    offset: const Offset(0, 6),
                  ),
                ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: widget.enabled && !widget.isLoading ? widget.onPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: widget.isLoading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: isTinyScreen ? 18 : 24,
                      height: isTinyScreen ? 18 : 24,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: isTinyScreen ? 8 : 12),
                    Flexible(
                      child: Text(
                        widget.loadingText,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: isTinyScreen ? 14 : 16,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
                    : Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.enabled ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.w700,
                    fontSize: isTinyScreen ? 14 : 16,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EnhancedOutlinedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final String loadingText;
  final bool enabled;

  const EnhancedOutlinedButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.loadingText = 'Loading...',
    this.enabled = true,
  });

  @override
  State<EnhancedOutlinedButton> createState() => _EnhancedOutlinedButtonState();
}

class _EnhancedOutlinedButtonState extends State<EnhancedOutlinedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnim;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnim = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool hovered) {
    setState(() => isHovered = hovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTinyScreen = screenSize.height < 600;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.enabled && !widget.isLoading ? widget.onPressed : null,
        child: AnimatedBuilder(
          animation: _hoverAnim,
          builder: (context, child) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color.lerp(
                  Colors.transparent,
                  primaryA.withAlpha((0.1 * 255).toInt()),
                  _hoverAnim.value,
                ),
                border: Border.all(
                  color: Color.lerp(
                    widget.enabled && !widget.isLoading
                        ? primaryB.withAlpha((0.8 * 255).toInt())
                        : Colors.grey.withAlpha((0.5 * 255).toInt()),
                    primaryB,
                    _hoverAnim.value,
                  )!,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.enabled && !widget.isLoading
                    ? [
                  BoxShadow(
                    color: primaryB.withAlpha(
                      ((0.1 + (_hoverAnim.value * 0.2)) * 255).toInt(),
                    ),
                    blurRadius: 8 + (_hoverAnim.value * 12),
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: isTinyScreen ? 16 : 20,
                      height: isTinyScreen ? 16 : 20,
                      child: CircularProgressIndicator(
                        color: primaryB,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: isTinyScreen ? 8 : 12),
                    Flexible(
                      child: Text(
                        widget.loadingText,
                        style: TextStyle(
                          color: primaryB,
                          fontWeight: FontWeight.w700,
                          fontSize: isTinyScreen ? 14 : 16,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
                    : Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.enabled
                        ? primaryB
                        : Colors.grey.withAlpha((0.7 * 255).toInt()),
                    fontWeight: FontWeight.w700,
                    fontSize: isTinyScreen ? 14 : 16,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}