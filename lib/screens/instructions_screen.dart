import 'package:flutter/material.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instrucciones')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _Instruction(
            icon: Icons.directions,
            title: 'Explora',
            description:
                'Mantén pulsada una flecha para caminar por los pasillos. '
                'Las paredes bloquean el paso.',
          ),
          _Instruction(
            icon: Icons.key,
            title: 'Encuentra la llave',
            description:
                'Recoge la llave dorada antes de intentar abrir la puerta.',
          ),
          _Instruction(
            icon: Icons.gps_fixed,
            title: 'Defiéndete',
            description:
                'Los enemigos patrullan los pasillos. Muévete para apuntar '
                'y pulsa el botón de disparo. Los muros detienen tus disparos.',
          ),
          _Instruction(
            icon: Icons.door_front_door_outlined,
            title: 'Escapa a tiempo',
            description:
                'Llega a la puerta antes de que el reloj llegue a cero. '
                'Puedes reiniciar el nivel desde el botón de arriba. '
                'Si una criatura te alcanza, tendrás que volver a empezar.',
          ),
        ],
      ),
    );
  }
}

class _Instruction extends StatelessWidget {
  const _Instruction({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF24211C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: const BorderSide(color: Color(0xFF59442E)),
      ),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFE9BD60), size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
