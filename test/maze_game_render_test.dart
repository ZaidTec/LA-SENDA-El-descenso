import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juego/game/maze_game.dart';
import 'package:juego/models/maze_level.dart';

void main() {
  testWidgets('maze uses the laid out GameWidget canvas size', (tester) async {
    final game = MazeGame(level: mazeLevels.first, onChanged: (_) {});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: GameWidget(game: game),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(game.canvasSize.x, 320);
    expect(game.canvasSize.y, 320);
    expect(tester.takeException(), isNull);
  });
}
