// lib/providers/memory_provider.dart
import 'package:flutter/material.dart';
import 'package:muchi/data/memory.dart';
import 'package:muchi/services/storage_service.dart';

class MemoryProvider extends ChangeNotifier {
  List<Memory> _memories = [];

  List<Memory> get memories => List.unmodifiable(_memories);
  int get count => _memories.length;

  MemoryProvider() {
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    _memories = await StorageService.loadMemories();
    _sortMemories();
    notifyListeners();
  }

  Future<void> addMemory(Memory memory) async {
    _memories.add(memory);
    _sortMemories();
    await StorageService.saveMemories(_memories);
    notifyListeners();
  }

  Future<void> deleteMemory(Memory memory) async {
    _memories.remove(memory);
    await StorageService.saveMemories(_memories);
    notifyListeners();
  }

  Future<void> updateMemory(Memory oldMemory, Memory newMemory) async {
    final index = _memories.indexOf(oldMemory);
    if (index != -1) {
      _memories[index] = newMemory;
      _sortMemories();
      await StorageService.saveMemories(_memories);
      notifyListeners();
    }
  }

  void _sortMemories() {
    _memories.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> clearAll() async {
    _memories.clear();
    await StorageService.clearAllData();
    notifyListeners();
  }
}
