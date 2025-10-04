import 'package:equatable/equatable.dart';
import 'package:blyft/models/article_model.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object> get props => [];
}

class BookmarkInitial extends BookmarkState {
  @override
  String toString()=>"BookmarkInitial";
}

class BookmarksLoaded extends BookmarkState {
  final List<Article> bookmarks;
  const BookmarksLoaded(this.bookmarks);

  @override
  List<Object> get props => [bookmarks];

  @override 
  String toString() => 'BookmarksLoaded { count: ${bookmarks.length} }';
}

class BookmarkError extends BookmarkState {
  final String message;
  const BookmarkError(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'BookmarkError { message: $message }';
}

