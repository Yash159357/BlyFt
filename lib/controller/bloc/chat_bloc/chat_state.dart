part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {
  ChatInitial() {
    Log.d('<CHAT_STATE> ChatInitial created');
  }
}

class ChatLoading extends ChatState {
  ChatLoading() {
    Log.d('<CHAT_STATE> ChatLoading created');
  }
}

class ChatLoaded extends ChatState {
  final ChatWindow chatWindow;
  final bool shouldAnimateLatest;
  
  ChatLoaded({
    required this.chatWindow,
    this.shouldAnimateLatest = false,
  }) {
    Log.d('<CHAT_STATE> ChatLoaded created: conversations=${chatWindow.conversations.length}, shouldAnimateLatest=$shouldAnimateLatest');
  }
}

class ChatError extends ChatState {
  final String message;
  ChatError({required this.message}) {
    Log.e('<CHAT_STATE> ChatError created: $message');
  }
}

class MessageSending extends ChatState {
  final ChatWindow chatWindow;
  MessageSending({required this.chatWindow}) {
    Log.d('<CHAT_STATE> MessageSending created');
  }
}

