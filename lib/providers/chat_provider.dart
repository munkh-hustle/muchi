// lib/providers/chat_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muchi/models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  List<String> _participants = [];
  bool _hasChatData = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<String> get participants => List.unmodifiable(_participants);
  bool get hasChatData => _hasChatData;

  ChatProvider() {
    _loadChatData();
  }

  Future<void> _loadChatData() async {
    final prefs = await SharedPreferences.getInstance();
    final chatJson = prefs.getString('chat_data');

    if (chatJson != null && chatJson.isNotEmpty) {
      await _parseChatData(chatJson);
    }

    notifyListeners();
  }

  Future<void> importChatFromJson(String jsonString,
      {bool merge = false}) async {
    try {
      // Parse the new messages
      await _parseChatData(jsonString, merge: merge);

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      final existingJson = prefs.getString('chat_data');

      if (merge && existingJson != null && existingJson.isNotEmpty) {
        // We need to merge with existing data
        final merged = _mergeChatData(existingJson, jsonString);
        await prefs.setString('chat_data', merged);
      } else {
        // Replace existing data
        await prefs.setString('chat_data', jsonString);
      }

      _hasChatData = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _parseChatData(String jsonString, {bool merge = false}) async {
    try {
      print('Parsing chat data (merge: $merge)...');
      final jsonData = jsonDecode(jsonString);

      List<dynamic> messagesList;
      List<String> participantsList =
          _participants; // Keep existing participants if merging

      // Handle different JSON structures (same as before)
      if (jsonData['messages'] != null) {
        messagesList = jsonData['messages'];

        if (!merge &&
            jsonData['participants'] != null &&
            jsonData['participants'] is List) {
          participantsList =
              (jsonData['participants'] as List).map<String>((p) {
            if (p is String) return p;
            if (p is Map && p['name'] != null) return p['name'].toString();
            return 'Unknown';
          }).toList();
        }
      } else if (jsonData['conversation'] != null &&
          jsonData['conversation']['messages'] != null) {
        messagesList = jsonData['conversation']['messages'];

        if (!merge &&
            jsonData['conversation']['participants'] != null &&
            jsonData['conversation']['participants'] is List) {
          participantsList = (jsonData['conversation']['participants'] as List)
              .map<String>((p) {
            if (p is String) return p;
            if (p is Map && p['name'] != null) return p['name'].toString();
            return 'Unknown';
          }).toList();
        }
      } else {
        throw Exception('Invalid chat JSON structure');
      }

      print('Found ${messagesList.length} messages');

      // Parse messages
      final List<ChatMessage> parsedMessages = [];

      for (int i = 0; i < messagesList.length; i++) {
        try {
          final msg = messagesList[i];
          if (msg is Map<String, dynamic>) {
            final chatMessage = ChatMessage.fromJson(msg);
            parsedMessages.add(chatMessage);
          }
        } catch (e) {
          print('Error parsing message $i: $e');
          continue;
        }
      }

      if (merge) {
        // Merge with existing messages
        final existingMessages = List<ChatMessage>.from(_messages);
        existingMessages.addAll(parsedMessages);

        // Remove duplicates based on timestamp and content
        final uniqueMessages = <ChatMessage>[];
        final seen = <String>{};

        for (final msg in existingMessages) {
          final key = '${msg.timestamp.millisecondsSinceEpoch}-${msg.content}';
          if (!seen.contains(key)) {
            seen.add(key);
            uniqueMessages.add(msg);
          }
        }

        // Sort by timestamp (newest first)
        uniqueMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        _messages = uniqueMessages;
      } else {
        // Replace existing messages
        _messages = parsedMessages;
        _participants = participantsList;
      }

      _hasChatData = _messages.isNotEmpty;
      print('Total messages after import: ${_messages.length}');
    } catch (e) {
      print('Error parsing chat data: $e');
      if (!merge) {
        _messages.clear();
        _participants.clear();
        _hasChatData = false;
      }
      rethrow;
    }
  }

  Future<void> clearChatData() async {
    _messages.clear();
    _participants.clear();
    _hasChatData = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_data');

    notifyListeners();
  }

  // Add these methods to ChatProvider class
  Map<String, List<ChatMessage>> getMessagesByYear() {
    final Map<String, List<ChatMessage>> yearMap = {};

    for (final message in _messages) {
      final year = message.timestamp.year.toString();
      if (!yearMap.containsKey(year)) {
        yearMap[year] = [];
      }
      yearMap[year]!.add(message);
    }

    // Sort years descending
    return Map.fromEntries(
        yearMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  }

  Map<String, List<ChatMessage>> getMessagesByMonth(String year) {
    final Map<String, List<ChatMessage>> monthMap = {};

    for (final message in _messages) {
      if (message.timestamp.year.toString() == year) {
        final month =
            '${message.timestamp.year}-${message.timestamp.month.toString().padLeft(2, '0')}';
        if (!monthMap.containsKey(month)) {
          monthMap[month] = [];
        }
        monthMap[month]!.add(message);
      }
    }

    return Map.fromEntries(
        monthMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  }

  Map<String, List<ChatMessage>> getMessagesByDay(String monthKey) {
    final Map<String, List<ChatMessage>> dayMap = {};
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    for (final message in _messages) {
      if (message.timestamp.year == year && message.timestamp.month == month) {
        final day =
            '${message.timestamp.year}-${message.timestamp.month.toString().padLeft(2, '0')}-${message.timestamp.day.toString().padLeft(2, '0')}';
        if (!dayMap.containsKey(day)) {
          dayMap[day] = [];
        }
        dayMap[day]!.add(message);
      }
    }

    return Map.fromEntries(
        dayMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  }

  String _mergeChatData(String existingJson, String newJson) {
    try {
      final existingData = jsonDecode(existingJson);
      final newData = jsonDecode(newJson);

      List<dynamic> existingMessages = [];
      List<dynamic> newMessages = [];

      // Extract messages from both JSONs
      if (existingData['messages'] != null) {
        existingMessages = existingData['messages'];
      } else if (existingData['conversation'] != null &&
          existingData['conversation']['messages'] != null) {
        existingMessages = existingData['conversation']['messages'];
      }

      if (newData['messages'] != null) {
        newMessages = newData['messages'];
      } else if (newData['conversation'] != null &&
          newData['conversation']['messages'] != null) {
        newMessages = newData['conversation']['messages'];
      }

      // Combine messages and remove duplicates
      final allMessages = [...existingMessages, ...newMessages];
      final uniqueMessages = <Map<String, dynamic>>[];
      final seen = <String>{};

      for (final msg in allMessages) {
        final timestamp = msg['timestamp_ms']?.toString() ??
            msg['timestamp']?.toString() ??
            '';
        final content = msg['content']?.toString() ?? '';
        final key = '$timestamp-$content';

        if (!seen.contains(key)) {
          seen.add(key);
          uniqueMessages.add(msg);
        }
      }

      // Sort by timestamp (oldest to newest for JSON structure)
      uniqueMessages.sort((a, b) {
        final timeA = a['timestamp_ms'] ?? a['timestamp'] ?? 0;
        final timeB = b['timestamp_ms'] ?? b['timestamp'] ?? 0;
        return (timeA as int).compareTo(timeB as int);
      });

      // Return merged JSON
      return jsonEncode({
        'messages': uniqueMessages,
        'participants': existingData['participants'] ??
            newData['participants'] ??
            ['User 1', 'User 2'],
        'merge_date': DateTime.now().toIso8601String(),
        'total_messages': uniqueMessages.length,
      });
    } catch (e) {
      print('Error merging chat data: $e');
      return existingJson; // Return existing data if merge fails
    }
  }
}
