import 'package:flutter/material.dart';

import '../models/maze_level.dart';
import '../services/progress_service.dart';
import 'game_screen.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar nivel')),
      body: FutureBuilder<ProgressData>(
        future: ProgressService.load(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _LoadError(error: snapshot.error!);
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: mazeLevels.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final level = mazeLevels[index];
              final unlocked = level.number <= progress.unlockedLevel;
              final bestTime = progress.bestTimes[level.number];
              return Card(
                color: const Color(0xFF1B2925),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: unlocked
                        ? const Color(0xFF315C45)
                        : const Color(0xFF303A35),
                    child: Icon(
                      unlocked ? Icons.explore : Icons.lock_outline,
                      color: unlocked
                          ? const Color(0xFFE9BD60)
                          : Colors.white54,
                    ),
                  ),
                  title: Text('Nivel ${level.number}: ${level.name}'),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${level.description}\n'
                      '${level.enemyCount} enemigos · '
                      '${level.timeLimitSeconds} segundos\n'
                      '${bestTime == null ? 'Sin récord' : 'Mejor tiempo: ${_formatTime(bestTime)}'}',
                    ),
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  enabled: unlocked,
                  onTap: unlocked
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => GameScreen(level: level),
                            ),
                          );
                        }
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'No se pudieron cargar los niveles: $error',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

String _formatTime(int seconds) =>
    '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
    '${(seconds % 60).toString().padLeft(2, '0')}';
