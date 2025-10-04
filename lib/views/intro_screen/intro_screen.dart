import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

import '../../controller/cubit/theme/theme_cubit.dart';
import '../../controller/services/tutorial_service.dart';
import '../../models/theme_model.dart';

// Enhanced Palette (matching auth design)
const Color bgStart = Color(0xFF070B14);
const Color bgEnd = Color(0xFF0E1624);
const Color primaryA = Color(0xFF3D4DFF);
const Color primaryB = Color(0xFF29C0FF);
const Color panelTop = Color(0xFF0F1724);
const Color panelBottom = Color(0xFF111827);
const Color mutedText = Color(0xFF9AA8BF);
const Color successColor = Color(0xFF10B981);

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showThemeSelection = false;
  AppTheme _selectedTheme = AppTheme.defaultTheme;
  bool _isDarkMode = true;

  // Animation controllers - removed slide and fade controllers that were causing issues
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  // Animations - keeping only the background animations
  late Animation<double> _floatAnim;
  late Animation<double> _pulseAnim;

  List<IntroPage> pages(BuildContext context) => [
        IntroPage(
          title: AppLocalizations.of(context)!.welcomeToBrevity,
          subtitle: AppLocalizations.of(context)!.yourSmartNewsCompanion,
          description:
              'Skip the long reads, not the knowledge. Get straight to the point with intelligent, 60-word summaries of the world\'s top stories.',
          icon: Icons.newspaper_outlined,
        ),

        IntroPage(
          title: AppLocalizations.of(context)!.aFeedJustForYou,
          subtitle: AppLocalizations.of(context)!.tailoredToYourTastes,
          description:
              'Like and dislike stories to shape your personal news feed. The more you engage, the smarter it gets.',
          icon: Icons.tune_outlined,
        ),

        IntroPage(
          title: AppLocalizations.of(context)!.aiPoweredInsights,
          subtitle: AppLocalizations.of(context)!.goBeyondHeadlines,
          description:
              'Have questions? Ask our AI assistant about any news story for detailed, context-aware answers.',
          icon: Icons.psychology_outlined,
        ),

        IntroPage(
          title: AppLocalizations.of(context)!.personalizeYourExperience,
          subtitle: AppLocalizations.of(context)!.themesAndCustomization,
          description:
              'Choose your preferred theme and customize your reading experience with multiple color options.',
          icon: Icons.palette_outlined,
        ),
    ];


  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _showThemeSelectionScreen() {
    setState(() => _showThemeSelection = true);
  }

  void _completeIntro() async {
    // Apply the selected theme
    context.read<ThemeCubit>().changeTheme(
      _selectedTheme.copyWith(isDarkMode: _isDarkMode),
    );

    // Mark tutorial as completed
    await TutorialService.completeTutorial();

    // Navigate to home
    if (mounted) {
      context.pushReplacement('/home/0');
    }
  }

  // Helper method to get surface color based on theme mode
  Color _getSurfaceColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  }

  // Helper method to get card color based on theme mode
  Color _getCardColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5);
  }

  // Helper method to get on surface color based on theme mode
  Color _getOnSurfaceColor(bool isDarkMode) {
    return isDarkMode ? Colors.white : Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgStart,
      body: Stack(
        children: [
          // Background matching auth design
          Positioned.fill(child: _buildBackground(size)),

          // Main Content
          SafeArea(
            child:
                _showThemeSelection
                    ? _buildThemeSelectionScreen()
                    : _buildIntroPages(size),
          ),
        ],
      ),
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
          // Floating particles (matching auth design)
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

          // Particle dots
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

  Widget _buildIntroPages(Size size) {
    return Column(
      children: [
        // Page Content with smooth custom transitions
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: pages(context).length,
            itemBuilder: (context, index) => _buildPage(pages(context)[index], index),
          ),
        ),
        _buildBottomPanel(),
      ],
    );
  }

  Widget _buildPage(IntroPage page, int pageIndex) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        double scale = 1.0;
        double opacity = 1.0;
        double horizontalTranslation = 0.0;

        if (_pageController.position.haveDimensions) {
          final size = MediaQuery.of(context).size;
          value = (_pageController.page ?? 0.0) - pageIndex;
          horizontalTranslation = value * -size.width / 2.5;

          scale = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
          opacity = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
        } else {
          if (pageIndex != _currentPage) {
            opacity = 0.0;
            scale = 0.8;
          }
        }

        return Transform.translate(
          offset: Offset(horizontalTranslation, 0),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnim.value,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryA.withAlpha((0.2 * 255).toInt()),
                                  primaryB.withAlpha((0.1 * 255).toInt()),
                                ],
                              ),
                              border: Border.all(
                                color: primaryA.withAlpha((0.3 * 255).toInt()),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              page.icon,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Title with subtle animation
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(
                          alpha: opacity > 0.8 ? 1.0 : 0.7,
                        ),
                        letterSpacing: -0.5,
                      ),
                      child: Text(page.title, textAlign: TextAlign.center),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryB.withValues(alpha: opacity > 0.8 ? 1.0 : 0.6),
                      ),
                      child: Text(page.subtitle, textAlign: TextAlign.center),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withAlpha(
                          ((0.8 * opacity) * 255).toInt(),
                        ),
                        height: 1.5,
                      ),
                      child: Text(
                        page.description,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomPanel() {
  final isLastPage = _currentPage == pages(context).length - 1;

    return Container(
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pages(context).length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 5,
                decoration: BoxDecoration(
                  color:
                      _currentPage == index
                          ? primaryB
                          : Colors.white.withAlpha((0.3 * 255).toInt()),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Navigation Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (isLastPage) {
                  _showThemeSelectionScreen();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryA, primaryB],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryA.withAlpha((0.3 * 255).toInt()),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  isLastPage ? AppLocalizations.of(context)!.customizeTheme.toUpperCase() : AppLocalizations.of(context)!.next.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelectionScreen() {
    return Container(
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
        padding: const EdgeInsets.all(24),
        child: AnimatedOpacity(
          opacity: _showThemeSelection ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          child: AnimatedSlide(
            offset: _showThemeSelection ? Offset.zero : const Offset(0, 0.1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showThemeSelection = false;
                        });
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),

                const SizedBox(height: 20),

                // Header
                const Text(
                  'Customize Your\nExperience',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.chooseThemeAndMode,
                  style: TextStyle(
                    fontSize: 14,
                    color: mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 32),

                // Dark/Light Mode Toggle
                _buildModeSelector(),

                const SizedBox(height: 24),

                // Theme Colors
                Text(
                  AppLocalizations.of(context)!.themeColor,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                _buildThemeSelector(),

                const SizedBox(height: 32),

                // Preview Card
                _buildThemePreview(),

                const SizedBox(height: 32),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.mode,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B131A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1F2937), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildModeOption(
                  AppLocalizations.of(context)!.darkMode,
                  Icons.dark_mode_outlined,
                  true,
                  _isDarkMode,
                ),
              ),
              Expanded(
                child: _buildModeOption(
                  AppLocalizations.of(context)!.lightMode,
                  Icons.light_mode_outlined,
                  false,
                  !_isDarkMode,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeOption(
    String title,
    IconData icon,
    bool isDark,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _isDarkMode = isDark),
      child: Container(
        // Removed AnimatedContainer - this makes the change instant
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? const LinearGradient(colors: [primaryA, primaryB])
                  : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children:
          AppTheme.availableThemes.map((theme) {
            final isSelected = _selectedTheme.name == theme.name;
            return GestureDetector(
              onTap: () => setState(() => _selectedTheme = theme),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withAlpha(
                        isSelected ? (0.4 * 255).toInt() : (0.2 * 255).toInt(),
                      ),
                      blurRadius: isSelected ? 12 : 6,
                      spreadRadius: isSelected ? 2 : 0,
                    ),
                  ],
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
              ),
            );
          }).toList(),
    );
  }

  Widget _buildThemePreview() {
    final surfaceColor = _getSurfaceColor(_isDarkMode);
    final cardColor = _getCardColor(_isDarkMode);
    final onSurfaceColor = _getOnSurfaceColor(_isDarkMode);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha((0.1 * 255).toInt()),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.preview,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceColor,
                ),
              ),
              const Spacer(),
              Text(
                _selectedTheme.name,
                style: TextStyle(
                  fontSize: 12,
                  color: _selectedTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _selectedTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.article,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.sampleNewsArticle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.newsCardPreview,
                        style: TextStyle(
                          color: onSurfaceColor.withAlpha((0.7 * 255).toInt()),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _completeIntro,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryA, primaryB],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryA.withAlpha((0.3 * 255).toInt()),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.getStarted,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IntroPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  IntroPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}

