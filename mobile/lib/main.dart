import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TubelyApp());
}

class TubelyApp extends StatelessWidget {
  const TubelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tubely',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    const accent = Color(0xFFF2A93B);
    const background = Color(0xFF151316);
    const surface = Color(0xFF1E1B20);
    const textMuted = Color(0xFF9C96A3);

    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        secondary: accent,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: accent,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: textMuted),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: const Color(0xFFF5F1E8),
        displayColor: const Color(0xFFF5F1E8),
      ),
    );
  }
}
