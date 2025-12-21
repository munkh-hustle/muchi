// lib/screens/ig_chat_hierarchical_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muchi/models/chat_message.dart';
import 'package:muchi/screens/ig_chat_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:muchi/providers/chat_provider.dart';

class IgChatHierarchicalScreen extends StatefulWidget {
  const IgChatHierarchicalScreen({super.key});

  @override
  State<IgChatHierarchicalScreen> createState() =>
      _IgChatHierarchicalScreenState();
}

class _IgChatHierarchicalScreenState extends State<IgChatHierarchicalScreen> {
  String? _selectedYear;
  String? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (!chatProvider.hasChatData) {
          return const Center(
            child: Text('No chat data imported'),
          );
        }

        final messagesByYear = chatProvider.getMessagesByYear();

        return Scaffold(
          // Update app bar in ig_chat_hierarchical_screen.dart
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.favorite, color: Color(0xFFFF6B6B), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedMonth != null
                        ? '${_getMonthName(_selectedMonth!)} 💌'
                        : _selectedYear != null
                            ? 'Chat $_selectedYear ❤️'
                            : 'Our Love Messages 💝',
                    style: GoogleFonts.dancingScript(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFFFFF8F7),
            leading: _selectedMonth != null || _selectedYear != null
                ? IconButton(
                    icon: Icon(Icons.arrow_back, color: Color(0xFFFF6B6B)),
                    onPressed: () {
                      setState(() {
                        if (_selectedMonth != null) {
                          _selectedMonth = null;
                        } else {
                          _selectedYear = null;
                        }
                      });
                    },
                  )
                : null,
            actions: [
              IconButton(
                icon: Icon(Icons.photo_library, color: Color(0xFFFF6B6B)),
                onPressed: () {
                  // Optional: Show photo gallery
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showClearDialog(context),
              ),
            ],
          ),
          body: _buildContent(context, chatProvider, messagesByYear),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ChatProvider chatProvider,
      Map<String, List<ChatMessage>> messagesByYear) {
    if (_selectedMonth != null) {
      // Show days for selected month
      final messagesByDay = chatProvider.getMessagesByDay(_selectedMonth!);
      return _buildDayList(messagesByDay);
    } else if (_selectedYear != null) {
      // Show months for selected year
      final messagesByMonth = chatProvider.getMessagesByMonth(_selectedYear!);
      return _buildMonthList(messagesByMonth);
    } else {
      // Show years
      return _buildYearList(messagesByYear);
    }
  }

  Widget _buildYearList(Map<String, List<ChatMessage>> messagesByYear) {
    return ListView.builder(
      itemCount: messagesByYear.length,
      itemBuilder: (context, index) {
        final year = messagesByYear.keys.elementAt(index);
        final messages = messagesByYear[year]!;

        return // Update list tiles in ig_chat_hierarchical_screen.dart
            ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.calendar_today, color: Color(0xFFFF6B6B)),
          ),
          title: Text(
            '$year',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          subtitle: Text(
            '💖 ${messages.length} love messages',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFFF6B6B),
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: Color(0xFFFFB6C1)),
          onTap: () {
            setState(() {
              _selectedYear = year;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          tileColor: Colors.white,
        );
      },
    );
  }

  Widget _buildMonthList(Map<String, List<ChatMessage>> messagesByMonth) {
    return ListView.builder(
      itemCount: messagesByMonth.length,
      itemBuilder: (context, index) {
        final monthKey = messagesByMonth.keys.elementAt(index);
        final messages = messagesByMonth[monthKey]!;

        return ListTile(
          leading: const Icon(Icons.calendar_month),
          title: Text(_getMonthName(monthKey)),
          subtitle: Text('${messages.length} messages'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            setState(() {
              _selectedMonth = monthKey;
            });
          },
        );
      },
    );
  }

  Widget _buildDayList(Map<String, List<ChatMessage>> messagesByDay) {
    return ListView.builder(
      itemCount: messagesByDay.length,
      itemBuilder: (context, index) {
        final dayKey = messagesByDay.keys.elementAt(index);
        final messages = messagesByDay[dayKey]!;

        return ListTile(
          leading: const Icon(Icons.today),
          title: Text(_formatDate(DateTime.parse(dayKey))),
          subtitle: Text('${messages.length} messages'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IgChatDetailScreen(
                  messages: messages,
                  title: _formatDate(DateTime.parse(dayKey)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getMonthName(String monthKey) {
    final parts = monthKey.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);

    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${monthNames[month - 1]} $year';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat Data'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ChatProvider>().clearChatData();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
