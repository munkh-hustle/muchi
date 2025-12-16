// lib/models/chat_message.dart
class ChatMessage {
  final String senderName;
  final DateTime timestamp;
  final String content;
  final bool isGeoblocked;
  final bool isUnsent;

  ChatMessage({
    required this.senderName,
    required this.timestamp,
    required this.content,
    required this.isGeoblocked,
    required this.isUnsent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderName: json['sender_name'] ?? 'Unknown',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp_ms']),
      content: json['content'] ?? '',
      isGeoblocked: json['is_geoblocked_for_viewer'] ?? false,
      isUnsent: json['is_unsent_image_by_messenger_kid_parent'] ?? false,
    );
  }
}