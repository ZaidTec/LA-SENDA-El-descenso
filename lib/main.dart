import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/main_menu_screen.dart';
import 'utils/constants.dart';

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
    return MaterialApp(
      title: GameConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GameColors.cave,
        fontFamily: 'monospace',
        colorScheme: ColorScheme.fromSeed(
          seedColor: GameColors.torch,
          brightness: Brightness.dark,
          primary: GameColors.torch,
          secondary: GameColors.flame,
          surface: GameColors.stone,
          onSurface: GameColors.parchment,
          error: GameColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: GameColors.cave,
          foregroundColor: GameColors.parchment,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'monospace',
            color: GameColors.torch,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        cardTheme: CardThemeData(
          color: GameColors.stone,
          shadowColor: Colors.black54,
          elevation: 3,
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            side: BorderSide(color: GameColors.stoneEdge, width: 1.5),
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: GameColors.stone,
          titleTextStyle: TextStyle(
            fontFamily: 'monospace',
            color: GameColors.torch,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            side: BorderSide(color: GameColors.woodLight, width: 2),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: GameColors.wood,
          contentTextStyle: TextStyle(
            fontFamily: 'monospace',
            color: GameColors.parchment,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            side: BorderSide(color: GameColors.woodLight),
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: GameColors.torch,
          thumbColor: GameColors.parchment,
          inactiveTrackColor: Color(0xFF4A3A29),
          overlayColor: Color(0x33FFB94A),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                side: BorderSide(color: GameColors.woodLight),
              ),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: GameColors.wood,
            foregroundColor: GameColors.parchment,
            minimumSize: const Size.fromHeight(54),
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              side: BorderSide(color: GameColors.woodLight, width: 1.5),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: GameColors.parchment,
            side: const BorderSide(color: GameColors.woodLight, width: 1.5),
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
      initialRoute: '/',
      routes: {'/': (_) => const MainMenuScreen()},
    );
  }
}
