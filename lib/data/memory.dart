// lib/data/memory.dart
class Memory {
  final DateTime date;
  final String title;
  final List<String> highlights;
  final String fullStory;
  final String location;
  final int loveRating;
  final String mood; // Now stores emoji like '😊'
  final String weather; // Now stores emoji like '☀️'
  final bool isMilestone;
  final List<String> tags;
  final String secretNote;

  Memory({
    required this.date,
    required this.title,
    required this.highlights,
    required this.fullStory,
    required this.location,
    this.loveRating = 5,
    this.mood = '😊',
    this.weather = '☀️',
    this.isMilestone = false,
    this.tags = const [],
    this.secretNote = '',
  });
}
