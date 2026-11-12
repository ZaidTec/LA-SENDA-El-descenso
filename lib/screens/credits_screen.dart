import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créditos')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore, size: 64, color: Color(0xFFFFB94A)),
              const SizedBox(height: 12),
              Text(
                'LA SENDA: El descenso',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const _CreditLine(
                role: 'DESARROLLO',
                names: 'Equipo de desarrollo · 3 integrantes',
              ),
              const _CreditLine(
                role: 'TECNOLOGÍA',
                names: 'Flutter · Dart · Flame',
              ),
              const _CreditLine(
                role: 'AGRADECIMIENTOS',
                names: 'A quienes se atreven a explorar la senda.',
              ),
              const SizedBox(height: 24),
              const Text(
                'Una aventura independiente creada como proyecto estudiantil.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditLine extends StatelessWidget {
  const _CreditLine({required this.role, required this.names});

  final String role;
  final String names;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            role,
            style: const TextStyle(
              color: Color(0xFFFFB94A),
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(names, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
