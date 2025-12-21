// lib/services/chat_merge_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ChatMergeService {
  // Import multiple JSON files and merge them
  static Future<String> importAndMergeMultipleFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No files selected');
      }

      final allMessages = [];
      List<String>? participants;

      for (final file in result.files) {
        if (file.path == null) continue;

        final jsonString = await File(file.path!).readAsString();
        final jsonData = jsonDecode(jsonString);

        // Extract messages from different structures
        List<dynamic> messagesList;
        if (jsonData['messages'] != null) {
          messagesList = jsonData['messages'];
        } else if (jsonData['conversation'] != null &&
            jsonData['conversation']['messages'] != null) {
          messagesList = jsonData['conversation']['messages'];
        } else {
          continue; // Skip invalid files
        }

        allMessages.addAll(messagesList);

        // Store participants from the first valid file
        if (participants == null) {
          if (jsonData['participants'] != null) {
            participants = (jsonData['participants'] as List)
                .map<String>((p) => p['name']?.toString() ?? 'Unknown')
                .toList();
          } else if (jsonData['conversation'] != null &&
              jsonData['conversation']['participants'] != null) {
            participants = (jsonData['conversation']['participants'] as List)
                .map<String>((p) => p['name']?.toString() ?? 'Unknown')
                .toList();
          }
        }
      }

      // Sort all messages by timestamp
      allMessages.sort((a, b) {
        final tsA = a['timestamp_ms'] ?? 0;
        final tsB = b['timestamp_ms'] ?? 0;
        return tsB.compareTo(tsA); // Newest first
      });

      // Create merged JSON
      final mergedJson = jsonEncode({
        'participants': participants ?? ['User 1', 'User 2'],
        'messages': allMessages,
        'merged_at': DateTime.now().toIso8601String(),
        'files_count': result.files.length,
      });

      return mergedJson;
    } catch (e) {
      print('Error merging files: $e');
      rethrow;
    }
  }

  // Check if folder contains multiple JSON files
  static Future<bool> hasMultipleMessageFiles(String folderPath) async {
    try {
      final directory = Directory(folderPath);
      if (!await directory.exists()) return false;

      final files = await directory.list().toList();
      final jsonFiles = files.where((file) {
        return file.path.endsWith('.json') && file.path.contains('message_');
      }).toList();

      return jsonFiles.length > 1;
    } catch (e) {
      return false;
    }
  }
}
