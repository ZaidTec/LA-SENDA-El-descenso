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
                color: const Color(0xFF24211C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                  side: const BorderSide(color: Color(0xFF59442E)),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: unlocked
                          ? const Color(0xFF533A24)
                          : const Color(0xFF292725),
                      border: Border.all(
                        color: unlocked
                            ? const Color(0xFFB77C3D)
                            : const Color(0xFF51483D),
                      ),
                    ),
                    child: Icon(
                      unlocked ? Icons.explore : Icons.lock_outline,
                      color: unlocked
                          ? const Color(0xFFFFB94A)
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
                              builder: (_) => GameScreen(
                                level: level,
                                controlMode: progress.controlMode,
                                equippedItem: progress.equippedItem,
                              ),
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
