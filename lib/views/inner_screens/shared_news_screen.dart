import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blyft/controller/services/backend_service.dart' as backend;
import 'package:blyft/models/article_model.dart';
import 'package:blyft/utils/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:blyft/controller/cubit/theme/theme_cubit.dart';
import 'package:blyft/l10n/app_localizations.dart';

class SharedNewsScreen extends StatefulWidget {
  final String newsId;

  const SharedNewsScreen({super.key, required this.newsId});

  @override
  State<SharedNewsScreen> createState() => _SharedNewsScreenState();
}

class _SharedNewsScreenState extends State<SharedNewsScreen> {
  Article? _article;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await backend.ApiService().getNewsById(widget.newsId);

      if (response.success && response.data != null) {
        Map<String, dynamic> articleJson;
        try {
          if (response.data is Map &&
              (response.data as Map).containsKey('data')) {
            articleJson = Map<String, dynamic>.from(response.data['data']);
          } else {
            articleJson = Map<String, dynamic>.from(response.data as Map);
          }
        } catch (e) {
          Log.e('SharedNewsScreen: Unexpected response data shape', e);
          setState(() {
            _error = AppLocalizations.of(context)!.invalidDataReceived;
            _isLoading = false;
          });
          return;
        }

        Log.d('SharedNewsScreen: Article JSON: $articleJson');

        setState(() {
          _article = Article.fromJson(articleJson);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = AppLocalizations.of(context)!.failedToLoadNewsArticle;
          _isLoading = false;
        });
      }
    } catch (e) {
      Log.e('Error loading shared news', e);
      setState(() {
        _error = AppLocalizations.of(context)!.errorLoadingArticle;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.sharedNews),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('sidepage'),
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const Gap(16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            ElevatedButton(
              onPressed: _loadNews,
              child: Text(AppLocalizations.of(context)!.tryAgain),
            ),
          ],
        ),
      );
    }

    if (_article == null) {
      return Center(child: Text(AppLocalizations.of(context)!.newsArticleNotFound));
    }

    return _buildNewsDetail();
  }

  Widget _buildNewsDetail() {
    final currentTheme = context.read<ThemeCubit>().currentTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article image
          if (_article!.urlToImage.isNotEmpty)
            CachedNetworkImage(
              imageUrl: _article!.urlToImage,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 64),
                  ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source and date
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: currentTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _article!.sourceName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        DateFormat(
                          'MMM dd, y • h:mm a',
                        ).format(_article!.publishedAt),
                        style: TextStyle(
                          color: Colors.white.withAlpha(229),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const Gap(16),

                // Title
                Text(
                  _article!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const Gap(16),

                // Description
                Text(
                  _article!.description,
                  style: TextStyle(
                    color: Colors.white.withAlpha(229),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),

                const Gap(16),

                // Content
                if (_article!.content.isNotEmpty)
                  Text(
                    _article!.content.split('[')[0].trim(),
                    style: TextStyle(
                      color: Colors.white.withAlpha(229),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                const Gap(24),

                // Author
                if (_article!.author.isNotEmpty)
                  Text(
                    '${AppLocalizations.of(context)!.byAuthor} ${_article!.author}',
                    style: TextStyle(
                      color: Colors.white.withAlpha((0.6 * 255).toInt()),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                const Gap(32),

                // Read full article button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_article!.url.isNotEmpty) {
                        final uri = Uri.parse(_article!.url);
                        try {
                          if (!await launchUrl(uri)) {
                            throw 'Could not launch ${_article!.url}';
                          }
                        } catch (e) {
                          Log.e('Error launching URL', e);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.couldNotOpenArticle),
                              ),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: Text(AppLocalizations.of(context)!.readFullArticle),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: currentTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

