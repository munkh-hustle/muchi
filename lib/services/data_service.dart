// lib/services/data_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:muchi/providers/memory_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:muchi/data/memory.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DataService {
  // Export memories as JSON file
  static Future<void> exportMemories(BuildContext context) async {
    try {
      final memoryProvider = context.read<MemoryProvider>();
      final memories = memoryProvider.memories;
      final List<Map<String, dynamic>> exportData = memories.map((memory) {
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
        'app': 'LoveLines',
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'memoriesCount': memories.length,
        'memories': exportData,
      });

      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/lovelines_backup_$timestamp.json');

      await file.writeAsString(jsonData);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'LoveLines Memories Backup',
        subject: 'LoveLines Backup ${DateTime.now().toString()}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported ${memories.length} memories successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Import memories from JSON file
  static Future<void> importMemories(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);

      // Validate JSON structure
      if (jsonData['app'] != 'LoveLines') {
        throw Exception('Invalid LoveLines backup file');
      }

      final importedMemories = (jsonData['memories'] as List)
          .map((item) => Memory(
                date: DateTime.parse(item['date']),
                title: item['title'],
                highlights: List<String>.from(item['highlights']),
                fullStory: item['fullStory'],
                location: item['location'],
                loveRating: item['loveRating'],
                mood: item['mood'],
                weather: item['weather'],
                isMilestone: item['isMilestone'],
                tags: List<String>.from(item['tags']),
                secretNote: item['secretNote'],
              ))
          .toList();

      // Show confirmation dialog
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Memories'),
          content: Text(
            'Found ${importedMemories.length} memories. Import them? '
            'This will add them to your existing memories.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Import'),
            ),
          ],
        ),
      );
      final memoryProvider = context.read<MemoryProvider>(); // Add this

      if (confirm == true) {
        // Add imported memories
        for (var memory in importedMemories) {
          await memoryProvider.addMemory(memory);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully imported ${importedMemories.length} memories!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Export as plain text (readable format)
  static Future<void> exportAsText(BuildContext context) async {
    try {
      final memoryProvider = context.read<MemoryProvider>();
      final memories = memoryProvider.memories;
      final buffer = StringBuffer();

      buffer.writeln('❤️ LoveLines Memories Export ❤️');
      buffer.writeln('Exported: ${DateTime.now()}');
      buffer.writeln('Total Memories: ${memories.length}');
      buffer.writeln('=' * 50);
      buffer.writeln();

      for (var memory in memories) {
        buffer.writeln('📅 ${memory.date.toLocal()}');
        buffer.writeln('✨ ${memory.title}');
        buffer.writeln('📍 ${memory.location}');
        buffer.writeln('😊 Mood: ${memory.mood}');
        buffer.writeln('☀️ Weather: ${memory.weather}');
        buffer.writeln('💖 Love Rating: ${'❤️' * memory.loveRating}');
        buffer.writeln('⭐ Milestone: ${memory.isMilestone ? 'Yes' : 'No'}');

        buffer.writeln('\nHighlights:');
        for (var highlight in memory.highlights) {
          buffer.writeln('  • $highlight');
        }

        buffer.writeln('\nStory:');
        buffer.writeln(memory.fullStory);

        buffer.writeln('\nTags: ${memory.tags.join(", ")}');
        buffer.writeln('\nSecret Note: ${memory.secretNote}');
        buffer.writeln('=' * 50);
        buffer.writeln();
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/lovelines_export_$timestamp.txt');

      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'LoveLines Memories Text Export',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported as text successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Clear all data (with confirmation)
  static Future<void> clearAllData(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          '⚠️ WARNING: This will delete ALL memories permanently! '
          'Make sure you have exported your data first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final memoryProvider = context.read<MemoryProvider>(); // Add this
      await memoryProvider.clearAll();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All memories have been deleted.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
