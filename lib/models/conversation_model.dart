class Conversation {
  final String request;
  final String response;
  final DateTime timestamp;

  Conversation({
    required this.request,
    required this.response,
    required this.timestamp,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        request: json['request'],
        response: json['response'],
        timestamp: DateTime.parse(json['timestamp']),
      );

  Map<String, dynamic> toJson() => {
        'request': request,
        'response': response,
        'timestamp': timestamp.toIso8601String(),
      };
}

