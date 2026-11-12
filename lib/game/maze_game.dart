import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';

import '../models/maze_level.dart';

enum MazeGameStatus { playing, won, lost }

class MazeGameSnapshot {
  const MazeGameSnapshot({
    required this.remainingSeconds,
    required this.elapsedSeconds,
    required this.hasKey,
    required this.remainingEnemies,
    required this.status,
    required this.message,
  });

  final int remainingSeconds;
  final int elapsedSeconds;
  final bool hasKey;
  final int remainingEnemies;
  final MazeGameStatus status;
  final String message;
}

class _Enemy {
  _Enemy(this.row, this.column)
    : fromRow = row.toDouble(),
      fromColumn = column.toDouble();

  int row;
  int column;
  double fromRow;
  double fromColumn;
  double moveProgress = 1;
}

class _Projectile {
  _Projectile({
    required this.row,
    required this.column,
    required this.rowDirection,
    required this.columnDirection,
  });

  double row;
  double column;
  final int rowDirection;
  final int columnDirection;
}

class MazeGame extends FlameGame {
  MazeGame({
    required this.level,
    required this.onChanged,
    this.equippedItem = 'explorer',
  }) : _map = level.rows.map((row) => row.split('')).toList(),
       _random = math.Random(level.number * 97) {
    for (var row = 0; row < _map.length; row++) {
      for (var column = 0; column < _map[row].length; column++) {
        switch (_map[row][column]) {
          case 'S':
            _playerRow = row;
            _playerColumn = column;
            _playerFromRow = row.toDouble();
            _playerFromColumn = column.toDouble();
            _map[row][column] = '.';
          case 'K':
            _keyRow = row;
            _keyColumn = column;
            _map[row][column] = '.';
          case 'E':
            _exitRow = row;
            _exitColumn = column;
            _map[row][column] = '.';
          case 'M':
            _enemies.add(_Enemy(row, column));
            _map[row][column] = '.';
        }
      }
    }
    _lastNotifiedRemaining = level.timeLimitSeconds;
  }

  final MazeLevel level;
  final void Function(MazeGameSnapshot snapshot) onChanged;
  final String equippedItem;
  final List<List<String>> _map;
  final List<_Enemy> _enemies = [];
  final List<_Projectile> _projectiles = [];
  final math.Random _random;

  late int _playerRow;
  late int _playerColumn;
  late int _keyRow;
  late int _keyColumn;
  late int _exitRow;
  late int _exitColumn;
  late double _playerFromRow;
  late double _playerFromColumn;
  int _facingRow = 0;
  int _facingColumn = 1;
  bool _hasKey = false;
  double _elapsed = 0;
  double _enemyMoveElapsed = 0;
  double _shotCooldown = 0;
  double _muzzleFlash = 0;
  double _playerMoveProgress = 1;
  int _lastNotifiedRemaining = 0;
  String _message = '';
  MazeGameStatus _status = MazeGameStatus.playing;

  int get remainingSeconds =>
      math.max(0, level.timeLimitSeconds - _elapsed.floor());

  int get elapsedSeconds => math.min(level.timeLimitSeconds, _elapsed.floor());

  @override
  Color backgroundColor() => const Color(0xFF0C1512);

  @override
  void update(double dt) {
    super.update(dt);
    if (_status != MazeGameStatus.playing) {
      return;
    }
    _shotCooldown = math.max(0.0, _shotCooldown - dt);
    _muzzleFlash = math.max(0.0, _muzzleFlash - dt);
    _playerMoveProgress = math.min(1.0, _playerMoveProgress + dt / .11);
    _updateProjectiles(dt);
    for (final enemy in _enemies) {
      enemy.moveProgress = math.min(1.0, enemy.moveProgress + dt / .22);
    }
    _elapsed += dt;
    _enemyMoveElapsed += dt;
    if (_enemyMoveElapsed >= level.enemyMoveInterval) {
      _enemyMoveElapsed %= level.enemyMoveInterval;
      _moveEnemies();
    }
    final remaining = remainingSeconds;
    if (remaining <= 0) {
      _status = MazeGameStatus.lost;
      _message = 'El tiempo se ha agotado.';
      _notify();
    } else if (remaining != _lastNotifiedRemaining) {
      _lastNotifiedRemaining = remaining;
      _notify();
    }
  }

