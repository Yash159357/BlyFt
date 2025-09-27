import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:brevity/controller/cubit/theme/theme_cubit.dart';
import 'package:brevity/models/theme_model.dart';
import '../../l10n/app_localizations.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildGlassContainer({
    required BuildContext context,
    required Widget child,
    double? opacity,
    EdgeInsets? margin,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor.withAlpha(((isDarkMode ? 0.5 : 0.8) * 255).toInt()),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: baseColor.withAlpha((0.12 * 255).toInt()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: child,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final theme = Theme.of(context);
    final appTheme = themeCubit.currentTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appTheme.primaryColor.withAlpha((0.2 * 255).toInt()),
              theme.colorScheme.surface,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildAppBar(appTheme),
                const Gap(24),
                _buildAppInfoSection(appTheme),
                const Gap(20),
                _buildFeaturesSection(appTheme),
                const Gap(20),
                _buildDeveloperSection(appTheme),
                const Gap(20),
                _buildVersionSection(appTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(AppTheme appTheme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildGlassContainer(
        context: context,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const Gap(8),
            Text(
              AppLocalizations.of(context)!.aboutUnity,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(AppTheme appTheme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildGlassContainer(
        context: context,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: appTheme.primaryColor.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.newspaper_rounded,
                    color: appTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const Gap(12),
                Text(
                  AppLocalizations.of(context)!.unityNews,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Gap(16),
            Text(
              'AI-Powered News Platform',
              style: TextStyle(
                color: appTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(12),
            Text(
              'Stay informed with curated news from reliable sources. Our intelligent chatbot helps you understand and discuss articles in real-time.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(AppTheme appTheme) {
    final features = [
      {
        'icon': Icons.auto_awesome,
        'title': AppLocalizations.of(context)!.aiChatAssistant,
        'description': AppLocalizations.of(context)!.discussArticlesChatbot,
      },
      {
        'icon': Icons.article_outlined,
        'title': AppLocalizations.of(context)!.curatedContent,
        'description': AppLocalizations.of(context)!.newsReliableSources,
      },
      {
        'icon': Icons.speed,
        'title': AppLocalizations.of(context)!.realtimeUpdates,
        'description': AppLocalizations.of(context)!.stayUpdatedLatestNews,
      },
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildGlassContainer(
        context: context,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: appTheme.primaryColor.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: appTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const Gap(12),
                Text(
                  AppLocalizations.of(context)!.features,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Gap(16),
            ...features.map((feature) => _buildFeatureItem(appTheme, feature)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(AppTheme appTheme, Map<String, dynamic> feature) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha((0.5 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: baseColor.withAlpha((0.08 * 255).toInt()),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: appTheme.primaryColor.withAlpha((0.2 * 255).toInt()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(feature['icon'], color: appTheme.primaryColor, size: 16),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'],
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Gap(2),
                Text(
                  feature['description'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection(AppTheme appTheme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildGlassContainer(
        context: context,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: appTheme.primaryColor.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.code, color: appTheme.primaryColor, size: 20),
                ),
                const Gap(12),
                Text(
                  AppLocalizations.of(context)!.developers,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Gap(16),
            Text(
              'Meet the talented developers behind Unity News.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
                height: 1.4,
              ),
            ),
            const Gap(24),
            _buildDeveloperCard(
              name: 'Samarth Sharma',
              role: 'Co-Developer',
              portfolioUrl: 'https://saysamarth.netlify.app/',
              linkedinUrl: 'https://www.linkedin.com/in/saysamarth/',
              theme: appTheme,
            ),
            const Gap(16),
            _buildDeveloperCard(
              name: 'Yash',
              role: 'Co-Developer',
              portfolioUrl: 'https://portfolio-yash-914981.netlify.app/',
              linkedinUrl: 'https://www.linkedin.com/in/yash-kumar101/',
              theme: appTheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard({
    required String name,
    required String role,
    required String portfolioUrl,
    required String linkedinUrl,
    required AppTheme theme,
  }) {
    final uiTheme = Theme.of(context);
    final isDarkMode = uiTheme.brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: uiTheme.colorScheme.surface.withAlpha((0.5 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: baseColor.withAlpha((0.08 * 255).toInt()),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.primaryColor.withAlpha((0.2 * 255).toInt()),
                child: Text(
                  name.split(' ').map((n) => n[0]).take(2).join(),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: uiTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        color: theme.primaryColor.withAlpha((0.8 * 255).toInt()),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _launchUrl(portfolioUrl),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.primaryColor.withAlpha((0.3 * 255).toInt()),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.web, color: theme.primaryColor, size: 16),
                        const Gap(6),
                        Text(
                          'Portfolio',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(8),
              Expanded(
                child: InkWell(
                  onTap: () => _launchUrl(linkedinUrl),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: baseColor.withAlpha((0.04 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: baseColor.withAlpha((0.12 * 255).toInt()),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business,
                          color: baseColor.withAlpha((0.8 * 255).toInt()),
                          size: 16,
                        ),
                        const Gap(6),
                        Text(
                          'LinkedIn',
                          style: TextStyle(
                            color: baseColor.withAlpha((0.8 * 255).toInt()),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVersionSection(AppTheme appTheme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildGlassContainer(
        context: context,
        padding: const EdgeInsets.all(16),
        opacity: 0.04,
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: appTheme.primaryColor.withAlpha((0.7 * 255).toInt()),
              size: 16,
            ),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Version 1.0.0 • Built with Flutter',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha((0.08 * 255).toInt()),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    'Unity is created for news consumption and educational purposes.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
