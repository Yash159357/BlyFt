import 'dart:async';
import 'dart:math' as math;

import 'package:brevity/controller/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';

import '../common_widgets/auth_header.dart';

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

class ForgotPasswordScreen extends StatefulWidget {
  final void Function() goToLoginPage;
  const ForgotPasswordScreen({super.key, required this.goToLoginPage});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _sentOtp = false;
  bool _isLoading = false;

  // Validation states
  bool _emailValid = false;
  bool _otpValid = false;
  bool _newPasswordValid = false;
  bool _confirmPasswordValid = false;
  String? _emailError;
  String? _otpError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  // Animations (matching login screen)
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _floatController;
  late final AnimationController _pulseController;
  late final AnimationController _shakeController;

  late final Animation<double> _floatAnim;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _shakeAnim;

  late Timer _timer;
  int _timerDuration = 30;
  int _remainingSeconds = 0;

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

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
    _floatAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
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

    // Add listeners for real-time validation
    _emailController.addListener(_validateEmail);
    _otpController.addListener(_validateOtp);
    _newPasswordController.addListener(_validateNewPassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    if (_remainingSeconds > 0) _timer.cancel();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    final isValid =
        email.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (_emailValid != isValid) {
      setState(() {
        _emailValid = isValid;
        _emailError =
            email.isEmpty
                ? null
                : (isValid ? null : 'Please enter a valid email');
      });
    }
  }

  void _validateOtp() {
    final otp = _otpController.text;
    final isValid = otp.length == 6;
    if (_otpValid != isValid) {
      setState(() {
        _otpValid = isValid;
        _otpError =
            otp.isEmpty ? null : (isValid ? null : 'OTP must be 6 digits');
      });
    }
  }

  void _validateNewPassword() {
    final password = _newPasswordController.text;
    final isValid = password.length >= 8;
    if (_newPasswordValid != isValid) {
      setState(() {
        _newPasswordValid = isValid;
        _newPasswordError =
            password.isEmpty
                ? null
                : (isValid ? null : 'Password must be at least 8 characters');
      });
    }
  }

  void _validateConfirmPassword() {
    final confirmPassword = _confirmPasswordController.text;
    final isValid =
        confirmPassword.isNotEmpty &&
        confirmPassword == _newPasswordController.text;
    if (_confirmPasswordValid != isValid) {
      setState(() {
        _confirmPasswordValid = isValid;
        _confirmPasswordError =
            confirmPassword.isEmpty
                ? null
                : (isValid ? null : 'Passwords do not match');
      });
    }
  }

  bool get _canReset =>
      _emailValid &&
      _otpValid &&
      _newPasswordValid &&
      _confirmPasswordValid &&
      !_isLoading;

  _setTimer(int seconds) {
    _remainingSeconds = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  void _sendOtp() {
    if (_emailController.text.isEmpty &&
        !RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(_emailController.text)) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: errorColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Please enter a valid email',
                style: TextStyle(color: Colors.white),
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
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
      _sentOtp = true;
    });