  void move(int rowDelta, int columnDelta) {
    if (_status != MazeGameStatus.playing) {
      return;
    }
    if (rowDelta != 0 || columnDelta != 0) {
      _facingRow = rowDelta;
      _facingColumn = columnDelta;
    }

    final nextRow = _playerRow + rowDelta;
    final nextColumn = _playerColumn + columnDelta;
    if (nextRow < 0 ||
        nextRow >= _map.length ||
        nextColumn < 0 ||
        nextColumn >= _map[nextRow].length ||
        _map[nextRow][nextColumn] == '#') {
      return;
    }

    if (nextRow == _exitRow && nextColumn == _exitColumn && !_hasKey) {
      _message = 'Busca la llave dorada.';
      _notify();
      return;
    }

    _playerFromRow = _visualPlayerRow;
    _playerFromColumn = _visualPlayerColumn;
    _playerMoveProgress = 0;
    _playerRow = nextRow;
    _playerColumn = nextColumn;
    _message = '';

    if (_enemies.any(
      (enemy) => enemy.row == nextRow && enemy.column == nextColumn,
    )) {
      _status = MazeGameStatus.lost;
      _message = '¡Una criatura te atrapó!';
      _notify();
      return;
    }

    if (_playerRow == _keyRow && _playerColumn == _keyColumn) {
      _hasKey = true;
      _message = '¡Llave encontrada! Ve a la puerta.';
    }
    if (_playerRow == _exitRow && _playerColumn == _exitColumn) {
      _status = MazeGameStatus.won;
    }
    _notify();
  }

  void shoot({int? rowDelta, int? columnDelta}) {
    if (_status != MazeGameStatus.playing || _shotCooldown > 0) {
      return;
    }
    if (rowDelta != null && columnDelta != null) {
      _facingRow = rowDelta;
      _facingColumn = columnDelta;
    }
    _shotCooldown = .2;
    _muzzleFlash = .08;
    _projectiles.add(
      _Projectile(
        row: _visualPlayerRow + _facingRow * .32,
        column: _visualPlayerColumn + _facingColumn * .32,
        rowDirection: _facingRow,
        columnDirection: _facingColumn,
      ),
    );
    _message = '';
  }

  void _updateProjectiles(double dt) {
    for (var index = _projectiles.length - 1; index >= 0; index--) {
      final projectile = _projectiles[index];
      projectile
        ..row += projectile.rowDirection * dt * 13
        ..column += projectile.columnDirection * dt * 13;

      final row = projectile.row.floor();
      final column = projectile.column.floor();
      if (row < 0 ||
          row >= _map.length ||
          column < 0 ||
          column >= _map[row].length ||
          _map[row][column] == '#') {
        _projectiles.removeAt(index);
        continue;
      }

      final enemyIndex = _enemies.indexWhere(
        (enemy) => enemy.row == row && enemy.column == column,
      );
      if (enemyIndex >= 0) {
        _enemies.removeAt(enemyIndex);
        _projectiles.removeAt(index);
        _message = '¡Criatura eliminada!';
        _notify();
        continue;
      }

      if (row == _exitRow && column == _exitColumn) {
        _projectiles.removeAt(index);
      }
    }
  }

  double get _visualPlayerRow =>
      _playerFromRow +
      (_playerRow - _playerFromRow) * _ease(_playerMoveProgress);

  double get _visualPlayerColumn =>
      _playerFromColumn +
      (_playerColumn - _playerFromColumn) * _ease(_playerMoveProgress);

  double _ease(double progress) {
    final value = progress.clamp(0.0, 1.0);
    return value * value * (3 - 2 * value);
  }

  void _moveEnemies() {
    for (final enemy in _enemies) {
      final options =
          <math.Point<int>>[
            math.Point(enemy.row - 1, enemy.column),
            math.Point(enemy.row + 1, enemy.column),
            math.Point(enemy.row, enemy.column - 1),
            math.Point(enemy.row, enemy.column + 1),
          ].where((point) {
            return point.x >= 0 &&
                point.x < _map.length &&
                point.y >= 0 &&
                point.y < _map[point.x].length &&
                _map[point.x][point.y] != '#' &&
                !(point.x == _exitRow && point.y == _exitColumn) &&
                !_enemies.any(
                  (other) =>
                      !identical(other, enemy) &&
                      other.row == point.x &&
                      other.column == point.y,
                );
          }).toList();

      if (options.isEmpty) {
        continue;
      }
      options.shuffle(_random);
      var bestDistance = _distanceToPlayer(options.first);
      var destination = options.first;
      for (final option in options.skip(1)) {
        final distance = _distanceToPlayer(option);
        if (distance < bestDistance) {
          bestDistance = distance;
          destination = option;
        }
      }
      enemy
        ..fromRow = enemy.row.toDouble()
        ..fromColumn = enemy.column.toDouble()
        ..row = destination.x
        ..column = destination.y
        ..moveProgress = 0;
      if (enemy.row == _playerRow && enemy.column == _playerColumn) {
        _status = MazeGameStatus.lost;
        _message = '¡Una criatura te atrapó!';
        _notify();
        return;
      }
    }
    _notify();
  }

