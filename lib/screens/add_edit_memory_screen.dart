// lib/screens/add_edit_memory_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muchi/data/memory.dart';
import 'package:muchi/data/memory_data.dart';
import 'package:muchi/utils/helpers.dart';

class AddEditMemoryScreen extends StatefulWidget {
  final Memory? memory; // null = add, not null = edit
  final DateTime? selectedDate; // For adding with pre-selected date

  const AddEditMemoryScreen({
    super.key,
    this.memory,
    this.selectedDate,
  });

  @override
  State<AddEditMemoryScreen> createState() => _AddEditMemoryScreenState();
}

class _AddEditMemoryScreenState extends State<AddEditMemoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _fullStoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _secretNoteController = TextEditingController();
  final _highlightController = TextEditingController();
  final _tagController = TextEditingController();
  final _moodController = TextEditingController();
  final _weatherController = TextEditingController();

  late DateTime _selectedDate;
  int _loveRating = 5;
  bool _isMilestone = false;
  List<String> _highlights = [];
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();

    // Set initial date based on widget parameters
    if (widget.memory != null) {
      // Edit mode
      final memory = widget.memory!;
      _titleController.text = memory.title;
      _fullStoryController.text = memory.fullStory;
      _locationController.text = memory.location;
      _secretNoteController.text = memory.secretNote;
      _selectedDate = memory.date;
      _loveRating = memory.loveRating;
      _isMilestone = memory.isMilestone;
      _highlights = List.from(memory.highlights);
      _tags = List.from(memory.tags);
      _moodController.text = memory.mood;
      _weatherController.text = memory.weather;
    } else {
      // Add mode
      _selectedDate = widget.selectedDate ?? DateTime.now();
      _moodController.text = '😊';
      _weatherController.text = '☀️';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fullStoryController.dispose();
    _locationController.dispose();
    _secretNoteController.dispose();
    _highlightController.dispose();
    _tagController.dispose();
    _moodController.dispose();
    _weatherController.dispose();
    super.dispose(); // Only call super.dispose() once
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addHighlight() {
    if (_highlightController.text.trim().isNotEmpty) {
      setState(() {
        _highlights.add(_highlightController.text.trim());
        _highlightController.clear();
      });
    }
  }

  void _removeHighlight(int index) {
    setState(() {
      _highlights.removeAt(index);
    });
  }

  void _addTag() {
    if (_tagController.text.trim().isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.memory == null ? 'Add New Memory' : 'Edit Memory',
          style: const TextStyle(color: Color(0xFFFF6B6B)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFF6B6B)),
        actions: [
          if (widget.memory != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context),
              color: Colors.red,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Date Picker
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                        style: const TextStyle(color: Color(0xFFFF6B6B)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Memory Title',
                  labelStyle: const TextStyle(color: Color(0xFFFFB6C1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFB6C1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  labelStyle: const TextStyle(color: Color(0xFFFFB6C1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFB6C1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Mood and Weather with emoji input
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mood',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _moodController,
                          decoration: InputDecoration(
                            hintText: 'Enter emoji (e.g., 😊)',
                            prefixIcon: const Icon(Icons.emoji_emotions),
                            suffixIcon: PopupMenuButton<String>(
                              icon: const Icon(Icons.arrow_drop_down),
                              onSelected: (value) {
                                setState(() {
                                  _moodController.text = value;
                                });
                              },
                              itemBuilder: (context) {
                                return getDefaultMoods().map((emoji) {
                                  return PopupMenuItem<String>(
                                    value: emoji,
                                    child: Text(emoji),
                                  );
                                }).toList();
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Default: ${getDefaultMoods().join(' ')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weather',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _weatherController,
                          decoration: InputDecoration(
                            hintText: 'Enter emoji (e.g., ☀️)',
                            prefixIcon: const Icon(Icons.wb_sunny),
                            suffixIcon: PopupMenuButton<String>(
                              icon: const Icon(Icons.arrow_drop_down),
                              onSelected: (value) {
                                setState(() {
                                  _weatherController.text = value;
                                });
                              },
                              itemBuilder: (context) {
                                return getDefaultWeathers().map((emoji) {
                                  return PopupMenuItem<String>(
                                    value: emoji,
                                    child: Text(emoji),
                                  );
                                }).toList();
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Default: ${getDefaultWeathers().join(' ')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Love Rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Love Rating',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.favorite,
                          size: 32,
                          color: index < _loveRating
                              ? const Color(0xFFFF6B6B)
                              : Colors.grey.shade300,
                        ),
                        onPressed: () {
                          setState(() {
                            _loveRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Milestone Toggle
              SwitchListTile(
                title: const Text(
                  'Mark as Milestone',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Special memories get golden highlights'),
                value: _isMilestone,
                activeColor: const Color(0xFFFF6B6B),
                onChanged: (value) {
                  setState(() {
                    _isMilestone = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Highlights
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Highlights',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _highlightController,
                          decoration: InputDecoration(
                            hintText: 'Add a highlight...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addHighlight,
                        color: const Color(0xFFFF6B6B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._highlights.asMap().entries.map((entry) {
                    final index = entry.key;
                    final highlight = entry.value;
                    return ListTile(
                      leading: const Icon(Icons.circle,
                          size: 8, color: Color(0xFFFF6B6B)),
                      title: Text(highlight),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeHighlight(index),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),

              // Tags
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tags',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tagController,
                          decoration: InputDecoration(
                            hintText: 'Add a tag...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTag,
                        color: const Color(0xFFFF6B6B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.asMap().entries.map((entry) {
                      final index = entry.key;
                      final tag = entry.value;
                      return Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeTag(index),
                        backgroundColor:
                            const Color(0xFFFFB6C1).withOpacity(0.1),
                        labelStyle: const TextStyle(color: Color(0xFFFF6B6B)),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Full Story
              TextFormField(
                controller: _fullStoryController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Full Story',
                  labelStyle: const TextStyle(color: Color(0xFFFFB6C1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFB6C1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Secret Note
              TextFormField(
                controller: _secretNoteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Secret Note (Optional)',
                  labelStyle: const TextStyle(color: Color(0xFFFFB6C1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFB6C1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newMemory = Memory(
                      date: _selectedDate,
                      title: _titleController.text,
                      highlights: _highlights,
                      fullStory: _fullStoryController.text,
                      location: _locationController.text,
                      loveRating: _loveRating,
                      mood: _moodController.text,
                      weather: _weatherController.text,
                      isMilestone: _isMilestone,
                      tags: _tags,
                      secretNote: _secretNoteController.text,
                    );

                    if (widget.memory == null) {
                      // Add new memory
                      MemoryData.addMemory(newMemory);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Memory added successfully!'),
                          backgroundColor: Color(0xFF4CAF50),
                        ),
                      );
                    } else {
                      // Update existing memory
                      MemoryData.updateMemory(widget.memory!, newMemory);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Memory updated successfully!'),
                          backgroundColor: Color(0xFF2196F3),
                        ),
                      );
                    }

                    Navigator.pop(context, true); // Return success
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  widget.memory == null ? 'Add Memory' : 'Update Memory',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Memory'),
        content: const Text(
            'Are you sure you want to delete this memory? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              MemoryData.deleteMemory(widget.memory!);
              Navigator.pop(context);
              Navigator.pop(context, true); // Return to timeline
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Memory deleted successfully!'),
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
  }
}
