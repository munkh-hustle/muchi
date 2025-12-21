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

  Future<void> importChatFromJson(String jsonString) async {
    try {
      await _parseChatData(jsonString);

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('chat_data', jsonString);

      _hasChatData = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _parseChatData(String jsonString) async {
    try {
      print('Parsing chat data...');
      final jsonData = jsonDecode(jsonString);

      List<dynamic> messagesList;
      List<String> participantsList = ['User 1', 'User 2'];

      // Handle different JSON structures
      if (jsonData['messages'] != null) {
        messagesList = jsonData['messages'];

        // Get participants
        if (jsonData['participants'] != null &&
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

        // Get participants
        if (jsonData['conversation']['participants'] != null &&
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

      print(
          'Found ${messagesList.length} messages from ${participantsList.join(' & ')}');

      // Parse messages with error handling
      final List<ChatMessage> parsedMessages = [];
      int errorCount = 0;

      for (int i = 0; i < messagesList.length; i++) {
        try {
          final msg = messagesList[i];
          if (msg is Map<String, dynamic>) {
            final chatMessage = ChatMessage.fromJson(msg);
            parsedMessages.add(chatMessage);
          }
        } catch (e) {
          errorCount++;
          print('Error parsing message $i: $e');

          // Skip problematic messages instead of crashing
          continue;
        }
      }

      if (errorCount > 0) {
        print(
            'Skipped $errorCount problematic messages out of ${messagesList.length}');
      }

      // Sort messages by timestamp (newest first)
      parsedMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _messages = parsedMessages;
      _participants = participantsList;
      _hasChatData = _messages.isNotEmpty;

      print('Successfully parsed ${_messages.length} messages');
    } catch (e) {
      print('Error parsing chat data: $e');

      // Clear data on error
      _messages.clear();
      _participants.clear();
      _hasChatData = false;

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
}
