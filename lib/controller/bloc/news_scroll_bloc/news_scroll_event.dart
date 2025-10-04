part of 'news_scroll_bloc.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

class FetchInitialNews extends NewsEvent {
  final NewsCategory category;
  FetchInitialNews({this.category = NewsCategory.general}) {
    Log.d('<NEWS_SCROLL_EVENT> FetchInitialNews created for category: $category');
  }

  @override
  List<Object> get props => [category];
}

class FetchNextPage extends NewsEvent {
  final int currentIndex;
  final NewsCategory category;
  FetchNextPage(this.currentIndex, this.category) {
    Log.d('<NEWS_SCROLL_EVENT> FetchNextPage created: pageTriggerIndex=$currentIndex, category=$category');
  }

  @override
  List<Object> get props => [currentIndex, category];
}

class UpdateNewsIndex extends NewsEvent {
  final int newIndex;
  UpdateNewsIndex(this.newIndex) {
    Log.d('<NEWS_SCROLL_EVENT> UpdateNewsIndex created: newIndex=$newIndex');
  }

  @override
  List<Object> get props => [newIndex];
}

