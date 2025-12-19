// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muchi/data/memory.dart';

class StorageService {
  static const String _memoriesKey = 'memories_data';
  static const String _currentVersion = '1.0';

  // Save all memories to local storage
  static Future<void> saveMemories(List<Memory> memories) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert memories to JSON
      final List<Map<String, dynamic>> jsonList = memories.map((memory) {
        return {
          'date': memory.date.toIso8601String(),
          'title': memory.title,
          'highlights': memory.highlights,
          'fullStory': memory.fullStory,
          'location': memory.location,
          'loveRating': memory.loveRating,
          'mood': memory.mood,
          'weather': memory.weather,
          'isMilestone': memory.isMilestone,
          'tags': memory.tags,
          'secretNote': memory.secretNote,
        };
      }).toList();

      final jsonData = jsonEncode({
        'version': _currentVersion,
        'memories': jsonList,
        'lastSaved': DateTime.now().toIso8601String(),
      });

      await prefs.setString(_memoriesKey, jsonData);
    } catch (e) {
      print('Error saving memories: $e');
      rethrow;
    }
  }

  // Load all memories from local storage
  static Future<List<Memory>> loadMemories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_memoriesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonData = jsonDecode(jsonString);

      // Validate version (optional, for future migrations)
      if (jsonData['version'] != _currentVersion) {
        print(
            'Data version mismatch. Current: $_currentVersion, Stored: ${jsonData['version']}');
      }

      final List<dynamic> memoryList = jsonData['memories'];

      return memoryList.map((item) {
        return Memory(
          date: DateTime.parse(item['date']),
          title: item['title'],
          highlights: List<String>.from(item['highlights']),
          fullStory: item['fullStory'],
          location: item['location'],
          loveRating: item['loveRating'],
          mood: item['mood'] ?? '😊',
          weather: item['weather'] ?? '☀️',
          isMilestone: item['isMilestone'] ?? false,
          tags: List<String>.from(item['tags']),
          secretNote: item['secretNote'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error loading memories: $e');
      return [];
    }
  }

  // Clear all stored data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_memoriesKey);
  }
}
