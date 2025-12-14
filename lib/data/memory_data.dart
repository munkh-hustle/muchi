// In memory_data.dart
import 'package:muchi/data/memory.dart';

class MemoryData {
  static List<Memory> get memories {
    // This is now just a wrapper for the provider
    // In practice, you should remove all direct MemoryData usage
    return []; // Return empty or find a way to access provider
  }

  // ... (other methods should be removed or marked deprecated)
}
