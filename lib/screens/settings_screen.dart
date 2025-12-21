// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:muchi/screens/ig_chat_screen.dart';
import 'package:muchi/services/data_service.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:muchi/providers/memory_provider.dart'; // Add this import

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memoryProvider = context.read<MemoryProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFF6B6B)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Data Management Section
          _buildSection(
            title: 'Data Management',
            icon: Icons.data_usage,
            color: const Color(0xFF4CAF50),
            children: [
              _buildSettingItem(
                icon: Icons.backup,
                title: 'Export as JSON',
                subtitle: 'Backup all memories as JSON file',
                onTap: () => DataService.exportMemories(context),
                color: const Color(0xFF4CAF50),
              ),
              _buildSettingItem(
                icon: Icons.text_snippet,
                title: 'Export as Text',
                subtitle: 'Export memories in readable text format',
                onTap: () => DataService.exportAsText(context),
                color: const Color(0xFF2196F3),
              ),
              _buildSettingItem(
                icon: Icons.download,
                title: 'Import Memories',
                subtitle: 'Import memories from backup file',
                onTap: () => DataService.importMemories(context),
                color: const Color(0xFFFF9800),
              ),
              _buildSettingItem(
                icon: Icons.merge,
                title: 'Import IG Chat',
                subtitle: 'Import Instagram chat JSON file',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IgChatScreen(),
                    ),
                  );
                },
                color: const Color(0xFF9C27B0),
              ),
              _buildSettingItem(
                icon: Icons.delete_forever,
                title: 'Clear All Data',
                subtitle: 'Delete all memories (irreversible)',
                onTap: () => DataService.clearAllData(context),
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Info Section
          _buildSection(
            title: 'About',
            icon: Icons.info,
            color: const Color(0xFF9C27B0),
            children: [
              _buildInfoItem(
                'Version',
                '1.0.5',
              ),
              _buildInfoItem(
                'Developed with',
                '❤️ for Chimdee',
              ),
              _buildInfoItem(
                'Memories Count',
                '${memoryProvider.memories.length}',
              ),
            ],
          ),

          const SizedBox(height: 60),

          // Footer
          Center(
            child: Column(
              children: [
                Text(
                  '🐇Muunu & 🐈‍⬛Chimdee',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontFamily: 'DancingScript',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Олон олон дурсамж бүтээе хэхэ💖',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF6B6B),
            ),
          ),
        ],
      ),
    );
  }

  void _showBulkImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Import Instagram Chat'),
        content: const Text(
          'Select all your message_*.json files from the Instagram data folder. '
          'The app will merge them into a single conversation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Navigate to chat screen with bulk import option
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IgChatScreen(),
                ),
              ).then((_) {
                // Trigger bulk import
                Future.delayed(Duration(milliseconds: 500), () {
                  // You might want to pass a parameter or use a different approach
                  // This is just a conceptual example
                });
              });
            },
            child: const Text('Start Bulk Import'),
          ),
        ],
      ),
    );
  }
}
