import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/maze_level.dart';
import '../services/progress_service.dart';
import 'game_screen.dart';
import 'instructions_screen.dart';
import 'levels_screen.dart';
import 'records_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<ProgressData> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = ProgressService.load();
  }

  void _retryLoading() {
    setState(() {
      _progressFuture = ProgressService.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProgressData>(
      future: _progressFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No se pudo cargar el progreso.'),
                    const SizedBox(height: 12),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _retryLoading,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final progress = snapshot.data!;
        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            color: const Color(0xFF203D31),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF67816A),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.explore,
                            size: 64,
                            color: Color(0xFFE9BD60),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'LA SENDA:',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                letterSpacing: 4,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFF4EBD0),
                              ),
                        ),
                        Text(
                          'El descenso',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                letterSpacing: 3,
                                color: const Color(0xFFE9BD60),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Encuentra la llave. Escapa antes de que acabe el tiempo.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 28),
                        FilledButton.icon(
                          onPressed: () {
                            final level =
                                mazeLevels[(progress.unlockedLevel - 1).clamp(
                                  0,
                                  mazeLevels.length - 1,
                                )];
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => GameScreen(level: level),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Jugar'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const LevelsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Seleccionar niveles'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            foregroundColor: const Color(0xFFF4EBD0),
                            side: const BorderSide(color: Color(0xFF536B5C)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SmallMenuButton(
                                icon: Icons.emoji_events_outlined,
                                label: 'Récords',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const RecordsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SmallMenuButton(
                                icon: Icons.menu_book_outlined,
                                label: 'Instrucciones',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const InstructionsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            if (!kIsWeb &&
                                defaultTargetPlatform ==
                                    TargetPlatform.android) {
                              SystemNavigator.pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'La opción Salir está disponible en Android.',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.exit_to_app, size: 18),
                          label: const Text('Salir'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'NIVEL ${progress.unlockedLevel} DE ${mazeLevels.length} DESBLOQUEADO',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                letterSpacing: 1.5,
                                color: const Color(0xFFA8B5A7),
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SmallMenuButton extends StatelessWidget {
  const _SmallMenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE5E4D7),
        side: const BorderSide(color: Color(0xFF3D5148)),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
