// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muchi/providers/chat_provider.dart';
import 'package:muchi/providers/love_coupon_provider.dart';
import 'package:provider/provider.dart';
import 'package:muchi/providers/memory_provider.dart';
import 'package:muchi/screens/timeline_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LoveDiaryApp());
}

// Update main.dart
class LoveDiaryApp extends StatelessWidget {
  const LoveDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MemoryProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => LoveCouponProvider()),
      ],
      child: MaterialApp(
        title: 'MuChi Love Diary',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B6B), // Romantic pink/red
            brightness: Brightness.light,
            primary: const Color(0xFFFF6B6B),
            secondary: const Color(0xFFFFB6C1),
            tertiary: const Color(0xFFFFE4E1),
            background: const Color(0xFFFFF8F7),
          ),
          useMaterial3: true,
          fontFamily: GoogleFonts.inter().fontFamily,

          // Romantic theme customizations
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFFF8F7),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Color(0xFFFF6B6B),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'DancingScript',
            ),
            iconTheme: IconThemeData(
              color: Color(0xFFFF6B6B),
            ),
          ),

          textTheme: TextTheme(
            displayLarge: GoogleFonts.dancingScript(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF6B6B),
            ),
            displayMedium: GoogleFonts.dancingScript(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF6B6B),
            ),
            displaySmall: GoogleFonts.dancingScript(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFF6B6B),
            ),
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Color(0xFF444444),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFFB6C1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
            ),
            labelStyle: const TextStyle(color: Color(0xFFFF6B6B)),
            hintStyle: TextStyle(color: Colors.grey.shade500),
          ),

          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
            shadowColor: const Color(0xFFFF6B6B).withOpacity(0.2),
          ),

          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFF6B6B),
            foregroundColor: Colors.white,
          ),

          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            modalBackgroundColor: Colors.white.withOpacity(0.95),
          ),

          listTileTheme: ListTileThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Colors.white,
            textColor: Color(0xFF333333),
            iconColor: Color(0xFFFF6B6B),
          ),
        ),
        home: const TimelineScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
