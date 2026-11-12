import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import 'camp_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _saving = false;

  Future<void> _continue() async {
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ProgressService.setIntroSeen();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const CampScreen()),
      );
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la introducción: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, .35),
                radius: 1.1,
                colors: [
                  Color(0xFF352719),
                  Color(0xFF171514),
                  Color(0xFF080A0B),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 420;
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: _saving ? null : _continue,
                          child: const Text('Saltar  ›'),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.local_fire_department,
                        size: compact ? 46 : 64,
                        color: const Color(0xFFFFB746),
                        shadows: const [
                          Shadow(color: Color(0xAAFF7B20), blurRadius: 28),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'ANTES DEL DESCENSO',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFF2C15E),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 650),
                        child: Text(
                          'Bajo las ruinas duerme una senda que nadie ha logrado '
                          'recorrer dos veces. Las antiguas expediciones dejaron '
                          'mapas, llaves y señales de algo que aún habita en la '
                          'oscuridad.\n\n'
                          'Prepara tu equipo en el campamento. Encuentra la llave, '
                          'evita a las criaturas y regresa con vida.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.55,
                            color: Colors.white.withValues(alpha: .88),
                            fontSize: compact ? 14 : 17,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _saving ? null : _continue,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.explore),
                        label: const Text('IR AL CAMPAMENTO'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(260, 52),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
