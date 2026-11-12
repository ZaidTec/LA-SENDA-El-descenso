import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juego/models/maze_level.dart';
import 'package:juego/screens/game_screen.dart';

void main() {
  testWidgets('game layout fits a landscape phone screen', (tester) async {
    tester.view.physicalSize = const Size(900, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: GameScreen(level: mazeLevels.first)),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('maze-game')), findsOneWidget);
    expect(find.text('Muévete, apunta y dispara'), findsOneWidget);
    expect(find.bySemanticsLabel('Mover arriba'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('joystick preference shows the joystick control', (tester) async {
    tester.view.physicalSize = const Size(900, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(level: mazeLevels.first, controlMode: 'joystick'),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('joystick-control')), findsOneWidget);
    expect(find.bySemanticsLabel('Mover arriba'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pause menu offers resume, restart and camp', (tester) async {
    tester.view.physicalSize = const Size(900, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: GameScreen(level: mazeLevels.first)),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Pausar expedición'));
    await tester.pumpAndSettle();

    expect(find.text('Expedición en pausa'), findsOneWidget);
    expect(find.text('CONTINUAR'), findsOneWidget);
    expect(find.text('REINICIAR'), findsOneWidget);
    expect(find.text('CAMPAMENTO'), findsOneWidget);
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
    expect(find.text('Expedición en pausa'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
