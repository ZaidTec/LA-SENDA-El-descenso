import 'package:flutter/material.dart';

import '../models/maze_level.dart';
import 'game_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    required this.level,
    required this.won,
    required this.elapsedSeconds,
    this.lostReason = '',
    this.saveError,
    super.key,
  });

  final MazeLevel level;
  final bool won;
  final int elapsedSeconds;
  final String lostReason;
  final String? saveError;

  @override
  Widget build(BuildContext context) {
    final nextLevel = level.number < mazeLevels.length
        ? mazeLevels[level.number]
        : null;
    final time = Duration(seconds: elapsedSeconds);
    final formattedTime =
        '${time.inMinutes.toString().padLeft(2, '0')}:'
        '${(time.inSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    won
                        ? Icons.emoji_events
                        : lostReason.contains('atrap')
                        ? Icons.warning_amber
                        : Icons.hourglass_bottom,
                    size: 82,
                    color: won
                        ? const Color(0xFFE9BD60)
                        : const Color(0xFFFF8273),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    won
                        ? '¡Laberinto superado!'
                        : lostReason.contains('atrap')
                        ? '¡Te atraparon!'
                        : 'Se acabó el tiempo',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    won
                        ? 'Completaste ${level.name}.'
                        : lostReason.contains('atrap')
                        ? 'Esquiva o elimina a los enemigos y vuelve a intentarlo.'
                        : 'Inténtalo de nuevo y busca la llave.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: const Color(0xFF1B2925),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'TIEMPO UTILIZADO',
                            style: TextStyle(
                              color: Colors.white60,
                              letterSpacing: 1.5,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF4EBD0),
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (saveError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'No se pudo guardar el récord: $saveError',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFFFA99D)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (won && nextLevel != null)
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => GameScreen(level: nextLevel),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: Text('Jugar nivel ${nextLevel.number}'),
                    ),
                  if (!won)
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => GameScreen(level: level),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  if (won && nextLevel == null)
                    Text(
                      '¡Completaste los ${mazeLevels.length} niveles!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFE9BD60)),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Volver al menú'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
