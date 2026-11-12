import 'package:flutter/material.dart';

import 'screens/menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LaberintoApp());
}

class LaberintoApp extends StatelessWidget {
  const LaberintoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const forest = Color(0xFF17352D);
    return MaterialApp(
      title: 'LA SENDA: El descenso',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101A18),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF72A985),
          brightness: Brightness.dark,
          surface: const Color(0xFF1B2925),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101A18),
          foregroundColor: Color(0xFFF4EBD0),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: forest,
            foregroundColor: const Color(0xFFF4EBD0),
            minimumSize: const Size.fromHeight(54),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF537C62)),
            ),
          ),
        ),
      ),
      home: const MenuScreen(),
    );
  }
}
