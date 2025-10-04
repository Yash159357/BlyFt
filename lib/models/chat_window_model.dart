import 'package:blyft/models/conversation_model.dart';
import 'package:blyft/models/article_model.dart';

class ChatWindow {
  final Article article;
  final List<Conversation> conversations;
  final DateTime createdAt;

  ChatWindow({
    required this.article,
    required this.conversations,
    required this.createdAt,
  });

  ChatWindow copyWith({
    Article? article,
    List<Conversation>? conversations,
  }) {
    return ChatWindow(
      article: article ?? this.article,
      conversations: conversations ?? this.conversations,
      createdAt: createdAt,
    );
  }
}

