import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:juego/game/maze_game.dart';
import 'package:juego/models/maze_level.dart';

void main() {
  test('the player collects the key and wins at the exit', () {
    final original = mazeLevels.first;
    final level = MazeLevel(
      number: original.number,
      name: original.name,
      description: original.description,
      timeLimitSeconds: original.timeLimitSeconds,
      enemyCount: 0,
      enemyMoveInterval: original.enemyMoveInterval,
      cellCount: 5,
      seed: 27,
    );
    final game = MazeGame(level: level, onChanged: (_) {});
    final start = _find(level.rows, 'S');
    final key = _find(level.rows, 'K');
    final exit = _find(level.rows, 'E');

    _followPath(game, level.rows, _path(level.rows, start, key));
    expect(game.snapshot.hasKey, isTrue);
    expect(game.snapshot.status, MazeGameStatus.playing);

    _followPath(game, level.rows, _path(level.rows, key, exit));
    expect(game.snapshot.status, MazeGameStatus.won);
  });

  test('the player can shoot and eliminate an enemy', () {
    final level = mazeLevels.first;
    final game = MazeGame(level: level, onChanged: (_) {});
    final start = _find(level.rows, 'S');
    final enemy = _find(level.rows, 'M');
    List<_Point>? approachPath;
    _Point? firingPosition;

    for (final direction in const <_Point>[
      _Point(-1, 0),
      _Point(1, 0),
      _Point(0, -1),
      _Point(0, 1),
    ]) {
      final candidate = _Point(
        enemy.row - direction.row,
        enemy.column - direction.column,
      );
      if (candidate.row < 0 ||
          candidate.row >= level.rows.length ||
          candidate.column < 0 ||
          candidate.column >= level.rows[candidate.row].length ||
          level.rows[candidate.row][candidate.column] == '#') {
        continue;
      }
      try {
        approachPath = _path(level.rows, start, candidate, avoidEnemies: true);
        firingPosition = candidate;
        break;
      } on StateError {
        continue;
      }
    }

    expect(approachPath, isNotNull);
    expect(firingPosition, isNotNull);
    _followPath(game, level.rows, approachPath!);
    final rowDelta = enemy.row - firingPosition!.row;
    final columnDelta = enemy.column - firingPosition.column;

    game.shoot(rowDelta: rowDelta, columnDelta: columnDelta);
    for (var frame = 0; frame < 8; frame++) {
      game.update(0.016);
    }

    expect(game.snapshot.remainingEnemies, level.enemyCount - 1);
    expect(game.snapshot.status, MazeGameStatus.playing);
  });

  test('contact with an enemy ends the level', () {
    final level = mazeLevels.first;
    final game = MazeGame(level: level, onChanged: (_) {});
    final start = _find(level.rows, 'S');
    final enemy = _find(level.rows, 'M');
    List<_Point>? approachPath;
    _Point? firingPosition;

    for (final direction in const <_Point>[
      _Point(-1, 0),
      _Point(1, 0),
      _Point(0, -1),
      _Point(0, 1),
    ]) {
      final candidate = _Point(
        enemy.row - direction.row,
        enemy.column - direction.column,
      );
      if (candidate.row < 0 ||
          candidate.row >= level.rows.length ||
          candidate.column < 0 ||
          candidate.column >= level.rows[candidate.row].length ||
          level.rows[candidate.row][candidate.column] == '#') {
        continue;
      }
      try {
        approachPath = _path(level.rows, start, candidate, avoidEnemies: true);
        firingPosition = candidate;
        break;
      } on StateError {
        continue;
      }
    }

    expect(approachPath, isNotNull);
    _followPath(game, level.rows, approachPath!);
    final rowDelta = enemy.row - firingPosition!.row;
    final columnDelta = enemy.column - firingPosition.column;

    game.move(rowDelta, columnDelta);

    expect(game.snapshot.status, MazeGameStatus.lost);
    expect(game.snapshot.message, contains('atrapó'));
  });

  test('a wall blocks movement', () {
    final level = mazeLevels.first;
    var changeCount = 0;
    final game = MazeGame(level: level, onChanged: (_) => changeCount++);
    final start = _find(level.rows, 'S');
    const directions = <_Point>[
      _Point(-1, 0),
      _Point(1, 0),
      _Point(0, -1),
      _Point(0, 1),
    ];
    final wallDirection = directions.firstWhere((direction) {
      final row = start.row + direction.row;
      final column = start.column + direction.column;
      return level.rows[row][column] == '#';
    });

    game.move(wallDirection.row, wallDirection.column);

    expect(changeCount, 0);
    expect(game.snapshot.status, MazeGameStatus.playing);
  });

  test('a wall blocks shots', () {
    final level = mazeLevels.first;
    final game = MazeGame(level: level, onChanged: (_) {});
    final start = _find(level.rows, 'S');
    final wallDirection =
        const <_Point>[
          _Point(-1, 0),
          _Point(1, 0),
          _Point(0, -1),
          _Point(0, 1),
        ].firstWhere((direction) {
          return level.rows[start.row + direction.row][start.column +
                  direction.column] ==
              '#';
        });

    game.shoot(rowDelta: wallDirection.row, columnDelta: wallDirection.column);
    for (var frame = 0; frame < 8; frame++) {
      game.update(0.016);
    }

    expect(game.snapshot.remainingEnemies, level.enemyCount);
  });
}

