import 'package:flutter/material.dart';

class GameHud extends StatelessWidget {
  const GameHud({
    required this.clock,
    required this.hasKey,
    required this.remainingEnemies,
    this.urgent = false,
    this.compact = false,
    super.key,
  });

  final String clock;
  final bool hasKey;
  final int remainingEnemies;
  final bool urgent;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _HudCard(
          compact: compact,
          icon: Icons.timer_outlined,
          label: 'TIEMPO',
          value: clock,
          color: urgent
              ? const Color(0xFFFF8273)
              : const Color(0xFFF0D7A0),
        ),
      ),
      SizedBox(width: compact ? 6 : 10),
      Expanded(
        child: _HudCard(
          compact: compact,
          icon: hasKey ? Icons.key : Icons.key_off,
          label: 'LLAVE',
          value: hasKey
              ? (compact ? 'Lista' : 'Encontrada')
              : 'Pendiente',
          color: hasKey
              ? const Color(0xFFFFB94A)
              : const Color(0xFFCBCBC1),
        ),
      ),
      SizedBox(width: compact ? 6 : 10),
      Expanded(
        child: _HudCard(
          compact: compact,
          icon: Icons.pest_control,
          label: 'ENEMIGOS',
          value: '$remainingEnemies',
          color: const Color(0xFFFF8273),
        ),
      ),
    ],
  );
}

class _HudCard extends StatelessWidget {
  const _HudCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 7 : 14,
      vertical: compact ? 7 : 10,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFF24211C),
      borderRadius: BorderRadius.circular(3),
      border: Border.all(color: const Color(0xFF59442E)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: compact ? 18 : 22),
        SizedBox(width: compact ? 5 : 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 8 : 10,
                  letterSpacing: 1.2,
                  color: const Color(0xFFB7A98C),
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
