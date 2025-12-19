// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muchi/providers/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:muchi/providers/memory_provider.dart';
import 'package:muchi/screens/timeline_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LoveDiaryApp());
}

class LoveDiaryApp extends StatelessWidget {
  const LoveDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MemoryProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'MuChi',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFB6C1),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
        home: const TimelineScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
