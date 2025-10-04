part of 'news_scroll_bloc.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {
  NewsLoading() {
    Log.d('<NEWS_SCROLL_STATE> NewsLoading created');
  }
}

class NewsLoaded extends NewsState {
  final List<Article> articles;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final NewsCategory category;
  final int currentIndex;

  NewsLoaded({
    required this.articles,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    required this.category,
    this.currentIndex = 0,
  }) {
    Log.d('<NEWS_SCROLL_STATE> NewsLoaded created: articles=${articles.length}, hasReachedMax=$hasReachedMax, isLoadingMore=$isLoadingMore, category=$category, currentIndex=$currentIndex');
  }

  NewsLoaded copyWith({
    List<Article>? articles,
    bool? hasReachedMax,
    bool? isLoadingMore,
    NewsCategory? category,
    int? currentIndex,
  }) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      category: category ?? this.category,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object> get props => [
    articles,
    hasReachedMax,
    isLoadingMore,
    category,
    currentIndex,
  ];
}

class NewsError extends NewsState {
  final String message;
  NewsError(this.message) {
    Log.e('<NEWS_SCROLL_STATE> NewsError created: $message');
  }

  @override
  List<Object> get props => [message];
}

