import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  // Ensure proper system UI colors for the cyberpunk look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MediaTrackerApp());
}

class MediaTrackerApp extends StatelessWidget {
  const MediaTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackEET',
      debugShowCheckedModeBanner: false, // Remove debug banner for cleaner UI
      theme: ThemeData(
        // Set Orbitron as the default font for the entire app
        fontFamily: 'Orbitron',
        
        // Update color scheme to match cyberpunk aesthetic
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFFF), // Cyan neon
          secondary: Color(0xFFFF00FF), // Magenta neon
          background: Color(0xFF121212), // Dark background
          surface: Color(0xFF1E1E1E), // Slightly lighter dark
          error: Colors.redAccent,
        ),
        
        // Text theme with cyberpunk styling
        textTheme: const TextTheme(
          // Headlines with bold cyberpunk styling
          headlineLarge: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          // Body text with cyberpunk styling
          bodyLarge: TextStyle(
            letterSpacing: 0.8,
          ),
          bodyMedium: TextStyle(
            letterSpacing: 0.8,
          ),
        ),
        
        // Update the AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Color(0xFF00FFFF),
          elevation: 8.0,
          centerTitle: true,
        ),
        
        // Card theme for a cyberpunk look
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Color(0xFF00FFFF), width: 1.0),
          ),
        ),
        
        // Divider theme
        dividerTheme: const DividerThemeData(
          color: Color(0xFF00FFFF),
          thickness: 1,
          space: 20,
        ),
        
        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FFFF),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 5,
          ),
        ),
        
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF00FFFF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF00FFFF), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFFFF00FF), width: 2.0),
          ),
          labelStyle: const TextStyle(color: Color(0xFF00FFFF)),
          hintStyle: TextStyle(color: const Color(0xFF00FFFF).withOpacity(0.5)),
        ),
        
        // Slider theme for rating
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFF00FFFF),
          inactiveTrackColor: const Color(0xFF00FFFF).withOpacity(0.2),
          thumbColor: const Color(0xFFFF00FF),
          overlayColor: const Color(0x2900FFFF),
          valueIndicatorColor: const Color(0xFF1E1E1E),
          valueIndicatorTextStyle: const TextStyle(
            color: Color(0xFF00FFFF),
            fontWeight: FontWeight.bold,
          ),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
        ),
        
        // Dialog theme
        dialogTheme: DialogTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Color(0xFF00FFFF), width: 1.0),
          ),
          titleTextStyle: const TextStyle(
            color: Color(0xFF00FFFF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 0.8,
          ),
        ),
        
        // Bottom sheet theme
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
        
        // Tooltip theme
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF00FFFF), width: 1),
          ),
          textStyle: const TextStyle(
            color: Color(0xFF00FFFF),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}