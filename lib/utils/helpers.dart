import 'package:flutter/material.dart';

IconData getWeatherIcon(String weather) {
  final Map<String, IconData> weatherIcons = {
    'sunny': Icons.wb_sunny,
    'cloudy': Icons.cloud,
    'clear': Icons.wb_sunny,
    'rainy': Icons.beach_access,
  };

  return weatherIcons[weather] ?? Icons.wb_sunny;
}

IconData getMoodIcon(String mood) {
  final Map<String, IconData> moodIcons = {
    'happy': Icons.sentiment_very_satisfied,
    'romantic': Icons.favorite,
    'nervous': Icons.sentiment_neutral,
    'excited': Icons.emoji_emotions,
  };

  return moodIcons[mood] ?? Icons.sentiment_satisfied;
}
