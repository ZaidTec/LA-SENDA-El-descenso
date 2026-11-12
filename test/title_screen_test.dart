import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juego/screens/menu_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  Future<void> pumpCover(WidgetTester tester) async {
    for (var frame = 0; frame < 8; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('provided pixel-art cover opens the configured options screen', (
    tester,
  ) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    tester.view.physicalSize = const Size(966, 542);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
    await pumpCover(tester);

    final cover = tester.widget<Image>(
      find.byKey(const ValueKey('cover-image')),
    );
    expect(find.byKey(const ValueKey('cover-animation')), findsOneWidget);
    expect(
      (cover.image as AssetImage).assetName,
      'assets/images/la_senda_cover.png',
    );
    expect(find.bySemanticsLabel('JUGAR'), findsOneWidget);
    expect(find.bySemanticsLabel('OPCIONES'), findsOneWidget);
    expect(find.bySemanticsLabel('SALIR'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('cover-options')));
    await pumpCover(tester);
    expect(find.text('Opciones de expedición'), findsOneWidget);
    expect(find.text('Música'), findsOneWidget);
    expect(find.text('Joystick'), findsOneWidget);
    expect(find.text('Instrucciones'), findsOneWidget);
    expect(find.text('Créditos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('first play shows the narrative intro and skip enters camp', (
    tester,
  ) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    tester.view.physicalSize = const Size(966, 542);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
    await pumpCover(tester);
    await tester.tap(find.byKey(const ValueKey('cover-play')));
    await pumpCover(tester);

    expect(find.text('ANTES DEL DESCENSO'), findsOneWidget);
    await tester.tap(find.text('Saltar  ›'));
    await pumpCover(tester);
    expect(find.text('CAMPAMENTO BASE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
