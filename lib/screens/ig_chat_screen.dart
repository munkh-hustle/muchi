// lib/screens/ig_chat_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:muchi/services/chat_merge_service.dart';
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

  // In _importChat method, add option to merge multiple files
  Future<void> _importChat() async {
    try {
      // Show options dialog
      final option = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Chat'),
          content: const Text('How do you want to import chat data?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 1),
              child: const Text('Single JSON file'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 2),
              child: const Text('Merge multiple JSON files'),
            ),
          ],
        ),
      );

      if (option == 1) {
        // Original single file import
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
          allowMultiple: false,
        );

        if (result == null || result.files.isEmpty) return;

        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final chatProvider = context.read<ChatProvider>();
        await chatProvider.importChatFromJson(jsonString);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (option == 2) {
        // Merge multiple files
        final mergedJson = await ChatMergeService.importAndMergeMultipleFiles();
        final chatProvider = context.read<ChatProvider>();
        await chatProvider.importChatFromJson(mergedJson);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Multiple chat files merged and imported!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Import error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            title: const Text('IG Chat'),
            actions: [
              if (hasData)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showClearDialog(context),
                  color: Colors.red,
                ),
              IconButton(
                icon: const Icon(Icons.file_upload),
                onPressed: _importChat,
              ),
            ],
          ),
          body: !hasData
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Participants header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                                ),
                              ),
                            ],
                          ),
                          Chip(
                            label: Text('${messages.length} messages'),
                            backgroundColor: const Color(0xFFFFB6C1),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildChatList(messages),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          const Text(
            'No chat data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Import your IG chat JSON file to view messages',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _importChat,
            icon: const Icon(Icons.file_upload),
            label: const Text('Import Chat JSON'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Note: Use the "Download Your Information" feature on Instagram to get your chat data',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(List<ChatMessage> messages) {
    return ListView.builder(
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
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatDate(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? const Color(0xFFFF6B6B)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isCurrentUser ? Colors.white : Colors.black,
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
            ),
          ],
        );
      },
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat Data'),
        content: const Text(
          'Are you sure you want to clear all chat data? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final chatProvider = context.read<ChatProvider>();
              chatProvider.clearChatData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat data cleared'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
