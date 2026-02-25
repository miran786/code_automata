class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? insights;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.insights,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['response'] ?? json['message'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(
        json['generated_at'] ??
            json['timestamp'] ??
            DateTime.now().toIso8601String(),
      ),
      insights: json['health_insights'] != null
          ? List<String>.from(json['health_insights'])
          : null,
    );
  }
}
