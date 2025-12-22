// lib/screens/ig_chat_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:muchi/providers/chat_provider.dart';
import 'package:muchi/models/chat_message.dart';

class IgChatScreen extends StatefulWidget {
  const IgChatScreen({super.key});

  @override
  State<IgChatScreen> createState() => _IgChatScreenState();
}

class _IgChatScreenState extends State<IgChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _importChat() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: true, // Allow multiple files
      );

      if (result == null || result.files.isEmpty) return;

      final chatProvider = context.read<ChatProvider>();
      final hasExistingData = chatProvider.hasChatData;

      if (hasExistingData && result.files.length > 1) {
        // Ask user if they want to merge or replace
        final choice = await _showImportChoiceDialog(context);
        if (choice == null) return;

        await _processFiles(result.files, chatProvider, choice == 'merge');
      } else if (hasExistingData) {
        // Single file with existing data - ask
        final choice = await _showImportChoiceDialog(context);
        if (choice == null) return;

        await _processFiles(result.files, chatProvider, choice == 'merge');
      } else {
        // No existing data - just import
        await _processFiles(result.files, chatProvider, false);
      }
    } catch (e) {
      print('Import error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processFiles(
      List<PlatformFile> files, ChatProvider chatProvider, bool merge) async {
    int totalImported = 0;

    for (final file in files) {
      try {
        final jsonString = await File(file.path!).readAsString();
        await chatProvider.importChatFromJson(jsonString, merge: merge);
        totalImported++;
      } catch (e) {
        print('Error processing file ${file.name}: $e');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Successfully imported $totalImported/${files.length} files!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<String?> _showImportChoiceDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Chat Data'),
        content: const Text(
          'You already have chat data. What would you like to do?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'replace'),
            child: const Text('Replace'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'merge'),
            child: const Text('Merge'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime timestamp) {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messages = chatProvider.messages;
        final participants = chatProvider.participants;
        final hasData = chatProvider.hasChatData;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'IG Chat 💌',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color(0xFFFFF8F7),
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFFFF6B6B)),
            actions: [
              if (hasData)
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFFF6B6B)),
                  onPressed: () => _showClearDialog(context),
                ),
              IconButton(
                icon: const Icon(Icons.file_upload, color: Color(0xFFFF6B6B)),
                onPressed: _importChat,
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFFF8F7),
          body: !hasData
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Participants header - updated with pink theme
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8F7),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chat between:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                participants.join(' & '),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB6C1).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFFB6C1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${messages.length} messages',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFFF6B6B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
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
                        child: _buildChatList(messages),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB6C1).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFB6C1),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 50,
                color: Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No chat data 💌',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Import your IG chat JSON file to view sweet messages',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _importChat,
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: const Text('Import Chat JSON'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Note: Use "Download Your Information" on Instagram to get chat data',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(List<ChatMessage> messages) {
    return Container(
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
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final isCurrentUser = message.senderName.contains('Chimdee');
          final showDateHeader = index == 0 ||
              _formatDate(message.timestamp) !=
                  _formatDate(messages[index - 1].timestamp);

          return Column(
            children: [
              if (showDateHeader)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB6C1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDate(message.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isCurrentUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
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
                              color: Color(0xFFFF6B6B),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? const Color(0xFFFF6B6B)
                                  : Colors.white,
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
                                  color: Colors.pink.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              message.content,
                              style: TextStyle(
                                fontSize: 16,
                                color: isCurrentUser
                                    ? Colors.white
                                    : const Color(0xFF333333),
                              ),
                            ),
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
                          color: const Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFF8E8E),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B6B).withOpacity(0.3),
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
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F7),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Color(0xFFFF6B6B),
                      size: 40,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Clear Chat Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Are you sure you want to clear all chat data?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final chatProvider = context.read<ChatProvider>();
                          chatProvider.clearChatData();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chat data cleared'),
                              backgroundColor: Color(0xFFFF6B6B),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text('Clear'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
