import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juego/game/levels/level_manager.dart';
import 'package:juego/screens/main_menu_screen.dart';
import 'package:juego/screens/result_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  testWidgets('landscape result keeps the menu action visible and reachable', (
    tester,
  ) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    tester.view.physicalSize = const Size(900, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ResultScreen(
          level: mazeLevels.first,
          won: true,
          elapsedSeconds: 75,
          rewardCoins: 20,
        ),
      ),
    );

    final menuButton = find.text('VOLVER AL MENÚ');
    expect(menuButton, findsOneWidget);
    expect(tester.getRect(menuButton).bottom, lessThanOrEqualTo(420));
    expect(tester.takeException(), isNull);

    await tester.tap(menuButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MainMenuScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
