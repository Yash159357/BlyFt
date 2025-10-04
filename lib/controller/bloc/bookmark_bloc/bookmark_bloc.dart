import 'dart:async';
import 'package:blyft/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blyft/controller/services/bookmark_services.dart';
import 'bookmark_event.dart';
import 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final BookmarkServices repository;

  BookmarkBloc(this.repository) : super(BookmarkInitial()) {
    on<ToggleBookmarkEvent>(_onToggleBookmark);
    on<LoadBookmarksEvent>(_onLoadBookmarks);
  }

  Future<void> _onToggleBookmark(
    ToggleBookmarkEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    _log("on<ToggleBookmarkEvent started with: ${event.article}");
    try {
      await repository.toggleBookmark(event.article);
      add(LoadBookmarksEvent());
    } catch (e, stackTrace) {
      _log("Error in ToggleBookmarkEvent:$e");
      addError(e, stackTrace);
      emit(BookmarkError('Failed to toggle bookmark: $e'));
    }
  }

  Future<void> _onLoadBookmarks(
    LoadBookmarksEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    _log("on<LoadBookmarksEvent> started");
    try {
      final bookmarks = await repository.getBookmarks();
      emit(BookmarksLoaded(bookmarks));
    } catch (e, stackTrace) {
      _log("Error in LoadBookmarksEvent: $e");
      addError(e, stackTrace);
      emit(BookmarkError('Failed to load bookmarks: $e'));
    }
  }

  @override
  void onTransition(Transition<BookmarkEvent, BookmarkState> transition) {
    super.onTransition(transition);
    _log("Transition: ${transition.event}-> ${transition.nextState}");
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    _log("onError: $error\n$stackTrace");
  }

  void _log(String message) {
    // Centralized logging format
    Log.d("BOOKMARK_BLOC:$message");
  }
}

