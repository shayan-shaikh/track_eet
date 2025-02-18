import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MediaTrackerApp());
}

class MediaTrackerApp extends StatelessWidget {
  const MediaTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}