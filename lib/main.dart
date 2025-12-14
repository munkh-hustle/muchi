// lib/
// ├── main.dart
// ├── data/
// │   ├── memory.dart
// │   └── memory_data.dart
// ├── screens/
// │   ├── add_edit_memory_screen.dart
// │   ├── timeline_screen.dart
// │   └── memory_detail_screen.dart
// │   └── settings_screen.dart
// ├── widgets/
// │   └── memory_card.dart
// └── utils/
//     └── helpers.dart
// └── services/
//     └── data_service.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muchi/screens/timeline_screen.dart';

void main() {
  runApp(const LoveDiaryApp());
}

class LoveDiaryApp extends StatelessWidget {
  const LoveDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoveLines',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB6C1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.dancingScript(
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
      home: const TimelineScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
