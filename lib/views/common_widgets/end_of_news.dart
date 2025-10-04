import 'package:blyft/controller/cubit/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../controller/cubit/theme/theme_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/theme_model.dart';

class EndOfNewsScreen extends StatefulWidget {
  const EndOfNewsScreen({super.key});

  @override
  State<EndOfNewsScreen> createState() => _EndOfNewsScreenState();
}

class _EndOfNewsScreenState extends State<EndOfNewsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startAnimations();
  }

  void _startAnimations() async {
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final currentTheme = themeState.currentTheme;
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDarkMode
                    ? currentTheme.primaryColor.withAlpha(20)
                    : currentTheme.secondaryColor.withAlpha(150),
                isDarkMode
                    ? Color.fromARGB(255, 16, 16, 16)
                    : const Color.fromARGB(255, 255, 255, 255),
                isDarkMode
                    ? const Color.fromARGB(255, 28, 28, 28)
                    : const Color.fromARGB(255, 242, 242, 242),
                isDarkMode
                    ? currentTheme.primaryColor.withAlpha(12)
                    : currentTheme.secondaryColor.withAlpha(130),
              ],
              stops: const [0.0, 0.4, 0.65, 1.0],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZmlsdGVyIGlkPSJub2lzZSI+CiAgICA8ZmVUdXJidWxlbmNlIGJhc2VGcmVxdWVuY3k9IjAuOSIgbnVtT2N0YXZlcz0iNCIvPgogICAgPGZlQ29sb3JNYXRyaXggdHlwZT0ic2F0dXJhdGUiIHZhbHVlcz0iMCIvPgogIDwvZmlsdGVyPgogIDxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbHRlcj0idXJsKCNub2lzZSkiIG9wYWNpdHk9IjAuMDMiLz4KPC9zdmc+',
                ),
                repeat: ImageRepeat.repeat,
                opacity: 0.1,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: SizedBox(
                                width: 180,
                                height: 180,
                                child: Lottie.asset(
                                  'assets/lottie/end_screen.json',
                                  fit: BoxFit.contain,
                                  repeat: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const Gap(32),

                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildPrimaryMessage(theme),
                        ),
                      ),

                      const Gap(16),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildSecondaryMessage(theme),
                      ),

                      const Gap(40),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildActionButton(currentTheme, theme),
                      ),

                      const Gap(24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrimaryMessage(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Text(
      AppLocalizations.of(context)!.youreDoneForTheDay,
      style: GoogleFonts.poppins(
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSecondaryMessage(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.takeAWellDeservedBreak,
          style: GoogleFonts.inter(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(8),
        Text(
          AppLocalizations.of(context)!.newStoriesWillAppearSoon,
          style: GoogleFonts.inter(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButton(AppTheme currentTheme, ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.white : Colors.black;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          // Add your navigation logic here
        },
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withAlpha((0.5 * 255).toInt()),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: baseColor.withAlpha((0.08 * 255).toInt()),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explore_outlined,
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.7 * 255).toInt(),
                ),
                size: 18,
              ),
              const Gap(8),
              Text(
                AppLocalizations.of(context)!.exploreOtherSections,
                style: GoogleFonts.inter(
                  color: theme.colorScheme.onSurface.withAlpha(
                    (0.7 * 255).toInt(),
                  ),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

