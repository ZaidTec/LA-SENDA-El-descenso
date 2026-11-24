import 'package:flutter/material.dart';

import '../game/levels/level_manager.dart';
import 'game_screen.dart';
import 'main_menu_screen.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide =
                constraints.maxWidth >= 700 &&
                constraints.maxWidth > constraints.maxHeight;
            final summary = _buildSummary(context, formattedTime, wide: wide);
            final actions = _buildActions(context, wide: wide);

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(wide ? 16 : 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: wide ? 900 : 420),
                  child: wide
                      ? Row(
                          children: [
                            Expanded(child: summary),
                            const SizedBox(width: 28),
                            Expanded(child: actions),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            summary,
                            const SizedBox(height: 24),
                            actions,
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    String formattedTime, {
    required bool wide,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          won
              ? Icons.emoji_events
              : lostReason.contains('atrap')
              ? Icons.warning_amber
              : Icons.hourglass_bottom,
          size: wide ? 52 : 82,
          color: won ? const Color(0xFFE9BD60) : const Color(0xFFFF8273),
        ),
        SizedBox(height: wide ? 8 : 18),
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
        SizedBox(height: wide ? 6 : 10),
        Text(
          won
              ? 'Completaste ${level.name}. La senda queda abierta.'
              : lostReason.contains('atrap')
              ? 'Esquiva o elimina a los enemigos y vuelve a intentarlo.'
              : 'Inténtalo de nuevo y busca la llave.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        SizedBox(height: wide ? 12 : 24),
        Card(
          color: const Color(0xFF24211C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
            side: const BorderSide(color: Color(0xFF59442E)),
          ),
          child: Padding(
            padding: EdgeInsets.all(wide ? 12 : 20),
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
                  style: TextStyle(
                    fontSize: wide ? 30 : 36,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF4EBD0),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (won) ...[
                  SizedBox(height: wide ? 8 : 12),
                  Card(
                    color: const Color(0xFF3B2A1D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                      side: const BorderSide(color: Color(0xFFB77C3D)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(wide ? 10 : 16),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          const Icon(Icons.toll, color: Color(0xFFE9BD60)),
                          Text(
                            saveError != null
                                ? 'No se pudo guardar la recompensa'
                                : rewardCoins > 0
                                ? 'Recompensa: +$rewardCoins monedas'
                                : 'Recompensa ya reclamada',
                            textAlign: TextAlign.center,
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
      ],
    );
  }

  Widget _buildActions(BuildContext context, {required bool wide}) {
    final buttonHeight = wide ? 48.0 : 54.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!won) ...[
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
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(buttonHeight),
            ),
          ),
          const SizedBox(height: 10),
        ],
        FilledButton.icon(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const ShopScreen())),
          icon: const Icon(Icons.storefront_outlined),
          label: Text(won ? 'CANJEAR EN EL PUESTO' : 'VISITAR EL PUESTO'),
          style: FilledButton.styleFrom(
            minimumSize: Size.fromHeight(buttonHeight),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const MainMenuScreen()),
            (_) => false,
          ),
          icon: const Icon(Icons.home_outlined),
          label: const Text('VOLVER AL MENÚ'),
          style: OutlinedButton.styleFrom(
            minimumSize: Size.fromHeight(buttonHeight),
          ),
        ),
      ],
    );
  }
}
