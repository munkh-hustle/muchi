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
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFF6B6B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFFFF8F7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFFB6C1)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF8F7),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8F7),
              Color(0xFFFFF0F5),
            ],
          ),
        ),
        child: ListView.builder(
          reverse: false,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildMessage(context, message);
          },
        ),
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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB6C1).withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFB6C1),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  message.senderName.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFFB6C1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        isCurrentUser ? const Color(0xFFFFB6C1) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isCurrentUser
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: isCurrentUser
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFFFFB6C1).withValues(
                          alpha: 1,
                        ),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildMessageContent(context, message),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(
                    right: isCurrentUser ? 8 : 0,
                    left: isCurrentUser ? 0 : 8,
                  ),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8),
          if (isCurrentUser)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB6C1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFB6C1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB6C1).withValues(
                      alpha: 1,
                    ),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  message.senderName.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(BuildContext context, List<String> photoPaths) {
    if (photoPaths.isEmpty) return const SizedBox.shrink();

    // For multiple photos, use a PageView
    if (photoPaths.length > 1) {
      return SizedBox(
        height: 150,
        width: 150,
        child: PageView.builder(
          itemCount: photoPaths.length,
          itemBuilder: (context, index) {
            return _buildSinglePhoto(
                context,
                photoPaths[index],
                index,
                photoPaths, // Pass the entire list
                photoPaths.length);
          },
        ),
      );
    } else {
      return _buildSinglePhoto(context, photoPaths.first, 0, photoPaths, 1);
    }
  }

  Widget _buildSinglePhoto(
      BuildContext context,
      String photoPath,
      int index,
      List<String> photoPaths, // Add this parameter
      int total) {
    // Extract filename from path
    final assetPath = 'assets/$photoPath';

    return GestureDetector(
      onTap: () {
        // Now we have access to photoPaths
        _showFullScreenImageCarousel(context, photoPaths, index);
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
            if (total > 1)
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
                    '${index + 1}/$total',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImageCarousel(
      BuildContext context, List<String> photoPaths, int initialIndex) {
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
            child: Stack(
              children: [
                // Close button
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Image carousel
                Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: PageView.builder(
                      controller: PageController(initialPage: initialIndex),
                      itemCount: photoPaths.length,
                      itemBuilder: (context, index) {
                        final assetPath = 'assets/${photoPaths[index]}';
                        return InteractiveViewer(
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
                        );
                      },
                    ),
                  ),
                ),

                // Page indicator
                if (photoPaths.length > 1)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${initialIndex + 1} of ${photoPaths.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
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
    final isCurrentUser = message.senderName.contains('Chimdee');
    final content = message.content;
    final hasPhotos = message.photos.isNotEmpty;
    final hasShare = message.hasShareLink;

    // Get text color based on whether it's current user's message
    final textColor = isCurrentUser ? Colors.white : Colors.black;

    // Handle share/attachment messages
    if ((content.contains('You sent an attachment') ||
            content.contains('Sent an attachment')) &&
        hasShare) {
      final shareLink = message.shareLink;
      final shareText = message.shareText;
      final shareOwner = message.shareOwner;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isInstagramReelShare)
            _buildShareChip(
              context,
              shareLink!,
              '🎬 Instagram Reel',
              Icons.play_circle_filled,
              shareText,
              shareOwner,
              isCurrentUser: isCurrentUser,
            ),
          if (message.isInstagramPostShare)
            _buildShareChip(
              context,
              shareLink!,
              '📱 Instagram Post',
              Icons.image,
              shareText,
              shareOwner,
              isCurrentUser: isCurrentUser,
            ),
          if (!message.isInstagramReelShare &&
              !message.isInstagramPostShare &&
              hasShare)
            _buildShareChip(
              context,
              shareLink!,
              '🔗 Shared Link',
              Icons.link,
              shareText,
              shareOwner,
              isCurrentUser: isCurrentUser,
            ),

          // Show reactions if any
          if (shareText?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                shareText!,
                style: TextStyle(
                  fontSize: 14,
                  color: isCurrentUser ? Colors.white70 : Color(0xFF555555),
                ),
              ),
            ),
        ],
      );
    }

    // Check for Instagram Reel/Post links in content
    final reelLinks = _extractReelLinks(content);
    final instagramLinks = _extractInstagramLinks(content);

    // Handle Instagram links first
    if (reelLinks.isNotEmpty || instagramLinks.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final link in reelLinks)
            _buildLinkChip(
              context,
              link,
              '🎬 Instagram Reel',
              Icons.play_circle_filled,
              isCurrentUser: isCurrentUser,
            ),
          for (final link in instagramLinks)
            _buildLinkChip(
              context,
              link,
              '📱 Instagram Post',
              Icons.image,
              isCurrentUser: isCurrentUser,
            ),
          if (content
              .replaceAll(reelLinks.join(''), '')
              .replaceAll(instagramLinks.join(''), '')
              .trim()
              .isNotEmpty)
            Text(
              content
                  .replaceAll(reelLinks.join(''), '')
                  .replaceAll(instagramLinks.join(''), '')
                  .trim(),
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
        ],
      );
    }

    // Handle liked/reacted messages
    else if (content.contains('Liked a message') ||
        content.contains('Reacted')) {
      return Row(
        children: [
          Icon(
            content.contains('Liked') ? Icons.favorite : Icons.emoji_emotions,
            color: content.contains('Liked')
                ? (isCurrentUser ? Colors.white : Color(0xFFFF6B6B))
                : (isCurrentUser ? Colors.white : Colors.amber),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: textColor,
            ),
          ),
        ],
      );
    }

    // Handle empty content with photos
    else if (content.trim().isEmpty && hasPhotos) {
      return Row(
        children: [
          Icon(
            Icons.photo,
            color: isCurrentUser ? Colors.white70 : Color(0xFFFF6B6B),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '📷 Photo',
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
          ),
        ],
      );
    }

    // Default text display
    return Text(
      content,
      style: TextStyle(
        fontSize: 16,
        color: textColor,
      ),
    );
  }

  Widget _buildShareChip(
    BuildContext context,
    String url,
    String label,
    IconData icon,
    String? description,
    String? owner, {
    required bool isCurrentUser,
  }) {
    return GestureDetector(
      onTap: () => _openUrl(context, url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? Colors.white.withOpacity(0.2)
              : const Color(0xFFFFF8F7),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isCurrentUser
                ? Colors.white.withOpacity(0.5)
                : const Color(0xFFFFB6C1),
            width: 1.5,
          ),
          boxShadow: isCurrentUser
              ? []
              : [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    color:
                        isCurrentUser ? Colors.white : const Color(0xFFFF6B6B),
                    size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      color: isCurrentUser
                          ? Colors.white
                          : const Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  color: isCurrentUser ? Colors.white : const Color(0xFFFF6B6B),
                  size: 16,
                ),
              ],
            ),
            if (description != null && description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 30),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCurrentUser ? Colors.white70 : Color(0xFF555555),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (owner != null && owner.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 30),
                child: Text(
                  'From: $owner',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isCurrentUser ? Colors.white60 : Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkChip(
    BuildContext context,
    String url,
    String label,
    IconData icon, {
    required bool isCurrentUser,
  }) {
    return GestureDetector(
      onTap: () => _openUrl(context, url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? Colors.white.withOpacity(0.2)
              : const Color(0xFFFF6B6B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isCurrentUser
                ? Colors.white.withOpacity(0.5)
                : const Color(0xFFFF6B6B),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isCurrentUser ? Colors.white : const Color(0xFFFF6B6B),
                size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: isCurrentUser ? Colors.white : const Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.open_in_new,
              color: isCurrentUser ? Colors.white : const Color(0xFFFF6B6B),
              size: 16,
            ),
          ],
        ),
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

  Future<void> _openUrl(BuildContext context, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No URL available to open'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }

    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Open this link in browser?'),
            const SizedBox(height: 8),
            Text(
              finalUrl,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
