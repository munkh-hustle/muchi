import 'package:muchi/data/memory.dart';
import 'package:muchi/services/storage_service.dart';

class MemoryData {
  static List<Memory> _memories = [];

  // Getter to access memories
  static List<Memory> get memories => List.unmodifiable(_memories);

  // Initialize with saved data
  static Future<void> init() async {
    _memories = await StorageService.loadMemories();
  }

  // ADD: Add a new memory
  static Future<void> addMemory(Memory memory) async {
    _memories.add(memory);
    _sortMemories();
    await StorageService.saveMemories(_memories);
  }

  // DELETE: Remove a memory
  static Future<void> deleteMemory(Memory memory) async {
    _memories.remove(memory);
    await StorageService.saveMemories(_memories);
  }

  // UPDATE: Update an existing memory
  static Future<void> updateMemory(Memory oldMemory, Memory newMemory) async {
    final index = _memories.indexOf(oldMemory);
    if (index != -1) {
      _memories[index] = newMemory;
      _sortMemories();
      await StorageService.saveMemories(_memories);
    }
  }

  // GET: Get memory by index
  static Memory getMemory(int index) {
    return _memories[index];
  }

  // Helper method to sort memories
  static void _sortMemories() {
    _memories.sort((a, b) => b.date.compareTo(a.date));
  }

  // Clear all memories (for Settings screen)
  static Future<void> clearAllMemories() async {
    _memories.clear();
    await StorageService.clearAllData();
  }
}
