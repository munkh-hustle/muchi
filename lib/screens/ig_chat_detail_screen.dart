// lib/screens/ig_chat_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muchi/models/chat_message.dart';
import 'package:url_launcher/url_launcher.dart';

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
          return _buildMessage(context, message);
        },
      ),
    );
  }

  Widget _buildMessage(BuildContext context, ChatMessage message) {
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
                if (hasPhotos) _buildPhotoPreview(context, message.photos),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? const Color(0xFFFF6B6B)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _buildMessageContent(context, message),
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

  Widget _buildPhotoPreview(BuildContext context, List<String> photoPaths) {
    if (photoPaths.isEmpty) return const SizedBox.shrink();

    // Extract filename from path
    final filename = photoPaths.first.split('/').last;
    final assetPath =
        'assets/your_instagram_activity/messages/inbox/chimdee_17995024886728646/photos/$filename';

    return GestureDetector(
      onTap: () {
        _showFullScreenImage(context, assetPath, photoPaths);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

            // Tap indicator
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.zoom_in,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(
      BuildContext context, String assetPath, List<String> photoPaths) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black.withOpacity(0.9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // Image
                Expanded(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 3,
                    child: Center(
                      child: FutureBuilder(
                        future: _loadImage(assetPath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data == true) {
                            return Image.asset(
                              assetPath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildFullScreenPlaceholder();
                              },
                            );
                          } else {
                            return _buildFullScreenPlaceholder();
                          }
                        },
                      ),
                    ),
                  ),
                ),

                // Photo count and navigation (if multiple photos)
                if (photoPaths.length > 1)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '1 of ${photoPaths.length} photos',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.photo,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            'Photo not found',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The photo might not be included in the app assets',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, ChatMessage message) {
    final content = message.content;
    final hasPhotos = message.photos.isNotEmpty;

    // Check for Instagram Reel/Post links
    final reelLinks = _extractReelLinks(content);
    final instagramLinks = _extractInstagramLinks(content);

    if (reelLinks.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final link in reelLinks)
            GestureDetector(
              onTap: () => _openUrl(context, link),
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFF6B6B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_circle_filled,
                      color: Color(0xFFFF6B6B),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '🎬 Instagram Reel',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new,
                      color: Color(0xFFFF6B6B),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          if (content.replaceAll(reelLinks.join(''), '').trim().isNotEmpty)
            Text(
              content.replaceAll(reelLinks.join(''), '').trim(),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
        ],
      );
    } else if (instagramLinks.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final link in instagramLinks)
            GestureDetector(
              onTap: () => _openUrl(context, link),
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB6C1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFB6C1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.image,
                      color: Color(0xFFFF6B6B),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '📱 Instagram Post',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new,
                      color: Color(0xFFFF6B6B),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          if (content.replaceAll(instagramLinks.join(''), '').trim().isNotEmpty)
            Text(
              content.replaceAll(instagramLinks.join(''), '').trim(),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
        ],
      );
    } else if (content.contains('You sent an attachment')) {
      return GestureDetector(
        onTap: () {
          // Try to find if there's a link in the message
          final url = _extractUrl(content);
          if (url.isNotEmpty) {
            _openUrl(context, url);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.link,
              color: Colors.blue,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Tap to open attachment',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade700,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else if (content.contains('Liked a message')) {
      return Row(
        children: [
          const Icon(
            Icons.favorite,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '❤️ Liked a message',
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    } else if (content.contains('Reacted')) {
      return Row(
        children: [
          const Icon(
            Icons.emoji_emotions,
            color: Colors.amber,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '😊 Reacted to a message',
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    } else if (content.trim().isEmpty && hasPhotos) {
      return Row(
        children: [
          const Icon(
            Icons.photo,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '📷 Photo',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      );
    } else if (content.trim().isEmpty && !hasPhotos) {
      return Row(
        children: [
          const Icon(
            Icons.attachment,
            color: Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '📎 Media',
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    return Text(
      content,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }

  List<String> _extractReelLinks(String text) {
    final reelRegex = RegExp(r'https?://(?:www\.)?instagram\.com/reel/[^\s]+');
    return reelRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  List<String> _extractInstagramLinks(String text) {
    final postRegex = RegExp(r'https?://(?:www\.)?instagram\.com/p/[^\s]+');
    return postRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  String _extractUrl(String text) {
    final urlRegex = RegExp(r'https?://[^\s]+');
    final matches = urlRegex.allMatches(text);
    return matches.isNotEmpty ? matches.first.group(0)! : '';
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    // Check if URL has protocol
    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }

    // Show confirmation dialog
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Link'),
        content: Text('Open this link in browser?\n\n$finalUrl'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text('Open'),
          ),
        ],
      ),
    );

    if (shouldOpen == true) {
      try {
        final uri = Uri.parse(finalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot open this link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            'Tap to view',
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
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      print('Asset not found: $assetPath');
      return false;
    }
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
