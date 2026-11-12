import 'package:flutter/material.dart';

import '../models/maze_level.dart';
import '../services/progress_service.dart';
import 'levels_screen.dart';
import 'menu_screen.dart';
import 'options_screen.dart';
import 'records_screen.dart';
import 'shop_screen.dart';

class CampScreen extends StatefulWidget {
  const CampScreen({super.key});

  @override
  State<CampScreen> createState() => _CampScreenState();
}

class _CampScreenState extends State<CampScreen> {
  late Future<ProgressData> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = ProgressService.load();
  }

  void _refresh() {
    setState(() => _progressFuture = ProgressService.load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ProgressData>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('No se pudo cargar el campamento: ${snapshot.error}'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _refresh,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = snapshot.data!;
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final landscape = constraints.maxWidth > constraints.maxHeight;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(landscape ? 22 : 18),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (landscape ? 44 : 36),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context)
                                  .pushReplacement(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const MenuScreen(),
                                    ),
                                  ),
                              tooltip: 'Título principal',
                              icon: const Icon(Icons.arrow_back),
                            ),
                            const Spacer(),
                            _CoinPill(coins: progress.coins),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const OptionsScreen(),
                                ),
                              ),
                              tooltip: 'Opciones',
                              icon: const Icon(Icons.settings_outlined),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Icon(
                          Icons.local_fire_department,
                          size: landscape ? 38 : 52,
                          color: const Color(0xFFFFB94A),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'CAMPAMENTO BASE',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: const Color(0xFFF0D7A0),
                                letterSpacing: 3,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'La fogata está encendida. Prepara tu próxima expedición.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .7),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: GridView.count(
                            crossAxisCount: landscape ? 3 : 1,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: landscape ? 1.55 : 3.2,
                            children: [
                              _CampCard(
                                icon: Icons.map_outlined,
                                title: 'MAPA DE EXPEDICIONES',
                                subtitle:
                                    'Mundos y niveles: ${progress.unlockedLevel} de $mazeLevelCount abiertos',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const LevelsScreen(),
                                  ),
                                ),
                              ),
                              _CampCard(
                                icon: Icons.storefront_outlined,
                                title: 'PUESTO DEL ARQUEÓLOGO',
                                subtitle:
                                    'Compra y equipa objetos para la senda',
                                onTap: () => Navigator.of(context)
                                    .push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const ShopScreen(),
                                      ),
                                    )
                                    .then((_) => _refresh()),
                              ),
                              _CampCard(
                                icon: Icons.emoji_events_outlined,
                                title: 'DIARIO DE CAMPO',
                                subtitle:
                                    '${progress.bestTimes.length} expediciones completadas',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const RecordsScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'EQUIPADO: ${_itemName(progress.equippedItem).toUpperCase()}',
                          style: const TextStyle(
                            color: Color(0xFFFFB94A),
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B2A1D),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFB77C3D), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.toll, size: 18, color: Color(0xFFE9BD60)),
          const SizedBox(width: 7),
          Text('$coins'),
        ],
      ),
    );
  }
}

class _CampCard extends StatelessWidget {
  const _CampCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF24211C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: const BorderSide(color: Color(0xFF59442E), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 34, color: const Color(0xFFE9BD60)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

String _itemName(String id) => switch (id) {
  'explorer' => 'Equipo de explorador',
  'torch' => 'Antorcha antigua',
  'armor' => 'Armadura de piedra',
  'relic' => 'Reliquia dorada',
  _ => id,
};
