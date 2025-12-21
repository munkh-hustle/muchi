// lib/models/chat_message.dart
import 'dart:convert';

class ChatMessage {
  final String senderName;
  final DateTime timestamp;
  final String content;
  final bool isGeoblocked;
  final bool isUnsent;
  final List<String> photos;

  ChatMessage({
    required this.senderName,
    required this.timestamp,
    required this.content,
    required this.isGeoblocked,
    required this.isUnsent,
    this.photos = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderName: _safeString(json['sender_name']?.toString() ?? 'Unknown'),
      timestamp: _parseTimestamp(json['timestamp_ms']),
      content: _safeString(json['content']?.toString() ?? ''),
      isGeoblocked: json['is_geoblocked_for_viewer'] ?? false,
      isUnsent: json['is_unsent_image_by_messenger_kid_parent'] ?? false,
      photos: _parsePhotos(json['photos']),
    );
  }

  static DateTime _parseTimestamp(dynamic timestampMs) {
    try {
      if (timestampMs is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestampMs);
      } else if (timestampMs is String) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(timestampMs));
      } else {
        return DateTime.now();
      }
    } catch (e) {
      return DateTime.now();
    }
  }

  static List<String> _parsePhotos(dynamic photosData) {
    if (photosData == null) return [];
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
      // First try to decode and re-encode to handle encoding issues
      if (input.isEmpty) return input;

      // Handle common encoding issues
      final bytes = utf8.encode(input);
      return utf8.decode(bytes, allowMalformed: true);
    } catch (e) {
      // If everything fails, filter out invalid characters
      final sanitized = String.fromCharCodes(
        input.runes.where(
          (rune) => rune < 0xD800 || rune > 0xDFFF,
        ),
      );
      return sanitized.isNotEmpty ? sanitized : '[Unable to display message]';
    }
  }
}
