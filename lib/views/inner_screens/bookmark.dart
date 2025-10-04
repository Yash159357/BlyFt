import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blyft/controller/bloc/bookmark_bloc/bookmark_event.dart';
import 'package:blyft/views/common_widgets/list_of_article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blyft/controller/bloc/bookmark_bloc/bookmark_bloc.dart';
import 'package:blyft/controller/bloc/bookmark_bloc/bookmark_state.dart';
import 'package:blyft/controller/cubit/theme/theme_cubit.dart';
import 'package:blyft/models/article_model.dart';
import 'package:blyft/views/common_widgets/common_appbar.dart';
import 'package:blyft/models/theme_model.dart';
import 'package:blyft/l10n/app_localizations.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  late AnimationController _particleAnimationController;

  @override
  void initState() {
    super.initState();
    context.read<BookmarkBloc>().add(LoadBookmarksEvent());

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

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<ThemeCubit>().currentTheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: theme.colorScheme.surface.withAlpha((0.85 * 255).toInt()),
            expandedHeight: 70,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: ParticlesHeader(
                title: AppLocalizations.of(context)!.bookmarks,
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
          SliverPadding(
            padding: const EdgeInsets.only(top: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: BlocBuilder<BookmarkBloc, BookmarkState>(
                      builder: (context, state) {
                        if (state is BookmarksLoaded) {
                          return state.bookmarks.isEmpty
                              ? _buildEmptyState(currentTheme)
                              : _buildBookmarksList(state.bookmarks);
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            color: currentTheme.primaryColor,
                            strokeWidth: 3,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppTheme currentTheme) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
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
                Icons.bookmark_border_rounded,
                size: 70,
                color: currentTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.noBookmarksYet,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.articlesSavedWillAppearHere,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
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
                  const Icon(Icons.explore_outlined),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.discoverNews,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
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

  Widget _buildBookmarksList(List<Article> bookmarks) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final article = bookmarks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 22, right: 22),
          child: ArticleListItem(
            showRemove: true,
            article: article,
            onSide: () => context.read<BookmarkBloc>().add(
              ToggleBookmarkEvent(article),
            ),
            onTap: () => _launchUrl(article.url),
          ),
        );
      },
    );
  }
}

