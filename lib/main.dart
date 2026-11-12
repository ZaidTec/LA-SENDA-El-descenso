import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/menu_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
  runApp(const LaberintoApp());
}

class LaberintoApp extends StatelessWidget {
  const LaberintoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const torchGold = Color(0xFFFFB94A);
    const caveBlack = Color(0xFF0B0D0E);
    const stoneSurface = Color(0xFF211F1B);
    const wood = Color(0xFF593A27);
    const parchment = Color(0xFFF0D7A0);
    return MaterialApp(
      title: 'LA SENDA: El descenso',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: caveBlack,
        fontFamily: 'monospace',
        colorScheme: ColorScheme.fromSeed(
          seedColor: torchGold,
          brightness: Brightness.dark,
          primary: torchGold,
          secondary: const Color(0xFFC47735),
          surface: stoneSurface,
          onSurface: parchment,
          error: const Color(0xFFD65A42),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: caveBlack,
          foregroundColor: parchment,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'monospace',
            color: torchGold,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        cardTheme: CardThemeData(
          color: stoneSurface,
          shadowColor: Colors.black54,
          elevation: 3,
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            side: BorderSide(color: Color(0xFF59442E), width: 1.5),
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: stoneSurface,
          titleTextStyle: TextStyle(
            fontFamily: 'monospace',
            color: torchGold,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            side: BorderSide(color: Color(0xFF80603B), width: 2),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: wood,
          contentTextStyle: TextStyle(
            fontFamily: 'monospace',
            color: parchment,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            side: BorderSide(color: Color(0xFFB77C3D)),
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: torchGold,
          thumbColor: parchment,
          inactiveTrackColor: Color(0xFF4A3A29),
          overlayColor: Color(0x33FFB94A),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                side: BorderSide(color: Color(0xFF80603B)),
              ),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: wood,
            foregroundColor: parchment,
            minimumSize: const Size.fromHeight(54),
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              side: BorderSide(color: Color(0xFFB77C3D), width: 1.5),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: parchment,
            side: const BorderSide(color: Color(0xFFB77C3D), width: 1.5),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const MenuScreen(),
    );
  }
}
