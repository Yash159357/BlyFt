import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blyft/utils/logger.dart';
import 'package:equatable/equatable.dart';
import 'package:blyft/models/article_model.dart';
import 'package:blyft/models/news_category.dart';
import 'package:blyft/controller/services/news_services.dart';

part 'news_scroll_event.dart';
part 'news_scroll_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsService newsService;
  int _page = 1;
  // --- CHANGE THIS VALUE ---
  final int _pageSize = 10; // Change from 10 to 8
  // -------------------------
  NewsCategory _currentCategory = NewsCategory.general;

  NewsBloc({required this.newsService}) : super(NewsInitial()) {
    on<FetchInitialNews>(_onFetchInitialNews);
    on<FetchNextPage>(_onFetchNextPage);
    on<UpdateNewsIndex>(_onUpdateNewsIndex);
  }

  @override
  void onEvent(NewsEvent event) {
    super.onEvent(event);
    Log.d('<NEWS_SCROLL_BLOC> Event received: ${event.runtimeType}');
  }

  Future<void> _onFetchInitialNews(
      FetchInitialNews event,
      Emitter<NewsState> emit,
      ) async {
    try {
  Log.d('<NEWS_SCROLL_BLOC> FetchInitialNews requested for category: ${event.category}');
  _currentCategory = event.category;
  _page = 1;

  Log.d('<NEWS_SCROLL_BLOC> Starting API call to fetch initial news (page=$_page, category=$_currentCategory)');
  emit(NewsLoading());
  final articles = await _fetchCategoryNews();
  Log.d('<NEWS_SCROLL_BLOC> Finished API call to fetch initial news: received ${articles.length} articles');
      emit(
        NewsLoaded(
          articles: articles,
          hasReachedMax: articles.length < _pageSize,
          category: _currentCategory,
          currentIndex: 0,
        ),
      );
    } catch (e) {
  Log.e('<NEWS_SCROLL_BLOC> Error fetching initial news: $e');
  emit(NewsError('Failed to load news: $e'));
    }
  }

  Future<void> _onFetchNextPage(
      FetchNextPage event,
      Emitter<NewsState> emit,
      ) async {
    if (state is! NewsLoaded) return;
    final currentState = state as NewsLoaded;

    if (currentState.hasReachedMax || currentState.isLoadingMore || _currentCategory != event.category) {
      return;
    }

    // mark loading more
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      _page++;

      Log.d('<NEWS_SCROLL_BLOC> Starting API call to fetch next page: page=$_page, category=$_currentCategory');

      final newArticles = await _fetchCategoryNews(page: _page);

      Log.d('<NEWS_SCROLL_BLOC> Finished API call for page $_page: received ${newArticles.length} articles');

      emit(NewsLoaded(
        articles: List.of(currentState.articles)..addAll(newArticles),
        hasReachedMax: newArticles.length < _pageSize,
        isLoadingMore: false,
        category: currentState.category,
        currentIndex: currentState.currentIndex,
      ));

    } catch (e) {
      Log.e('<NEWS_SCROLL_BLOC> Error fetching page $_page: $e');
      _page--;
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  void _onUpdateNewsIndex(
      UpdateNewsIndex event,
      Emitter<NewsState> emit,
      ) {
    if (state is NewsLoaded) {
      final currentState = state as NewsLoaded;
      emit(currentState.copyWith(currentIndex: event.newIndex));
    }
  }

  Future<List<Article>> _fetchCategoryNews({int? page}) async {
    switch (_currentCategory) {
      case NewsCategory.technology:
        return newsService.fetchTechnologyNews(page: page ?? _page);
      case NewsCategory.sports:
        return newsService.fetchSportsNews(page: page ?? _page);
      case NewsCategory.entertainment:
        return newsService.fetchEntertainmentNews(page: page ?? _page);
      case NewsCategory.business:
        return newsService.fetchBusinessNews(page: page ?? _page);
      case NewsCategory.health:
        return newsService.fetchHealthNews(page: page ?? _page);
      case NewsCategory.politics:
        return newsService.fetchPoliticsNews(page: page ?? _page);
      default:
        return newsService.fetchGeneralNews(page: page ?? _page);
    }
  }
}

