import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

const kBackground = Color(0xFF0E0E11);
const kSurface = Color(0xFF1B1B20);
const kSurfaceRaised = Color(0xFF26262E);
const kRed = Color(0xFFE0293B);
const kOxblood = Color(0xFF7A0F1E);
const kGold = Color(0xFFE0B84A);
const kTableBlack = Color(0xFF1A1A1A);

const kFontDisplay = 'Anton';

void main() {
  runApp(const RojoNegroApp());
}

class RojoNegroApp extends StatelessWidget {
  const RojoNegroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rojo Negro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kRed,
          brightness: Brightness.dark,
          surface: kSurface,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontFamily: kFontDisplay,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.4,
            height: 1.05,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBackground,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: kFontDisplay,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.6,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
