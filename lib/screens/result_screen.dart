import 'package:flutter/material.dart';

import '../models/maze_level.dart';
import 'game_screen.dart';
import 'camp_screen.dart';
import 'shop_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    required this.level,
    required this.won,
    required this.elapsedSeconds,
    required this.rewardCoins,
    this.controlMode = 'dpad',
    this.equippedItem = 'explorer',
    this.lostReason = '',
    this.saveError,
    super.key,
  });

  final MazeLevel level;
  final bool won;
  final int elapsedSeconds;
  final int rewardCoins;
  final String controlMode;
  final String equippedItem;
  final String lostReason;
  final String? saveError;

  @override
  Widget build(BuildContext context) {
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
                        ? '¡Expedición completada!'
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
                        ? 'Completaste ${level.name}. La senda queda abierta.'
                        : lostReason.contains('atrap')
                        ? 'Esquiva o elimina a los enemigos y vuelve a intentarlo.'
                        : 'Inténtalo de nuevo y busca la llave.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: const Color(0xFF24211C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                      side: const BorderSide(color: Color(0xFF59442E)),
                    ),
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
                          if (won) ...[
                            const SizedBox(height: 12),
                            Card(
                              color: const Color(0xFF3B2A1D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                                side: const BorderSide(
                                  color: Color(0xFFB77C3D),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.toll,
                                      color: Color(0xFFE9BD60),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      saveError != null
                                          ? 'No se pudo guardar la recompensa'
                                          : rewardCoins > 0
                                          ? 'Recompensa: +$rewardCoins monedas'
                                          : 'Recompensa ya reclamada',
                                      style: const TextStyle(
                                        color: Color(0xFFE9BD60),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (saveError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'No se pudo guardar el progreso: $saveError',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFFFA99D)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (!won)
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => GameScreen(
                              level: level,
                              controlMode: controlMode,
                              equippedItem: equippedItem,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ShopScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.storefront_outlined),
                    label: Text(
                      won ? 'CANJEAR EN EL PUESTO' : 'VISITAR EL PUESTO',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const CampScreen(),
                      ),
                      (_) => false,
                    ),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('VOLVER AL CAMPAMENTO'),
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
