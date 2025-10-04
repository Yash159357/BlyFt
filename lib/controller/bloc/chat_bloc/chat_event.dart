part of 'chat_bloc.dart';

abstract class ChatEvent {}

class InitializeChat extends ChatEvent {
  final Article article;
  InitializeChat({required this.article}) {
    // Log creation of this event
    Log.d('<CHAT_EVENT> InitializeChat created for article: ${article.title}');
  }
}

class SendMessage extends ChatEvent {
  final String message;
  final ChatWindow chatWindow;
  final BuildContext context;
  SendMessage({required this.message, required this.chatWindow, required this.context}) {
    // Log creation of send message event (do not log full chatWindow to avoid noisy output)
    final preview = message.length > 120 ? '${message.substring(0, 120)}...' : message;
    Log.d('<CHAT_EVENT> SendMessage created: messagePreview="$preview"');
  }
}

class ClearChat extends ChatEvent {}


