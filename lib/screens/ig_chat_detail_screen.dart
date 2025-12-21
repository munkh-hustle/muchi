// lib/screens/ig_chat_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muchi/models/chat_message.dart';

class IgChatDetailScreen extends StatelessWidget {
  final List<ChatMessage> messages;
  final String title;

  const IgChatDetailScreen({
    super.key,
    required this.messages,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return _buildMessage(message);
        },
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isCurrentUser = message.senderName.contains('Chimdee');
    final hasPhotos = message.photos.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: Text(
                message.senderName.substring(0, 1),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (hasPhotos) _buildPhotoPreview(message.photos),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? const Color(0xFFFF6B6B)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    _getMessageContent(message),
                    style: TextStyle(
                      fontSize: 16,
                      color: isCurrentUser ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8),
          if (isCurrentUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFFFB6C1),
              child: Text(
                message.senderName.substring(0, 1),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(List<String> photoPaths) {
    if (photoPaths.isEmpty) return const SizedBox.shrink();

    // Extract filename from path
    final filename = photoPaths.first.split('/').last;
    final assetPath =
        'assets/your_instagram_activity/messages/inbox/chimdee_17995024886728646/photos/$filename';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // Try to load the image, fallback to placeholder
          FutureBuilder(
            future: _loadImage(assetPath),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    width: 150,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPhotoPlaceholder();
                    },
                  ),
                );
              } else {
                return _buildPhotoPlaceholder();
              }
            },
          ),

          // Multiple photos indicator
          if (photoPaths.length > 1)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${photoPaths.length - 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Photo',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _loadImage(String assetPath) async {
    try {
      // Check if the asset exists in the bundle
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      print('Asset not found: $assetPath');
      return false;
    }
  }

  String _getMessageContent(ChatMessage message) {
    final content = message.content;

    // Check for photos
    if (content.isEmpty && message.photos.isNotEmpty) {
      return '📷 Photo';
    }

    // Handle different message types
    if (content.contains('You sent an attachment')) {
      return '📎 Instagram Post';
    } else if (content.contains('Liked a message')) {
      return '❤️ Liked a message';
    } else if (content.contains('Reacted')) {
      return '😊 Reacted to a message';
    } else if (content.trim().isEmpty && message.photos.isEmpty) {
      return '📎 Media';
    }

    return content;
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
