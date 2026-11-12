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
  MazeGame({required this.level, required this.onChanged})
    : _map = level.rows.map((row) => row.split('')).toList(),
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
    final floorPaintA = Paint()..color = const Color(0xFF28372E);
    final floorPaintB = Paint()..color = const Color(0xFF303D32);
    final stonePaint = Paint()..color = const Color(0xFF465044);
    final wallPaint = Paint()
      ..shader = Gradient.linear(
        Offset.zero,
        Offset(tileWidth, tileHeight),
        const [Color(0xFF687562), Color(0xFF354339), Color(0xFF202B26)],
        const [0, .52, 1],
      );
    final wallTopPaint = Paint()..color = const Color(0xFF87917A);
    final wallShadePaint = Paint()..color = const Color(0xFF1A2520);
    final floorSeamPaint = Paint()..color = const Color(0x163D4E41);
    final ambientGlow = Paint()
      ..shader = Gradient.radial(
        Offset(
          (_visualPlayerColumn + .5) * tileWidth,
          (_visualPlayerRow + .5) * tileHeight,
        ),
        math.max(renderSize.x, renderSize.y) * .68,
        const [Color(0x465A744D), Color(0x00151C17)],
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
      canvas.drawCircle(
        center,
        math.min(tileWidth, tileHeight) * .27,
        Paint()
          ..color = const Color(0xFFE99C4D)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(
        center,
        math.min(tileWidth, tileHeight) * .13,
        Paint()..color = const Color(0xFFFFF1B5),
      );
    }
    _drawPlayer(
      canvas,
      _visualPlayerColumn * tileWidth,
      _visualPlayerRow * tileHeight,
      tileWidth,
      tileHeight,
    );
  }

  void _drawEnemy(Canvas canvas, double x, double y, double w, double h) {
    final body = Paint()..color = const Color(0xFFB74949);
    final shadow = Paint()..color = const Color(0xFF702E39);
    final eye = Paint()..color = const Color(0xFFFFE7B5);
    final pupil = Paint()..color = const Color(0xFF2A171B);
    canvas.drawOval(
      Rect.fromLTWH(x + w * .17, y + h * .78, w * .66, h * .14),
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

  void _drawPlayer(Canvas canvas, double x, double y, double w, double h) {
    final shadow = Paint()..color = const Color(0x990B100D);
    final cloak = Paint()
      ..shader = Gradient.linear(
        Offset(x, y),
        Offset(x + w, y + h),
        const [Color(0xFF779158), Color(0xFF364E3C), Color(0xFF26372E)],
        const [0, .52, 1],
      );
    final leather = Paint()..color = const Color(0xFF8A5438);
    final skin = Paint()..color = const Color(0xFFE8B98B);
    final trim = Paint()..color = const Color(0xFFD8B768);
    final ink = Paint()..color = const Color(0xFF241E19);
    canvas.drawOval(
      Rect.fromLTWH(x + w * .12, y + h * .76, w * .76, h * .18),
      shadow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + w * .18, y + h * .42, w * .64, h * .44),
        Radius.circular(w * .14),
      ),
      cloak,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + w * .62, y + h * .48, w * .2, h * .29),
        Radius.circular(w * .05),
      ),
      leather,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + w * .29, y + h * .2, w * .42, h * .38),
        Radius.circular(w * .16),
      ),
      skin,
    );
    canvas.drawOval(
      Rect.fromLTWH(x + w * .21, y + h * .09, w * .58, h * .28),
      leather,
    );
    canvas.drawOval(
      Rect.fromLTWH(x + w * .22, y + h * .08, w * .56, h * .2),
      Paint()..color = const Color(0xFF566D48),
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .22, y + h * .25, w * .56, h * .055),
      trim,
    );
    canvas.drawCircle(Offset(x + w * .43, y + h * .39), w * .025, ink);
    canvas.drawCircle(Offset(x + w * .58, y + h * .39), w * .025, ink);
    canvas.drawLine(
      Offset(x + w * .43, y + h * .67),
      Offset(x + w * .7, y + h * .67),
      Paint()
        ..color = const Color(0xFFE5D4A8)
        ..strokeWidth = math.max(1.0, w * .035)
        ..strokeCap = StrokeCap.round,
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
        ..strokeCap = StrokeCap.round,
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
        ..strokeCap = StrokeCap.round,
    );
    if (_muzzleFlash > 0) {
      canvas.drawCircle(
        Offset(
          weaponEnd.dx + _facingColumn * w * .06,
          weaponEnd.dy + _facingRow * h * .06,
        ),
        math.min(w, h) * .1,
        Paint()
          ..color = const Color(0xFFFFD16C)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  void _drawKey(Canvas canvas, double x, double y, double w, double h) {
    final gold = Paint()..color = const Color(0xFFF4C95D);
    final center = Offset(x + w * .38, y + h * .38);
    canvas.drawCircle(center, math.min(w, h) * .17, gold);
    canvas.drawCircle(
      center,
      math.min(w, h) * .075,
      Paint()..color = const Color(0xFF1A2A22),
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .43, y + h * .34, w * .4, h * .1),
      gold,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * .7, y + h * .4, w * .09, h * .2),
      gold,
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
    final frame = Paint()..color = const Color(0xFFB97743);
    final door = Paint()
      ..color = unlocked ? const Color(0xFF79AA72) : const Color(0xFF754B37);
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
  }
}