void _followPath(MazeGame game, List<String> rows, List<_Point> path) {
  for (var index = 1; index < path.length; index++) {
    final previous = path[index - 1];
    final current = path[index];
    final rowDelta = current.row - previous.row;
    final columnDelta = current.column - previous.column;
    if (rows[current.row][current.column] == 'M') {
      game.shoot(rowDelta: rowDelta, columnDelta: columnDelta);
      game.move(rowDelta, columnDelta);
    } else {
      game.move(rowDelta, columnDelta);
    }
    game.update(.11);
  }
}

List<_Point> _path(
  List<String> rows,
  _Point start,
  _Point target, {
  bool avoidEnemies = false,
}) {
  final queue = Queue<_Point>()..add(start);
  final previous = <_Point, _Point?>{start: null};
  const directions = <_Point>[
    _Point(-1, 0),
    _Point(1, 0),
    _Point(0, -1),
    _Point(0, 1),
  ];

  while (queue.isNotEmpty && !previous.containsKey(target)) {
    final current = queue.removeFirst();
    for (final direction in directions) {
      final next = _Point(
        current.row + direction.row,
        current.column + direction.column,
      );
      if (next.row >= 0 &&
          next.row < rows.length &&
          next.column >= 0 &&
          next.column < rows[next.row].length &&
          rows[next.row][next.column] != '#' &&
          (!avoidEnemies || rows[next.row][next.column] != 'M') &&
          (rows[next.row][next.column] != 'E' || next == target) &&
          !previous.containsKey(next)) {
        previous[next] = current;
        queue.add(next);
      }
    }
  }

  if (!previous.containsKey(target)) {
    throw StateError('No path found from start to target');
  }
  final result = <_Point>[];
  _Point? current = target;
  while (current != null) {
    result.add(current);
    current = previous[current];
  }
  return result.reversed.toList();
}

_Point _find(List<String> rows, String marker) {
  for (var row = 0; row < rows.length; row++) {
    final column = rows[row].indexOf(marker);
    if (column >= 0) {
      return _Point(row, column);
    }
  }
  throw StateError('Maze is missing marker $marker');
}

class _Point {
  const _Point(this.row, this.column);

  final int row;
  final int column;

  @override
  bool operator ==(Object other) =>
      other is _Point && other.row == row && other.column == column;

  @override
  int get hashCode => Object.hash(row, column);
}
