import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blyft/l10n/app_localizations.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? response;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.response,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isUser ? 60 : 12,
        right: isUser ? 12 : 60,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () => _copyToClipboard(context, message),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? const Color.fromRGBO(68, 138, 255, 1)
                        : const Color.fromARGB(255, 45, 45, 45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.messageCopiedToClipboard),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromRGBO(68, 138, 255, 1),
      ),
    );
  }
}

