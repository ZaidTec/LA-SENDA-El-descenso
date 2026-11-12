import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/maze_game.dart';
import '../models/maze_level.dart';
import '../services/progress_service.dart';
import '../widgets/direction_button.dart';
import 'camp_screen.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.level,
    this.controlMode = 'dpad',
    this.equippedItem = 'explorer',
    super.key,
  });

  final MazeLevel level;
  final String controlMode;
  final String equippedItem;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final MazeGame _game;
  late MazeGameSnapshot _snapshot;
  bool _resultOpened = false;

  @override
  void initState() {
    super.initState();
    _snapshot = MazeGameSnapshot(
      remainingSeconds: widget.level.timeLimitSeconds,
      elapsedSeconds: 0,
      hasKey: false,
      remainingEnemies: widget.level.enemyCount,
      status: MazeGameStatus.playing,
      message: '',
    );
    _game = MazeGame(
      level: widget.level,
      equippedItem: widget.equippedItem,
      onChanged: _handleGameChanged,
    );
  }

  void _handleGameChanged(MazeGameSnapshot snapshot) {
    if (!mounted) {
      return;
    }
    setState(() => _snapshot = snapshot);
    if (snapshot.status != MazeGameStatus.playing && !_resultOpened) {
      _resultOpened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_openResult(snapshot));
        }
      });
    }
  }

  Future<void> _openResult(MazeGameSnapshot snapshot) async {
    String? saveError;
    var rewardCoins = 0;
    if (snapshot.status == MazeGameStatus.won) {
      try {
        rewardCoins = await ProgressService.completeLevel(
          level: widget.level.number,
          elapsedSeconds: snapshot.elapsedSeconds,
        );
      } on Object catch (error) {
        saveError = error.toString();
      }
    }
    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          level: widget.level,
          won: snapshot.status == MazeGameStatus.won,
          elapsedSeconds: snapshot.elapsedSeconds,
          lostReason: snapshot.message,
          saveError: saveError,
          rewardCoins: rewardCoins,
          controlMode: widget.controlMode,
          equippedItem: widget.equippedItem,
        ),
      ),
    );
  }

  void _restart() {
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(
          level: widget.level,
          controlMode: widget.controlMode,
          equippedItem: widget.equippedItem,
        ),
      ),
    );
  }

  Future<void> _showPauseMenu() async {
    _game.pauseEngine();
    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF211F1B),
        title: const Text('Expedición en pausa'),
        content: const Text('El tiempo y los enemigos están detenidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('continue'),
            child: const Text('CONTINUAR'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('restart'),
            child: const Text('REINICIAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop('camp'),
            child: const Text('CAMPAMENTO'),
          ),
        ],
      ),
    );
    if (!mounted) {
      return;
    }
    if (action == 'restart') {
      _restart();
    } else if (action == 'camp') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const CampScreen()),
        (_) => false,
      );
    } else {
      _game.resumeEngine();
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = Duration(seconds: _snapshot.remainingSeconds);
    final clock =
        '${time.inMinutes.toString().padLeft(2, '0')}:'
        '${(time.inSeconds % 60).toString().padLeft(2, '0')}';
    final urgent = _snapshot.remainingSeconds <= 20;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > constraints.maxHeight) {
              return _buildLandscapeLayout(clock, urgent);
            }
            return _buildPortraitLayout(clock, urgent);
          },
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(String clock, bool urgent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: Center(child: _buildMaze())),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        compact: true,
                        icon: Icons.timer_outlined,
                        label: 'TIEMPO',
                        value: clock,
                        valueColor: urgent
                            ? const Color(0xFFFF8273)
                            : const Color(0xFFF4EBD0),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _InfoCard(
                        compact: true,
                        icon: _snapshot.hasKey ? Icons.key : Icons.key_off,
                        label: 'LLAVE',
                        value: _snapshot.hasKey ? 'Lista' : 'Pendiente',
                        valueColor: _snapshot.hasKey
                            ? const Color(0xFFFFB94A)
                            : const Color(0xFFCBCBC1),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _InfoCard(
                        compact: true,
                        icon: Icons.pest_control,
                        label: 'ENEMIGOS',
                        value: '${_snapshot.remainingEnemies}',
                        valueColor: const Color(0xFFFF8273),
                      ),
                    ),
                  ],
                ),
                if (_snapshot.message.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _snapshot.message,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFB94A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  'Muévete, apunta y dispara',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: const Color(0xFFB7A98C)),
                ),
                const SizedBox(height: 8),
                _buildControls(),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(String clock, bool urgent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.timer_outlined,
                  label: 'TIEMPO',
                  value: clock,
                  valueColor: urgent
                      ? const Color(0xFFFF8273)
                      : const Color(0xFFF4EBD0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoCard(
                  icon: _snapshot.hasKey ? Icons.key : Icons.key_off,
                  label: 'LLAVE',
                  value: _snapshot.hasKey ? 'Encontrada' : 'Pendiente',
                  valueColor: _snapshot.hasKey
                      ? const Color(0xFFFFB94A)
                      : const Color(0xFFCBCBC1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoCard(
                  icon: Icons.pest_control,
                  label: 'ENEMIGOS',
                  value: '${_snapshot.remainingEnemies}',
                  valueColor: const Color(0xFFFF8273),
                ),
              ),
            ],
          ),
          if (_snapshot.message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _snapshot.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFB94A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Expanded(child: Center(child: _buildMaze())),
          const SizedBox(height: 10),
          Text(
            'Muévete, apunta en la dirección y pulsa disparar',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: const Color(0xFFB7A98C)),
          ),
          const SizedBox(height: 8),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: _showPauseMenu,
          tooltip: 'Pausar expedición',
          icon: const Icon(Icons.pause),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NIVEL ${widget.level.number}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFB7A98C),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                widget.level.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _restart,
          tooltip: 'Reiniciar nivel',
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildMaze() {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF171514),
            border: Border.all(color: const Color(0xFF9A6937), width: 3),
          ),
          child: GameWidget(key: const ValueKey('maze-game'), game: _game),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.controlMode == 'joystick')
          _JoystickControl(
            key: const ValueKey('joystick-control'),
            onMove: _game.move,
          )
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DirectionButton(
                icon: Icons.keyboard_arrow_up,
                label: 'Mover arriba',
                onPressed: () => _game.move(-1, 0),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DirectionButton(
                    icon: Icons.keyboard_arrow_left,
                    label: 'Mover a la izquierda',
                    onPressed: () => _game.move(0, -1),
                  ),
                  const SizedBox(width: 6),
                  DirectionButton(
                    icon: Icons.keyboard_arrow_down,
                    label: 'Mover abajo',
                    onPressed: () => _game.move(1, 0),
                  ),
                  const SizedBox(width: 6),
                  DirectionButton(
                    icon: Icons.keyboard_arrow_right,
                    label: 'Mover a la derecha',
                    onPressed: () => _game.move(0, 1),
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(width: 12),
        SizedBox(
          width: 58,
          height: 56,
          child: FilledButton(
            onPressed: _game.shoot,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: const Color(0xFF6B3527),
              foregroundColor: const Color(0xFFFFD98A),
            ),
            child: const Icon(Icons.gps_fixed, size: 28),
          ),
        ),
      ],
    );
  }
}

