import 'dart:math';

class MazeLevel {
  MazeLevel({
    required this.number,
    required this.name,
    required this.description,
    required this.timeLimitSeconds,
    required this.enemyCount,
    required this.enemyMoveInterval,
    required int cellCount,
    required int seed,
  }) : rows = _generateMaze(cellCount, seed, enemyCount);

  final int number;
  final String name;
  final String description;
  final int timeLimitSeconds;
  final int enemyCount;
  final double enemyMoveInterval;
  final List<String> rows;

  int get rowCount => rows.length;
  int get columnCount => rows.first.length;

  static List<String> _generateMaze(int cellCount, int seed, int enemyCount) {
    final size = cellCount * 2 + 1;
    final grid = List.generate(size, (_) => List.filled(size, '#'));
    final visited = List.generate(
      cellCount,
      (_) => List.filled(cellCount, false),
    );
    final random = Random(seed);
    final stack = <Point<int>>[const Point(0, 0)];
    visited[0][0] = true;
    grid[1][1] = '.';

    while (stack.isNotEmpty) {
      final current = stack.last;
      final neighbors = <Point<int>>[
        Point(current.x - 1, current.y),
        Point(current.x + 1, current.y),
        Point(current.x, current.y - 1),
        Point(current.x, current.y + 1),
      ]..shuffle(random);

      Point<int>? next;
      for (final candidate in neighbors) {
        if (candidate.x >= 0 &&
            candidate.x < cellCount &&
            candidate.y >= 0 &&
            candidate.y < cellCount &&
            !visited[candidate.x][candidate.y]) {
          next = candidate;
          break;
        }
      }

      if (next == null) {
        stack.removeLast();
        continue;
      }

      final currentRow = current.x * 2 + 1;
      final currentColumn = current.y * 2 + 1;
      final nextRow = next.x * 2 + 1;
      final nextColumn = next.y * 2 + 1;
      grid[(currentRow + nextRow) ~/ 2][(currentColumn + nextColumn) ~/ 2] =
          '.';
      grid[nextRow][nextColumn] = '.';
      visited[next.x][next.y] = true;
      stack.add(next);
    }

    const start = Point<int>(1, 1);
    final exit = Point<int>(size - 2, size - 2);
    grid[start.x][start.y] = 'S';
    grid[exit.x][exit.y] = 'E';

    final queue = <Point<int>>[start];
    final distances = <Point<int>, int>{start: 0};
    var key = start;
    for (var index = 0; index < queue.length; index++) {
      final current = queue[index];
      if (distances[current]! > distances[key]!) {
        key = current;
      }
      for (final next in <Point<int>>[
        Point(current.x - 1, current.y),
        Point(current.x + 1, current.y),
        Point(current.x, current.y - 1),
        Point(current.x, current.y + 1),
      ]) {
        if (next.x >= 0 &&
            next.x < size &&
            next.y >= 0 &&
            next.y < size &&
            grid[next.x][next.y] != '#' &&
            next != exit &&
            !distances.containsKey(next)) {
          distances[next] = distances[current]! + 1;
          queue.add(next);
        }
      }
    }
    grid[key.x][key.y] = 'K';

    final openTiles =
        distances.entries
            .where(
              (entry) =>
                  entry.key != start && entry.key != key && entry.key != exit,
            )
            .toList()
          ..sort((first, second) => first.value.compareTo(second.value));
    final selectedEnemies = <Point<int>>[];
    for (var index = 0; index < enemyCount; index++) {
      final targetDistance =
          distances.values.reduce(
            (first, second) => first > second ? first : second,
          ) *
          (index + 1) /
          (enemyCount + 1);
      Point<int>? selected;
      var selectedDifference = double.infinity;
      for (final entry in openTiles) {
        if (selectedEnemies.contains(entry.key)) {
          continue;
        }
        final difference = (entry.value - targetDistance).abs();
        if (difference < selectedDifference) {
          selected = entry.key;
          selectedDifference = difference;
        }
      }
      if (selected != null) {
        selectedEnemies.add(selected);
        grid[selected.x][selected.y] = 'M';
      }
    }
    return grid.map((row) => row.join()).toList(growable: false);
  }
}

final List<MazeLevel> mazeLevels = [
  MazeLevel(
    number: 1,
    name: 'El sendero olvidado',
    description: 'Un comienzo entre ruinas antiguas.',
    timeLimitSeconds: 135,
    enemyCount: 1,
    enemyMoveInterval: 1.5,
    cellCount: 5,
    seed: 27,
  ),
  MazeLevel(
    number: 2,
    name: 'El bosque susurrante',
    description: 'Caminos mas largos y giros inesperados.',
    timeLimitSeconds: 165,
    enemyCount: 1,
    enemyMoveInterval: 1.35,
    cellCount: 6,
    seed: 84,
  ),
  MazeLevel(
    number: 3,
    name: 'El pantano antiguo',
    description: 'Un laberinto mayor y dos criaturas al acecho.',
    timeLimitSeconds: 195,
    enemyCount: 2,
    enemyMoveInterval: 1.15,
    cellCount: 7,
    seed: 193,
  ),
  MazeLevel(
    number: 4,
    name: 'Las catacumbas',
    description: 'Tres enemigos patrullan pasadizos profundos.',
    timeLimitSeconds: 225,
    enemyCount: 3,
    enemyMoveInterval: 1.0,
    cellCount: 8,
    seed: 306,
  ),
  MazeLevel(
    number: 5,
    name: 'La fortaleza perdida',
    description: 'Cuatro enemigos y menos tiempo para escapar.',
    timeLimitSeconds: 250,
    enemyCount: 4,
    enemyMoveInterval: 0.85,
    cellCount: 9,
    seed: 421,
  ),
  MazeLevel(
    number: 6,
    name: 'El corazon del laberinto',
    description: 'El desafio final: cinco enemigos muy rapidos.',
    timeLimitSeconds: 270,
    enemyCount: 5,
    enemyMoveInterval: 0.7,
    cellCount: 10,
    seed: 557,
  ),
];

int get mazeLevelCount => mazeLevels.length;
