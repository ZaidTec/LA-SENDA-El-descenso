import 'package:flutter/material.dart';

import '../models/maze_level.dart';
import '../services/progress_service.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Récords')),
      body: FutureBuilder<ProgressData>(
        future: ProgressService.load(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar los récords: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final times = snapshot.data!.bestTimes;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Tus mejores tiempos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              for (final level in mazeLevels)
                Card(
                  color: const Color(0xFF1B2925),
                  child: ListTile(
                    leading: const Icon(
                      Icons.emoji_events_outlined,
                      color: Color(0xFFE9BD60),
                    ),
                    title: Text('Nivel ${level.number}: ${level.name}'),
                    trailing: Text(
                      times[level.number] == null
                          ? '--:--'
                          : _formatTime(times[level.number]!),
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

String _formatTime(int seconds) =>
    '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
    '${(seconds % 60).toString().padLeft(2, '0')}';
