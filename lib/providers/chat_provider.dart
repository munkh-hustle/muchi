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
    final jsonData = jsonDecode(jsonString);

    // Parse participants
    _participants = (jsonData['participants'] as List)
        .map<String>((p) => p['name'].toString())
        .toList();

    // Parse messages
    _messages = (jsonData['messages'] as List)
        .map((msg) => ChatMessage.fromJson(msg))
        .toList();

    // Sort messages by timestamp (newest first)
    _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    _hasChatData = true;
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
