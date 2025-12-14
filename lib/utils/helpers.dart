// Simple helper functions for emoji display
String getMoodDisplay(String mood) {
  // Return the emoji directly or use default
  return mood.isNotEmpty ? mood : '😊';
}

String getWeatherDisplay(String weather) {
  // Return the emoji directly or use default
  return weather.isNotEmpty ? weather : '☀️';
}

// Optional: List of default emojis for suggestions
List<String> getDefaultMoods() {
  return ['😊', '❤️', '😍', '😘', '🥰'];
}

List<String> getDefaultWeathers() {
  return ['☀️', '⛅', '☁️', '🌧️', '❄️'];
}
