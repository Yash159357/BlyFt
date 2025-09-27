import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brevity/controller/bloc/bookmark_bloc/bookmark_bloc.dart';
import 'package:brevity/controller/bloc/bookmark_bloc/bookmark_event.dart';
import 'package:brevity/controller/cubit/theme/theme_cubit.dart';
import 'package:brevity/controller/services/news_services.dart';
import 'package:brevity/models/article_model.dart';
import 'package:brevity/views/common_widgets/common_appbar.dart';
import 'package:brevity/views/common_widgets/list_of_article.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import 'package:brevity/models/theme_model.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen>
    with TickerProviderStateMixin {
  late Future<List<Article>> _searchResults;
  late Animation<double> _animation;
  late AnimationController _animationController;
  late AnimationController _particleAnimationController;
  final NewsService _newsService = NewsService();

  @override
  void initState() {
    super.initState();
    _searchResults = _newsService.searchNews(widget.query);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<ThemeCubit>().currentTheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FutureBuilder<List<Article>>(
        future: _searchResults,
        builder: (context, snapshot) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: theme.colorScheme.surface.withAlpha((0.85 * 255).toInt()),
                expandedHeight: 70,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: ParticlesHeader(
                    title: "Results for ${widget.query}",
                    themeColor: currentTheme.primaryColor,
                    particleAnimation: _particleAnimationController,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 35)),
              _buildContentSlivers(snapshot, currentTheme),
            ],
          );
        },
      ),
    );
  }

  void _launchArticle(String url) async {
    final currentTheme = context.read<ThemeCubit>().currentTheme;

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              '${AppLocalizations.of(context)!.failedToOpenArticle}: $e',
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.dismiss,
              textColor: currentTheme.primaryColor,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Widget _buildContentSlivers(
      AsyncSnapshot<List<Article>> snapshot,
      AppTheme currentTheme,
      ) {
    final theme = Theme.of(context);

    if (snapshot.connectionState == ConnectionState.waiting) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            color: currentTheme.primaryColor,
          ),
        ),
      );
    }

    if (snapshot.hasError) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '${AppLocalizations.of(context)!.error}: ${snapshot.error}',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentTheme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _searchResults = _newsService.searchNews(widget.query);
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh, size: 18),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.retrySearch),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final results = snapshot.data ?? [];

    if (results.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: currentTheme.primaryColor.withAlpha((0.15 * 255).toInt()),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.search_off,
                  size: 70,
                  color: currentTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.noResultsFoundFor(widget.query),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.tryDifferentSearch,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentTheme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: currentTheme.primaryColor.withAlpha((0.5 * 255).toInt()),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.searchAgain,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final article = results[index];
        return FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(_animation),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 22, right: 22),
              child: ArticleListItem(
                onSide: () => context.read<BookmarkBloc>().add(
                  ToggleBookmarkEvent(article),
                ),
                article: article,
                onTap: () => _launchArticle(article.url),
                showBookmark: true,
                showRemove: false,
              ),
            ),
          ),
        );
      }, childCount: results.length),
    );
  }
}
