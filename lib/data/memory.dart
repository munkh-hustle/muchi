class Memory {
  final DateTime date;
  final String title;
  final List<String> highlights;
  final String fullStory;
  final List<String> photos;
  final String location;
  final int loveRating;
  final String mood;
  final String weather;
  final bool isMilestone;
  final List<String> tags;
  final String secretNote;

  Memory({
    required this.date,
    required this.title,
    required this.highlights,
    required this.fullStory,
    required this.photos,
    required this.location,
    this.loveRating = 5,
    this.mood = 'happy',
    this.weather = 'sunny',
    this.isMilestone = false,
    this.tags = const [],
    this.secretNote = '',
  });
}
