// lib/models/chat_message.dart
class ChatMessage {
  final String senderName;
  final DateTime timestamp;
  final String content;
  final bool isGeoblocked;
  final bool isUnsent;
  final List<String> photos; // Add this

  ChatMessage({
    required this.senderName,
    required this.timestamp,
    required this.content,
    required this.isGeoblocked,
    required this.isUnsent,
    this.photos = const [], // Add this
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderName: _safeString(json['sender_name']?.toString() ?? 'Unknown'),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp_ms']),
      content: _safeString(json['content']?.toString() ?? ''),
      isGeoblocked: json['is_geoblocked_for_viewer'] ?? false,
      isUnsent: json['is_unsent_image_by_messenger_kid_parent'] ?? false,
      photos: _parsePhotos(json['photos']), // This handles null
    );
  }

  static List<String> _parsePhotos(dynamic photosData) {
    if (photosData == null) return []; // Add null check
    if (photosData is List) {
      return photosData
          .map((p) => p['uri']?.toString() ?? '')
          .where((uri) => uri.isNotEmpty)
          .toList();
    }
    return [];
  }

  static String _safeString(String input) {
    try {
      return input;
    } catch (e) {
      return String.fromCharCodes(
        input.runes.where((rune) => rune < 0xD800 || rune > 0xDFFF),
      );
    }
  }
}