    AuthService()
        .forgotPassword(email: _emailController.text, context: context)
        .then((_) {
          _setTimer(_timerDuration);
          _timerDuration += 30;
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'OTP sent to your email',
                    style: TextStyle(color: Colors.white),
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
        });
  }

  void _resendOtp() {
    if (_emailController.text.isEmpty &&
        !RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(_emailController.text)) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: errorColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Please enter a valid email',
                style: TextStyle(color: Colors.white),
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
      return;
    }

    if (_remainingSeconds > 0) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.timer_rounded, color: warningColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Please wait $_remainingSeconds seconds before resending OTP',
                style: TextStyle(color: Colors.white),
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
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    AuthService()
        .forgotPassword(email: _emailController.text, context: context)
        .then((_) {
          _setTimer(_timerDuration);
          _timerDuration += 30;
        });
  }

  void _submitReset() {
    HapticFeedback.lightImpact();

    if (!_formKey.currentState!.validate()) {
      _shakeController.forward().then((_) => _shakeController.reset());
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    AuthService()
        .resetPassword(
          email: _emailController.text,
          otp: _otpController.text,
          newPassword: _newPasswordController.text,
          context: context,
        )
        .then((success) {
          setState(() => _isLoading = false);
          if (success) {
            HapticFeedback.mediumImpact();
            if (mounted) {
              _formKey.currentState!.reset();
              _emailController.clear();
              _otpController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
              _sentOtp = false;
              _remainingSeconds = 0;
              if (_remainingSeconds > 0) _timer.cancel();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: successColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Password reset successfully!',
                        style: TextStyle(color: Colors.white),
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

              widget.goToLoginPage();
            }
          }
        })
        .catchError((error) {
          setState(() => _isLoading = false);
          HapticFeedback.heavyImpact();
          _shakeController.forward().then((_) => _shakeController.reset());
        });
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
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(Size size) {
    return Column(
      children: [
        AnimatedHeader(
          title: AppLocalizations.of(context)!.resetPassword,
          subtitle: AppLocalizations.of(context)!.enterEmailForReset,
          logoAssetPath: 'assets/logos/Brevity_white.png',
          screenSize: size,
          isLandscape: false,
        ),
        _buildFormPanel(),
      ],
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
    return Expanded(
      child: AnimatedBuilder(
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20, // Reduced from 24
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress indicator
                      LinearProgressIndicator(
                        value: _getProgressValue(),
                        backgroundColor: Colors.white.withAlpha(
                          (0.1 * 255).toInt(),
                        ),
                        valueColor: AlwaysStoppedAnimation(primaryB),
                        minHeight: 2,
                      ),

                      const SizedBox(height: 20), // Reduced from 24

                      EnhancedTextField(
                        controller: _emailController,
                        label: AppLocalizations.of(context)!.emailAddress,
                        hintText: AppLocalizations.of(context)!.enterYourEmail,
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        isValid: _emailValid,
                        errorText: _emailError,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppLocalizations.of(context)!.emailIsRequired;
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(v)) {
                            return AppLocalizations.of(context)!.pleaseEnterValidEmail;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12), // Reduced from 16
                      // OTP field and button in same row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: EnhancedTextField(
                              controller: _otpController,
                        label: AppLocalizations.of(context)!.otp,
                              hintText: 'Enter 6-digit OTP',
                              icon: Icons.numbers_rounded,
                              keyboardType: TextInputType.number,
                              isValid: _otpValid,
                              errorText: _otpError,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return AppLocalizations.of(context)!.otpIsRequired;
                                }
                                if (v.length != 6) {
                                  return 'OTP must be 6 digits';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 30),
                                SizedBox(
                                  height: 48,
                                  child:
                                      !_sentOtp
                                          ? EnhancedSecondaryButton(
                                            onPressed:
                                                _emailValid && !_isLoading
                                                    ? _sendOtp
                                                    : null,
                                            text: AppLocalizations.of(context)!.send,
                                            isLoading: _isLoading && !_sentOtp,
                                          )
                                          : Container(
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0D1117),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color:
                                                    _remainingSeconds > 0 ||
                                                            _isLoading
                                                        ? Colors.white
                                                            .withAlpha(
                                                              (0.08 * 255)
                                                                  .toInt(),
                                                            )
                                                        : primaryB.withAlpha(
                                                          (0.3 * 255).toInt(),
                                                        ),
                                                width: 1,
                                              ),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                onTap:
                                                    _remainingSeconds == 0 &&
                                                            !_isLoading
                                                        ? _resendOtp
                                                        : null,
                                                child: Center(
                                                  child: Text(
                                                    _remainingSeconds > 0
                                                        ? '${_remainingSeconds}s'
                                                        : AppLocalizations.of(context)!.resend,
                                                    style: TextStyle(
                                                      color:
                                                          _remainingSeconds >
                                                                      0 ||
                                                                  _isLoading
                                                              ? mutedText
                                                              : primaryB,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12), // Reduced from 16

                      EnhancedTextField(
                        controller: _newPasswordController,
                        label: AppLocalizations.of(context)!.newPassword,
                        hintText: AppLocalizations.of(context)!.enterNewPassword,
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscureNewPassword,
                        isValid: _newPasswordValid,
                        errorText: _newPasswordError,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(
                              () => _obscureNewPassword = !_obscureNewPassword,
                            );
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              key: ValueKey(_obscureNewPassword),
                              color:
                                  _newPasswordValid ? successColor : primaryA,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppLocalizations.of(context)!.newPasswordIsRequired;
                          }
                          if (v.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12), // Reduced from 16

                      EnhancedTextField(
                        controller: _confirmPasswordController,
                        label: AppLocalizations.of(context)!.confirmPassword,
                        hintText: AppLocalizations.of(context)!.confirmNewPassword,
                        icon: Icons.lock_rounded,
                        obscureText: _obscureConfirmPassword,
                        isValid: _confirmPasswordValid,
                        errorText: _confirmPasswordError,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(
                              () =>
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                            );
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              key: ValueKey(_obscureConfirmPassword),
                              color:
                                  _confirmPasswordValid
                                      ? successColor
                                      : primaryA,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppLocalizations.of(context)!.pleaseConfirmPassword;
                          }
                          if (v != _newPasswordController.text) {
                            return AppLocalizations.of(context)!.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24), // Reduced from 32
                      // Enhanced reset button - made slightly smaller
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: SizedBox(
                            height: 48, // Reduced from 52
                            child: EnhancedButton(
                              onPressed: _canReset ? _submitReset : null,
                              isLoading: _isLoading && _sentOtp,
                              text: AppLocalizations.of(context)!.resetPasswordButton,
                              enabled: _canReset,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20), // Reduced from 24
                      // Back to login
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.goToLoginPage();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.backToLogin,
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20), // Reduced from 24
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _getProgressValue() {
    int validFields = 0;
    if (_emailValid) validFields++;
    if (_otpValid) validFields++;
    if (_newPasswordValid) validFields++;
    if (_confirmPasswordValid) validFields++;
    return validFields / 4.0;
  }
}

// -------------------- Enhanced Components (from login screen) --------------------

class EnhancedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isValid;
  final String? errorText;

  const EnhancedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.isValid = false,
    this.errorText,
  });

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField>
    with SingleTickerProviderStateMixin {
  bool _focused = false;
  bool _hasContent = false;
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasContent = widget.controller.text.isNotEmpty;
    if (hasContent != _hasContent) {
      setState(() => _hasContent = hasContent);
      if (hasContent) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  Color get _getBorderColor {
    if (widget.errorText != null && _hasContent) return errorColor;
    if (widget.isValid && _hasContent) return successColor;
    if (_focused) return primaryA;
    if (_hasContent) return const Color(0xFF374151);
    return const Color(0xFF1F2937);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (focused) {
            setState(() => _focused = focused);
            if (focused) {
              HapticFeedback.selectionClick();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: const Color(0xFF0B131A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor,
                width: _focused ? 2 : 1,
              ),
              boxShadow:
                  _focused
                      ? [
                        BoxShadow(
                          color: primaryA.withAlpha((0.1 * 255).toInt()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.white.withAlpha((0.4 * 255).toInt()),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Icon(
                      widget.icon,
                      color: Color.lerp(
                        _focused ? primaryA : Colors.white54,
                        widget.isValid && _hasContent
                            ? successColor
                            : (_focused ? primaryA : Colors.white54),
                        _animation.value,
                      ),
                      size: 20,
                    );
                  },
                ),
                suffixIcon:
                    widget.suffixIcon ??
                    (_hasContent && widget.isValid
                        ? Icon(
                          Icons.check_circle_rounded,
                          color: successColor,
                          size: 20,
                        )
                        : null),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        if (widget.errorText != null && _hasContent)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: errorColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class EnhancedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final bool enabled;

  const EnhancedButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.enabled = true,
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
    return GestureDetector(
      onTapDown:
          widget.enabled && !widget.isLoading
              ? (_) => _animController.forward()
              : null,
      onTapUp:
          widget.enabled && !widget.isLoading
              ? (_) => _animController.reverse()
              : null,
      onTapCancel:
          widget.enabled && !widget.isLoading
              ? () => _animController.reverse()
              : null,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient:
                    widget.enabled && !widget.isLoading
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
                boxShadow:
                    widget.enabled && !widget.isLoading
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
                onPressed:
                    widget.enabled && !widget.isLoading
                        ? widget.onPressed
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child:
                    widget.isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          widget.text,
                          style: TextStyle(
                            color:
                                widget.enabled ? Colors.white : Colors.white54,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: -0.2,
                          ),
                        ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EnhancedSecondaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  const EnhancedSecondaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  @override
  State<EnhancedSecondaryButton> createState() =>
      _EnhancedSecondaryButtonState();
}

class _EnhancedSecondaryButtonState extends State<EnhancedSecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnim;
  bool _isHovered = false;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          widget.onPressed != null && !widget.isLoading
              ? (_) {
                setState(() => _isHovered = true);
                _hoverController.forward();
              }
              : null,
      onTapUp:
          widget.onPressed != null && !widget.isLoading
              ? (_) {
                setState(() => _isHovered = false);
                _hoverController.reverse();
              }
              : null,
      onTapCancel:
          widget.onPressed != null && !widget.isLoading
              ? () {
                setState(() => _isHovered = false);
                _hoverController.reverse();
              }
              : null,
      child: AnimatedBuilder(
        animation: _hoverAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_hoverAnim.value * 0.02),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Color.lerp(
                  const Color(0xFF0D1117),
                  const Color(0xFF161B22),
                  _hoverAnim.value,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      Color.lerp(
                        Colors.white.withAlpha((0.08 * 255).toInt()),
                        primaryB.withAlpha((0.3 * 255).toInt()),
                        _hoverAnim.value,
                      )!,
                  width: 1,
                ),
                boxShadow:
                    _isHovered
                        ? [
                          BoxShadow(
                            color: primaryB.withAlpha((0.1 * 255).toInt()),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: ElevatedButton(
                onPressed:
                    widget.onPressed != null && !widget.isLoading
                        ? widget.onPressed
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    widget.isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          widget.text,
                          style: TextStyle(
                            color:
                                widget.onPressed != null
                                    ? Colors.white
                                    : Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          );
        },
      ),
    );
  }
}
