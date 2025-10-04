import 'package:blyft/l10n/app_localizations.dart';
import 'package:blyft/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blyft/models/conversation_model.dart';
import 'package:blyft/models/chat_window_model.dart';
import 'package:blyft/models/article_model.dart';
import 'package:blyft/controller/services/gemini_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GeminiFlashService _geminiService;

  ChatBloc({required GeminiFlashService geminiService})
    : _geminiService = geminiService,
      super(ChatInitial()) {
    on<InitializeChat>(_onInitializeChat);
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);
  }

  @override
  void onEvent(ChatEvent event) {
    super.onEvent(event);
    Log.d('<CHAT_BLOC> Event received: ${event.runtimeType}');
  }

  @override
  void onChange(Change<ChatState> change) {
    super.onChange(change);
    Log.d(
      '<CHAT_BLOC> State change: {previous: ${change.currentState.runtimeType}, next: ${change.nextState.runtimeType}}',
    );
  }

  void _onInitializeChat(InitializeChat event, Emitter<ChatState> emit) {
    Log.d(
      '<CHAT_BLOC> Handling InitializeChat for article: ${event.article.title}',
    );
    emit(
      ChatLoaded(
        chatWindow: ChatWindow(
          article: event.article,
          conversations: [],
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    Log.d('<CHAT_BLOC> Handling SendMessage: "${event.message}"');

    if (state is! ChatLoaded) {
      Log.d(
        '<CHAT_BLOC> Cannot send message: Chat is not in ChatLoaded state. Current state: ${state.runtimeType}',
      );
      return;
    }

    final currentState = state as ChatLoaded;

    // Show message sending state
    Log.d('<CHAT_BLOC> Emitting MessageSending');
    emit(MessageSending(chatWindow: currentState.chatWindow));

    try {
      // Build full context with conversation history
      final prompt = _buildContextualPrompt(event.chatWindow, event.message, event.context);

      // Get response from Gemini
      final response = await _geminiService.getFreeResponse(prompt);
      Log.d(
        '<CHAT_BLOC> Received response from Gemini (length=${response.length})',
      );

      // Create new conversation
      final newConversation = Conversation(
        request: event.message,
        response: response,
        timestamp: DateTime.now(),
      );

      Log.d(
        '<CHAT_BLOC> New Conversation created: requestPreview="${event.message.length > 120 ? '${event.message.substring(0, 120)}...' : event.message}"',
      );

      // Add conversation to chat window
      final updatedConversations = [
        ...currentState.chatWindow.conversations,
        newConversation,
      ];

      // Emit with typewriter animation flag
      Log.d(
        '<CHAT_BLOC> Emitting ChatLoaded with updated conversations=${updatedConversations.length}',
      );
      emit(
        ChatLoaded(
          chatWindow: currentState.chatWindow.copyWith(
            conversations: updatedConversations,
          ),
          shouldAnimateLatest: true, // Flag to animate the latest message
        ),
      );
    } catch (e) {
      Log.e('<CHAT_BLOC> Error while sending message: ${e.toString()}');
      emit(ChatError(message: '${AppLocalizations.of(event.context)!.failedToGetResponse}: ${e.toString()}'));

      // Return to previous state after error
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed) {
          emit(
            ChatLoaded(
              chatWindow: currentState.chatWindow,
              shouldAnimateLatest: false,
            ),
          );
        }
      });
    }
  }

  // Emit ChatLoaded with empty conversations instead of ChatInitial
  void _onClearChat(ClearChat event, Emitter<ChatState> emit) {
    Log.d('<CHAT_BLOC> Handling ClearChat');
    // Get the current article context from the existing state
    Article currentArticle;
    if (state is ChatLoaded) {
      currentArticle = (state as ChatLoaded).chatWindow.article;
    } else if (state is MessageSending) {
      currentArticle = (state as MessageSending).chatWindow.article;
    } else {
      // This case should ideally not be hit if the app flow is correct,
      // as ChatBloc is initialized with an article.
      // create a ChatLoaded state properly. Revert to ChatInitial as a fallback.
      emit(ChatInitial());
      return;
    }

    // Emit ChatLoaded with an empty list of conversations,
    // making the chat ready to receive new messages.
    emit(
      ChatLoaded(
        chatWindow: ChatWindow(
          article: currentArticle,
          conversations: [],
          createdAt: DateTime.now(),
        ),
        shouldAnimateLatest: false,
      ),
    );
  }

  String _buildContextualPrompt(ChatWindow chatWindow, String userQuery, BuildContext context) {
    final article = chatWindow.article;
    final history = chatWindow.conversations;

    String prompt =
        """You are an intelligent news companion that engages readers in meaningful discussions about articles. 

ARTICLE CONTEXT:
Title: ${article.title}
Author: ${article.author} | Source: ${article.sourceName}
Summary: ${article.description}
Content: ${article.content}
Locale: ${AppLocalizations.of(context)!.localeName}

GUIDELINES:
• Answer questions accurately based solely on the article content, in the specified locale
• Match the conversational tone and style from our chat history
• Politely redirect off-topic questions back to the article
• Keep responses engaging by ending with thoughtful follow-up questions
• Maintain a natural, human-like conversational flow""";

    if (history.isNotEmpty) {
      prompt += "\n\nCONVERSATION HISTORY:\n";
      for (var conv in history) {
        prompt += "You: ${conv.response}\nReader: ${conv.request}\n";
      }
    }

    prompt += "\n\nReader's Question: $userQuery\n\nYour Response:";

    return prompt;
  }
}
