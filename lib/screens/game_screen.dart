import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/maze_game.dart';
import '../models/maze_level.dart';
import '../services/progress_service.dart';
import '../widgets/direction_button.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({required this.level, super.key});

  final MazeLevel level;

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
    _game = MazeGame(level: widget.level, onChanged: _handleGameChanged);
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
    if (snapshot.status == MazeGameStatus.won) {
      try {
        await ProgressService.completeLevel(
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
        ),
      ),
    );
  }

  void _restart() {
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(builder: (_) => GameScreen(level: widget.level)),
    );
  }

  void _returnToMenu() {
    Navigator.of(context).popUntil((route) => route.isFirst);
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _returnToMenu,
                    tooltip: 'Volver al menú',
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NIVEL ${widget.level.number}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: const Color(0xFFA8B5A7),
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
              ),
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
                          ? const Color(0xFFE9BD60)
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
                    color: Color(0xFFE9BD60),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF587260),
                            width: 2,
                          ),
                        ),
                        child: GameWidget(game: _game),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Muévete, apunta en la dirección y pulsa disparar',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Colors.white60),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        backgroundColor: const Color(0xFF813B38),
                        foregroundColor: const Color(0xFFFFE6B5),
                      ),
                      child: const Icon(Icons.gps_fixed, size: 28),
                    ),
                  ),
                ],
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
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2925),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF354D41)),
      ),
      child: Row(
        children: [
          Icon(icon, color: valueColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
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
