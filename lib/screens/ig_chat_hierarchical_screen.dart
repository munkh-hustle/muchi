// lib/screens/ig_chat_hierarchical_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muchi/models/chat_message.dart';
import 'package:muchi/screens/ig_chat_detail_screen.dart';
import 'package:muchi/screens/ig_chat_screen.dart';
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
          return _buildEmptyState();
        }

        final messagesByYear = chatProvider.getMessagesByYear();

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.favorite, color: Color(0xFFFF6B6B), size: 20),
                const SizedBox(width: 8),
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
            backgroundColor: const Color(0xFFFFF8F7),
            leading: _selectedMonth != null || _selectedYear != null
                ? IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFFFF6B6B)),
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
                icon: const Icon(Icons.delete, color: Colors.red),
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
      return _buildDayGrid(messagesByDay);
    } else if (_selectedYear != null) {
      // Show months for selected year
      final messagesByMonth = chatProvider.getMessagesByMonth(_selectedYear!);
      return _buildMonthGrid(messagesByMonth);
    } else {
      // Show years
      return _buildYearGrid(messagesByYear);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          const Text(
            'No IG Chat Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Import your Instagram chat JSON file',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to import screen or show file picker
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IgChatScreen(),
                ),
              );
            },
            icon: const Icon(Icons.file_upload),
            label: const Text('Import Chat JSON'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearGrid(Map<String, List<ChatMessage>> messagesByYear) {
    final years = messagesByYear.keys.toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        final messages = messagesByYear[year]!;
        final messageCount = messages.length;

        return _buildYearCard(year, messageCount);
      },
    );
  }

  Widget _buildYearCard(String year, int messageCount) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedYear = year;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6B6B),
              const Color(0xFFFF8E8E),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 3,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative hearts
            Positioned(
              top: 10,
              right: 10,
              child: Icon(
                Icons.favorite,
                color: Colors.white.withOpacity(0.3),
                size: 40,
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Icon(
                Icons.favorite,
                color: Colors.white.withOpacity(0.2),
                size: 30,
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    year,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'DancingScript',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$messageCount messages',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View Months',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid(Map<String, List<ChatMessage>> messagesByMonth) {
    final months = messagesByMonth.keys.toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: months.length,
      itemBuilder: (context, index) {
        final monthKey = months[index];
        final messages = messagesByMonth[monthKey]!;
        final monthName = _getMonthName(monthKey);

        return _buildMonthCard(monthName, monthKey, messages.length);
      },
    );
  }

  Widget _buildMonthCard(String monthName, String monthKey, int messageCount) {
    final monthNumber = int.parse(monthKey.split('-')[1]);
    final emoji = _getMonthEmoji(monthNumber);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMonth = monthKey;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFB6C1),
              const Color(0xFFFFD1D9),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Month number in background
            Positioned(
              right: 10,
              top: 10,
              child: Text(
                monthNumber.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          monthName.split(' ')[0],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$messageCount messages',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Color(0xFFFF6B6B),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'View Days',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFFF6B6B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayGrid(Map<String, List<ChatMessage>> messagesByDay) {
    final days = messagesByDay.keys.toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final dayKey = days[index];
        final messages = messagesByDay[dayKey]!;
        final date = DateTime.parse(dayKey);
        final dayNumber = date.day;
        final dayName = _getDayName(date.weekday);

        return _buildDayCard(dayNumber, dayName, dayKey, messages.length);
      },
    );
  }

  Widget _buildDayCard(
      int dayNumber, String dayName, String dayKey, int messageCount) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IgChatDetailScreen(
              messages: context
                  .read<ChatProvider>()
                  .getMessagesByDay(dayKey)[dayKey]!,
              title: '${_getMonthName(dayKey.substring(0, 7))} $dayNumber',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFFFB6C1).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  dayNumber.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dayName.substring(0, 3),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB6C1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$messageCount',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
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

  String _getDayName(int weekday) {
    final dayNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return dayNames[weekday - 1];
  }

  String _getMonthEmoji(int month) {
    switch (month) {
      case 1:
        return '❄️'; // January
      case 2:
        return '💖'; // February
      case 3:
        return '🌸'; // March
      case 4:
        return '🌧️'; // April
      case 5:
        return '🌷'; // May
      case 6:
        return '☀️'; // June
      case 7:
        return '🌊'; // July
      case 8:
        return '🌻'; // August
      case 9:
        return '🍂'; // September
      case 10:
        return '🎃'; // October
      case 11:
        return '🍁'; // November
      case 12:
        return '🎄'; // December
      default:
        return '📅';
    }
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
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
