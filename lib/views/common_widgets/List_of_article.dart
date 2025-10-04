import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:blyft/controller/bloc/bookmark_bloc/bookmark_bloc.dart';
import 'package:blyft/controller/bloc/bookmark_bloc/bookmark_state.dart';
import 'package:blyft/controller/cubit/theme/theme_cubit.dart';
import 'package:blyft/models/article_model.dart';


class ArticleListItem extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onSide;
  final bool showBookmark;
  final bool showRemove;

  const ArticleListItem({
    super.key,
    required this.article,
    required this.onSide,
    required this.onTap,
    this.showRemove = false,
    this.showBookmark = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.read<ThemeCubit>().currentTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              currentTheme.primaryColor.withAlpha(70),
              currentTheme.primaryColor.withAlpha(10),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: article.urlToImage,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: const Color(0xFF2A303A),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: currentTheme.primaryColor,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: const Color(0xFF2A303A),
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withAlpha(110),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: currentTheme.primaryColor.withAlpha(40),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              article.sourceName.toUpperCase(),
                              style: TextStyle(
                                color: currentTheme.primaryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('MMM d').format(article.publishedAt),
                            style: TextStyle(
                              color: Colors.white.withAlpha(150),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Expanded(
                        child: Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                      // Action row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Read button
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: const Size(0, 24),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: onTap,
                            child: const Text('Read Article'),
                          ),
                          // Bookmark button
                          if (showBookmark)
                            BlocBuilder<BookmarkBloc, BookmarkState>(
                              builder: (context, state) {
                                final isBookmarked =
                                    state is BookmarksLoaded &&
                                    state.bookmarks.any(
                                      (a) => a.url == article.url,
                                    );

                                return SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: IconButton(
                                    icon: Icon(
                                      isBookmarked
                                          ? Icons.bookmark
                                          : Icons.bookmark_add_outlined,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    style: IconButton.styleFrom(
                                      backgroundColor: currentTheme.primaryColor
                                          .withAlpha(isBookmarked ? 40 : 10),
                                      foregroundColor:
                                          isBookmarked
                                              ? currentTheme.primaryColor
                                              : Colors.white70,
                                    ),
                                    onPressed: onSide,
                                    tooltip: 'Bookmark',
                                  ),
                                );
                              },
                            ),
                          if (showRemove)
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                padding: EdgeInsets.zero,
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFF353A47),
                                  foregroundColor: const Color(0xFFFF5252),
                                ),
                                onPressed: onSide,
                                tooltip: 'Remove',
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

