// lib/models/chat_message.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';

class ChatMessage {
  final String senderName;
  final DateTime timestamp;
  final String content;
  final bool isGeoblocked;
  final bool isUnsent;
  final List<String> photos;
  final Map<String, dynamic>? share;

  ChatMessage({
    required this.senderName,
    required this.timestamp,
    required this.content,
    required this.isGeoblocked,
    required this.isUnsent,
    this.photos = const [],
    this.share,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    try {
      // Get content and sanitize it
      String content = '';
      if (json['content'] != null) {
        final rawContent = json['content'].toString();
        content = _safeString(rawContent);
      }

      // Get sender name
      String senderName = 'Unknown';
      if (json['sender_name'] != null) {
        final rawSender = json['sender_name'].toString();
        senderName = _safeString(rawSender);
      }

      // Parse timestamp
      DateTime timestamp;
      try {
        if (json['timestamp_ms'] != null) {
          if (json['timestamp_ms'] is int) {
            timestamp =
                DateTime.fromMillisecondsSinceEpoch(json['timestamp_ms']);
          } else if (json['timestamp_ms'] is String) {
            timestamp = DateTime.fromMillisecondsSinceEpoch(
                int.parse(json['timestamp_ms']));
          } else {
            timestamp = DateTime.now();
          }
        } else if (json['timestamp'] != null) {
          // Alternative timestamp field
          if (json['timestamp'] is int) {
            timestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp']);
          } else if (json['timestamp'] is String) {
            timestamp = DateTime.parse(json['timestamp']);
          } else {
            timestamp = DateTime.now();
          }
        } else {
          timestamp = DateTime.now();
        }
      } catch (e) {
        timestamp = DateTime.now();
      }

      // Parse photos
      List<String> photos = [];
      try {
        if (json['photos'] != null && json['photos'] is List) {
          photos = (json['photos'] as List)
              .map<String>((p) {
                if (p['uri'] != null) return p['uri'].toString();
                if (p['uri'] == null && p is String) return p;
                return '';
              })
              .where((uri) => uri.isNotEmpty)
              .toList();
        }
      } catch (e) {
        photos = [];
      }

      // Parse share data
      Map<String, dynamic>? shareData;
      try {
        if (json['share'] != null && json['share'] is Map) {
          shareData = Map<String, dynamic>.from(json['share']);
        }
      } catch (e) {
        shareData = null;
      }

      return ChatMessage(
        senderName: senderName,
        timestamp: timestamp,
        content: content,
        isGeoblocked: json['is_geoblocked_for_viewer'] ?? false,
        isUnsent: json['is_unsent_image_by_messenger_kid_parent'] ?? false,
        photos: photos,
        share: shareData, // Add this
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating ChatMessage from JSON: $e');
      }
      return ChatMessage(
        senderName: 'Error',
        timestamp: DateTime.now(),
        content: '[Error loading message]',
        isGeoblocked: false,
        isUnsent: false,
        photos: [],
      );
    }
  }

  static String _safeString(String input) {
    if (input.isEmpty) return input;

    try {
      // Handle UTF-16 encoding issues
      final bytes = utf8.encode(input);

      // Try to decode with error handling
      return utf8.decode(bytes, allowMalformed: true);
    } catch (e) {
      // If UTF-8 fails, try to filter invalid characters
      try {
        // Remove any invalid UTF-16 surrogate pairs
        final buffer = StringBuffer();
        for (int i = 0; i < input.length; i++) {
          final char = input[i];
          final code = input.codeUnitAt(i);

          // Check for valid UTF-16 code point
          if ((code >= 0xD800 && code <= 0xDBFF) ||
              (code >= 0xDC00 && code <= 0xDFFF)) {
            // Skip surrogate pairs or handle them
            continue;
          }

          // Check for other invalid characters
          if (code == 0xFFFD || code == 0xFFFF) {
            continue;
          }

          buffer.write(char);
        }

        final sanitized = buffer.toString();
        return sanitized.isNotEmpty
            ? sanitized
            : '[Message contains invalid characters]';
      } catch (e2) {
        return '[Unable to display message]';
      }
    }
  }

  bool get hasInstagramReel {
    return content.contains('instagram.com/reel/');
  }

  bool get hasInstagramPost {
    return content.contains('instagram.com/p/');
  }

  List<String> get instagramLinks {
    final urlRegex = RegExp(r'https?://[^\s]+');
    return urlRegex.allMatches(content).map((m) => m.group(0)!).toList();
  }

  List<String> get instagramReelLinks {
    final links = instagramLinks
        .where((link) => link.contains('instagram.com/reel/'))
        .toList();

    if (isInstagramReelShare && shareLink != null) {
      links.add(shareLink!);
    }

    return links;
  }

  List<String> get instagramPostLinks {
    final links = instagramLinks
        .where((link) => link.contains('instagram.com/p/'))
        .toList();

    if (isInstagramPostShare && shareLink != null) {
      links.add(shareLink!);
    }

    return links;
  }

  List<String> get allLinks {
    final links = instagramLinks;
    if (hasShareLink && shareLink != null) {
      links.add(shareLink!);
    }
    return links;
  }

  String get displayContent {
    if (content.contains('You sent an attachment') && hasShareLink) {
      if (isInstagramReelShare) {
        return 'Shared an Instagram Reel';
      } else if (isInstagramPostShare) {
        return 'Shared an Instagram Post';
      } else if (hasInstagramShare) {
        return 'Shared an Instagram link';
      }
      return 'Shared a link';
    }

    if (hasInstagramReel || hasInstagramPost) {
      // Remove Instagram links from display text
      String displayText = content;
      for (final link in instagramLinks) {
        displayText = displayText.replaceAll(link, '').trim();
      }
      return displayText.isNotEmpty ? displayText : 'Shared an Instagram link';
    }
    return content;
  }

  bool get hasAttachment {
    return content.contains('You sent an attachment') ||
        content.contains('Sent an attachment') ||
        photos.isNotEmpty ||
        hasShareLink;
  }

  String get attachmentType {
    if (photos.isNotEmpty) return 'photo';
    if (content.contains('.jpg') ||
        content.contains('.png') ||
        content.contains('.jpeg') ||
        content.contains('.gif')) {
      return 'image';
    }
    if (content.contains('.mp4') || content.contains('.mov')) return 'video';
    if (content.contains('.pdf')) return 'document';
    return 'file';
  }

  bool get hasShareLink {
    return share != null && share!['link'] != null;
  }

  String? get shareLink {
    return hasShareLink ? share!['link'].toString() : null;
  }

  String? get shareText {
    return share != null && share!['share_text'] != null
        ? share!['share_text'].toString()
        : null;
  }

  String? get shareOwner {
    return share != null && share!['original_content_owner'] != null
        ? share!['original_content_owner'].toString()
        : null;
  }

  bool get hasInstagramShare {
    return hasShareLink && (shareLink?.contains('instagram.com') ?? false);
  }

  bool get isInstagramReelShare {
    return hasShareLink &&
        (shareLink?.contains('instagram.com/reel/') ?? false);
  }

  bool get isInstagramPostShare {
    return hasShareLink && (shareLink?.contains('instagram.com/p/') ?? false);
  }
}
