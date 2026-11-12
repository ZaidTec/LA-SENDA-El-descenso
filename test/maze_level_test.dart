import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:juego/models/maze_level.dart';

void main() {
  test('all six mazes connect the start, key, and exit', () {
    expect(mazeLevels, hasLength(6));

    for (final level in mazeLevels) {
      final start = _find(level.rows, 'S');
      final key = _find(level.rows, 'K');
      final exit = _find(level.rows, 'E');
      final reachable = _reachableTiles(level.rows, start);

      expect(level.rows.length, level.rows.first.length);
      expect(reachable, contains(key));
      expect(reachable, contains(exit));
      expect(
        level.rows.expand((row) => row.split('')).where((tile) => tile == 'M'),
        hasLength(level.enemyCount),
      );
    }

    for (var index = 1; index < mazeLevels.length; index++) {
      expect(
        mazeLevels[index].rowCount,
        greaterThan(mazeLevels[index - 1].rowCount),
      );
      expect(
        mazeLevels[index].enemyCount,
        greaterThanOrEqualTo(mazeLevels[index - 1].enemyCount),
      );
      expect(
        mazeLevels[index].enemyMoveInterval,
        lessThan(mazeLevels[index - 1].enemyMoveInterval),
      );
    }
  });
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

Set<_Point> _reachableTiles(List<String> rows, _Point start) {
  final visited = <_Point>{start};
  final queue = Queue<_Point>()..add(start);
  const directions = <_Point>[
    _Point(-1, 0),
    _Point(1, 0),
    _Point(0, -1),
    _Point(0, 1),
  ];

  while (queue.isNotEmpty) {
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
          visited.add(next)) {
        queue.add(next);
      }
    }
  }
  return visited;
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
