import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muchi/data/memory_data.dart';
import 'package:muchi/screens/add_edit_memory_screen.dart';
import 'package:muchi/screens/memory_detail_screen.dart';
import 'package:muchi/widgets/memory_card.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  int _selectedMonth = 0;
  final List<String> _months = [
    'December 2024',
    'January 2025',
    'February 2025'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F7),
      body: Column(
        children: [
          // Custom App Bar
          _buildAppBar(),

          // Month Selector
          _buildMonthSelector(),

          // Timeline
          Expanded(
            child: _buildTimeline(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(
        top: 50,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade50,
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFFF6B6B)),
            onPressed: () {
              _showBottomMenu(context);
            },
          ),
          Text(
            'LoveLines',
            style: GoogleFonts.dancingScript(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFF6B6B),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFFFF6B6B)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFFFFB6C1)),
            onPressed: () {
              if (_selectedMonth > 0) {
                setState(() {
                  _selectedMonth--;
                });
              }
            },
          ),
          Text(
            _months[_selectedMonth],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Color(0xFFFFB6C1)),
            onPressed: () {
              if (_selectedMonth < _months.length - 1) {
                setState(() {
                  _selectedMonth++;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // Replace the entire _buildTimeline() method with this:

  Widget _buildTimeline() {
    final filteredMemories = MemoryData.memories.where((memory) {
      if (_selectedMonth == 0) return memory.date.month == 12;
      if (_selectedMonth == 1) return memory.date.month == 1;
      return memory.date.month == 2;
    }).toList();

    // If no memories for selected month
    if (filteredMemories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_album,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No memories for ${_months[_selectedMonth]}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add one!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredMemories.length,
      itemBuilder: (context, index) {
        final memory = filteredMemories[index];
        return MemoryCard(
          memory: memory,
          index: index,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MemoryDetailScreen(memory: memory),
              ),
            );
          },
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditMemoryScreen(memory: memory),
                fullscreenDialog: true,
              ),
            ).then((refresh) {
              if (refresh == true) {
                setState(() {}); // Refresh the timeline
              }
            });
          },
          onDelete: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Memory'),
                content:
                    const Text('Are you sure you want to delete this memory?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      MemoryData.deleteMemory(memory);
                      setState(() {});
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Memory deleted!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _showAddMemoryDialog(context);
      },
      backgroundColor: const Color(0xFFFF6B6B),
      shape: const CircleBorder(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF6B6B),
              const Color(0xFFFF8E8E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  void _showAddMemoryDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditMemoryScreen(),
        fullscreenDialog: true,
      ),
    ).then((refresh) {
      if (refresh == true) {
        setState(() {}); // Refresh the timeline
      }
    });
  }

  void _showBottomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildMenuItem(
                icon: Icons.calendar_month,
                title: 'Calendar View',
                color: const Color(0xFF4FC3F7),
                onTap: () {
                  Navigator.pop(context);
                  _showFeatureDialog('Calendar View');
                },
              ),
              _buildMenuItem(
                icon: Icons.collections_bookmark,
                title: 'Collections',
                color: const Color(0xFFD4AF37),
                onTap: () {
                  Navigator.pop(context);
                  _showFeatureDialog('Collections');
                },
              ),
              _buildMenuItem(
                icon: Icons.tag,
                title: 'Search by Tags',
                color: const Color(0xFFFFB6C1),
                onTap: () {
                  Navigator.pop(context);
                  _showFeatureDialog('Search by Tags');
                },
              ),
              _buildMenuItem(
                icon: Icons.favorite,
                title: 'Milestones',
                color: const Color(0xFFFF6B6B),
                onTap: () {
                  Navigator.pop(context);
                  _showFeatureDialog('Milestones');
                },
              ),
              _buildMenuItem(
                icon: Icons.map,
                title: 'Memory Map',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  Navigator.pop(context);
                  _showFeatureDialog('Memory Map');
                },
              ),
              _buildMenuItem(
                icon: Icons.settings,
                title: 'Settings',
                color: Colors.grey,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'LoveLines • Our Story',
                  style: GoogleFonts.dancingScript(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
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
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showFeatureDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$featureName'),
          content: Text('$featureName feature coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