  int _distanceToPlayer(math.Point<int> start) {
    final queue = <(math.Point<int>, int)>[(start, 0)];
    final visited = <math.Point<int>>{start};
    for (var index = 0; index < queue.length; index++) {
      final (point, distance) = queue[index];
      if (point.x == _playerRow && point.y == _playerColumn) {
        return distance;
      }
      for (final next in <math.Point<int>>[
        math.Point(point.x - 1, point.y),
        math.Point(point.x + 1, point.y),
        math.Point(point.x, point.y - 1),
        math.Point(point.x, point.y + 1),
      ]) {
        if (next.x >= 0 &&
            next.x < _map.length &&
            next.y >= 0 &&
            next.y < _map[next.x].length &&
            _map[next.x][next.y] != '#' &&
            visited.add(next)) {
          queue.add((next, distance + 1));
        }
      }
    }
    return _map.length * _map.first.length;
  }

  MazeGameSnapshot get snapshot => MazeGameSnapshot(
    remainingSeconds: remainingSeconds,
    elapsedSeconds: elapsedSeconds,
    hasKey: _hasKey,
    remainingEnemies: _enemies.length,
    status: _status,
    message: _message,
  );

  void _notify() => onChanged(snapshot);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // This custom drawing is outside the camera viewport transform, so it
    // must use the actual GameWidget canvas rather than FlameGame's virtual
    // world size.
    final renderSize = canvasSize;
    if (renderSize.x <= 0 || renderSize.y <= 0) {
      return;
    }

    final tileWidth = renderSize.x / _map.first.length;
    final tileHeight = renderSize.y / _map.length;
    final floorPaintA = Paint()..color = const Color(0xFF38342C);
    final floorPaintB = Paint()..color = const Color(0xFF302E29);
    final stonePaint = Paint()..color = const Color(0xFF65533A);
    final wallPaint = Paint()
      ..shader = Gradient.linear(
        Offset.zero,
        Offset(tileWidth, tileHeight),
        const [Color(0xFF675C48), Color(0xFF393A35), Color(0xFF202426)],
        const [0, .52, 1],
      );
    final wallTopPaint = Paint()..color = const Color(0xFF817052);
    final wallShadePaint = Paint()..color = const Color(0xFF171A1B);
    final wallEdgePaint = Paint()..color = const Color(0xFF4A4437);
    final floorSeamPaint = Paint()..color = const Color(0x303C3327);
    final ambientGlow = Paint()
      ..shader = Gradient.radial(
        Offset(
          (_visualPlayerColumn + .5) * tileWidth,
          (_visualPlayerRow + .5) * tileHeight,
        ),
        math.max(renderSize.x, renderSize.y) * .68,
        const [Color(0x48C47A35), Color(0x00110F0D)],
      );