class _JoystickControl extends StatefulWidget {
  const _JoystickControl({required this.onMove, super.key});

  final void Function(int rowDelta, int columnDelta) onMove;

  @override
  State<_JoystickControl> createState() => _JoystickControlState();
}

class _JoystickControlState extends State<_JoystickControl> {
  static const _size = 112.0;
  Offset _offset = Offset.zero;

  void _update(Offset position) {
    final delta = position - const Offset(_size / 2, _size / 2);
    final distance = delta.distance;
    final limited = distance > 36 ? delta * (36 / distance) : delta;
    setState(() => _offset = limited);
  }

  void _move() {
    final dx = _offset.dx;
    final dy = _offset.dy;
    if (_offset.distance < 18) {
      return;
    }
    if (dx.abs() > dy.abs()) {
      widget.onMove(0, dx > 0 ? 1 : -1);
    } else {
      widget.onMove(dy > 0 ? 1 : -1, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _update(details.localPosition),
      onPanUpdate: (details) => _update(details.localPosition),
      onPanEnd: (_) {
        _move();
        setState(() => _offset = Offset.zero);
      },
      child: SizedBox(
        width: _size,
        height: _size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF24211C),
            border: Border.all(color: const Color(0xFF9A6937), width: 3),
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.gamepad, color: Colors.white24, size: 42),
              Transform.translate(
                offset: _offset,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0A64A),
                    border: Border.all(
                      color: const Color(0xFFFFE6B5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 6),
                    ],
                  ),
                  child: const Icon(
                    Icons.circle,
                    size: 9,
                    color: Color(0xFF63451D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 14,
        vertical: compact ? 7 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF24211C),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF59442E)),
      ),
      child: Row(
        children: [
          Icon(icon, color: valueColor, size: compact ? 18 : 22),
          SizedBox(width: compact ? 5 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: compact ? 8 : 10,
                    letterSpacing: 1.2,
                    color: Colors.white60,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