    for (var row = 0; row < _map.length; row++) {
      for (var column = 0; column < _map[row].length; column++) {
        final rect = Rect.fromLTWH(
          column * tileWidth,
          row * tileHeight,
          tileWidth,
          tileHeight,
        );
        if (_map[row][column] == '#') {
          canvas.drawRect(rect, wallPaint);
          canvas.drawRect(
            Rect.fromLTWH(
              rect.left + tileWidth * .06,
              rect.top + tileHeight * .05,
              tileWidth * .88,
              tileHeight * .09,
            ),
            wallTopPaint,
          );
          canvas.drawRect(
            Rect.fromLTWH(
              rect.left + tileWidth * .91,
              rect.top + tileHeight * .1,
              tileWidth * .07,
              tileHeight * .86,
            ),
            wallShadePaint,
          );
          if ((row * 3 + column * 5).isEven) {
            canvas.drawRect(
              Rect.fromLTWH(
                rect.left + tileWidth * .12,
                rect.top + tileHeight * .42,
                tileWidth * .3,
                tileHeight * .035,
              ),
              wallEdgePaint,
            );
            canvas.drawRect(
              Rect.fromLTWH(
                rect.left + tileWidth * .47,
                rect.top + tileHeight * .42,
                tileWidth * .045,
                tileHeight * .19,
              ),
              wallEdgePaint,
            );
            canvas.drawRect(
              Rect.fromLTWH(
                rect.left + tileWidth * .23,
                rect.top + tileHeight * .78,
                tileWidth * .16,
                tileHeight * .045,
              ),
              wallTopPaint,
            );
          }
        } else {
          canvas.drawRect(
            rect,
            (row + column).isEven ? floorPaintA : floorPaintB,
          );
          canvas.drawRect(
            Rect.fromLTWH(rect.left, rect.top, tileWidth, tileHeight * .025),
            floorSeamPaint,
          );
          if ((row * 7 + column * 11) % 5 == 0) {
            canvas.drawRect(
              Rect.fromLTWH(
                rect.left + tileWidth * .2,
                rect.top + tileHeight * .69,
                tileWidth * .12,
                tileHeight * .06,
              ),
              stonePaint,
            );
          }
        }
      }
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, renderSize.x, renderSize.y),
      ambientGlow,
    );

    if (!_hasKey) {
      _drawKey(
        canvas,
        _keyColumn * tileWidth,
        _keyRow * tileHeight,
        tileWidth,
        tileHeight,
      );
    }
    _drawDoor(
      canvas,
      _exitColumn * tileWidth,
      _exitRow * tileHeight,
      tileWidth,
      tileHeight,
      _hasKey,
    );
    for (final enemy in _enemies) {
      final enemyRow =
          enemy.fromRow +
          (enemy.row - enemy.fromRow) * _ease(enemy.moveProgress);
      final enemyColumn =
          enemy.fromColumn +
          (enemy.column - enemy.fromColumn) * _ease(enemy.moveProgress);
      _drawEnemy(
        canvas,
        enemyColumn * tileWidth,
        enemyRow * tileHeight,
        tileWidth,
        tileHeight,
      );
    }
    for (final projectile in _projectiles) {
      final center = Offset(
        projectile.column * tileWidth,
        projectile.row * tileHeight,
      );
      final pixel = math.min(tileWidth, tileHeight) * .22;
      canvas
        ..drawRect(
          Rect.fromCenter(center: center, width: pixel * 2, height: pixel * 2),
          Paint()..color = const Color(0xFFE27632),
        )
        ..drawRect(
          Rect.fromCenter(center: center, width: pixel, height: pixel),
          Paint()..color = const Color(0xFFFFE59A),
        );
    }
    _drawPlayer(
      canvas,
      _visualPlayerColumn * tileWidth,
      _visualPlayerRow * tileHeight,
      tileWidth,
      tileHeight,
      equippedItem,
    );
  }

  void _drawEnemy(Canvas canvas, double x, double y, double w, double h) {
    final body = Paint()..color = const Color(0xFFB74949);
    final shadow = Paint()..color = const Color(0xFF702E39);
    final eye = Paint()..color = const Color(0xFFFFE7B5);
    final pupil = Paint()..color = const Color(0xFF2A171B);
    canvas.drawRect(
      Rect.fromLTWH(x + w * .2, y + h * .8, w * .6, h * .1),
      Paint()..color = const Color(0x770D100D),
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .18, y + h * .38, w * .64, h * .48),
      shadow,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .24, y + h * .26, w * .52, h * .48),
      body,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .27, y + h * .17, w * .16, h * .18),
      shadow,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .57, y + h * .17, w * .16, h * .18),
      shadow,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .34, y + h * .39, w * .12, h * .12),
      eye,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .54, y + h * .39, w * .12, h * .12),
      eye,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .38, y + h * .42, w * .06, h * .06),
      pupil,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .58, y + h * .42, w * .06, h * .06),
      pupil,
    );
  }

  void _drawPlayer(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    String equippedItem,
  ) {
    final shadow = Paint()..color = const Color(0x990B100D);
    final cloakColors = switch (equippedItem) {
      'torch' => const [
        Color(0xFFB36B36),
        Color(0xFF76402E),
        Color(0xFF4A2D25),
      ],
      'armor' => const [
        Color(0xFF9A9B91),
        Color(0xFF626962),
        Color(0xFF414A46),
      ],
      'relic' => const [
        Color(0xFFD8B768),
        Color(0xFF9A753B),
        Color(0xFF55452B),
      ],
      _ => const [Color(0xFF779158), Color(0xFF364E3C), Color(0xFF26372E)],
    };
    final headgearColor = switch (equippedItem) {
      'torch' => const Color(0xFFE58A3F),
      'armor' => const Color(0xFF9A9B91),
      'relic' => const Color(0xFFF0D27A),
      _ => const Color(0xFF566D48),
    };
    final cloak = Paint()..color = cloakColors.first;
    final leather = Paint()..color = const Color(0xFF8A5438);
    final skin = Paint()..color = const Color(0xFFE8B98B);
    final trim = Paint()..color = const Color(0xFFD8B768);
    final ink = Paint()..color = const Color(0xFF241E19);
    canvas.drawRect(
      Rect.fromLTWH(x + w * .12, y + h * .78, w * .76, h * .14),
      shadow,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .21, y + h * .45, w * .58, h * .38),
      cloak,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .62, y + h * .5, w * .19, h * .28),
      leather,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .28, y + h * .2, w * .44, h * .35),
      skin,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .2, y + h * .12, w * .6, h * .18),
      leather,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .24, y + h * .08, w * .52, h * .15),
      Paint()..color = headgearColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .22, y + h * .25, w * .56, h * .06),
      trim,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .4, y + h * .38, w * .06, h * .06),
      ink,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .57, y + h * .38, w * .06, h * .06),
      ink,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .27, y + h * .79, w * .23, h * .1),
      Paint()..color = const Color(0xFF211C18),
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .52, y + h * .79, w * .24, h * .1),
      Paint()..color = const Color(0xFF211C18),
    );
    final weaponStart = Offset(x + w * .53, y + h * .58);
    final weaponEnd = Offset(
      weaponStart.dx + _facingColumn * w * .34,
      weaponStart.dy + _facingRow * h * .34,
    );
    canvas.drawLine(
      weaponStart,
      weaponEnd,
      Paint()
        ..color = const Color(0xFF392B20)
        ..strokeWidth = math.max(2.0, w * .1)
        ..strokeCap = StrokeCap.square,
    );
    canvas.drawLine(
      Offset(
        weaponStart.dx + _facingColumn * w * .08,
        weaponStart.dy + _facingRow * h * .08,
      ),
      weaponEnd,
      Paint()
        ..color = const Color(0xFFD4B16A)
        ..strokeWidth = math.max(1.0, w * .035)
        ..strokeCap = StrokeCap.square,
    );
    if (_muzzleFlash > 0) {
      final flashCenter = Offset(
        weaponEnd.dx + _facingColumn * w * .06,
        weaponEnd.dy + _facingRow * h * .06,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: flashCenter,
          width: math.min(w, h) * .2,
          height: math.min(w, h) * .2,
        ),
        Paint()..color = const Color(0xFFFFD16C),
      );
    }
  }

  void _drawKey(Canvas canvas, double x, double y, double w, double h) {
    final gold = Paint()..color = const Color(0xFFF4C95D);
    final darkGold = Paint()..color = const Color(0xFF8F5A27);
    final centerX = x + w * .37;
    final centerY = y + h * .38;
    final unit = math.min(w, h) * .075;
    canvas
      ..drawRect(
        Rect.fromLTWH(
          centerX - unit * 2,
          centerY - unit * 2,
          unit * 4,
          unit * 4,
        ),
        darkGold,
      )
      ..drawRect(
        Rect.fromLTWH(centerX - unit, centerY - unit, unit * 2, unit * 2),
        Paint()..color = const Color(0xFF30271D),
      )
      ..drawRect(
        Rect.fromLTWH(centerX - unit, centerY - unit * 2, unit * 2, unit),
        gold,
      )
      ..drawRect(
        Rect.fromLTWH(centerX - unit * 2, centerY - unit, unit, unit * 2),
        gold,
      )
      ..drawRect(Rect.fromLTWH(centerX, centerY + unit, unit, unit), gold)
      ..drawRect(
        Rect.fromLTWH(centerX + unit, centerY + unit * 1.5, unit, unit),
        gold,
      );
    canvas.drawRect(
      Rect.fromLTWH(centerX + unit * 2, centerY - unit * .5, w * .4, unit),
      gold,
    );
    canvas.drawRect(Rect.fromLTWH(x + w * .7, centerY, w * .09, h * .18), gold);
    canvas.drawRect(
      Rect.fromLTWH(x + w * .46, centerY + h * .09, w * .09, h * .06),
      darkGold,
    );
  }

  void _drawDoor(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    bool unlocked,
  ) {
    final frame = Paint()..color = const Color(0xFF8A5A36);
    final door = Paint()
      ..color = unlocked ? const Color(0xFF738047) : const Color(0xFF523523);
    canvas.drawRect(
      Rect.fromLTWH(x + w * .16, y + h * .12, w * .68, h * .78),
      frame,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .27, y + h * .22, w * .46, h * .68),
      door,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .59, y + h * .54, w * .07, h * .08),
      Paint()..color = const Color(0xFFF4C95D),
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .2, y + h * .14, w * .6, h * .06),
      Paint()..color = const Color(0xFFC28B4D),
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .32, y + h * .28, w * .05, h * .54),
      Paint()..color = const Color(0xFF30251D),
    );
  }
}
