import 'dart:async';

import 'package:flutter/material.dart';

class DirectionButton extends StatefulWidget {
  const DirectionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  State<DirectionButton> createState() => _DirectionButtonState();
}

class _DirectionButtonState extends State<DirectionButton> {
  Timer? _repeatTimer;

  void _startMoving(TapDownDetails _) {
    _stopMoving();
    widget.onPressed();
    _repeatTimer = Timer.periodic(
      const Duration(milliseconds: 180),
      (_) => widget.onPressed(),
    );
  }

  void _stopMoving([TapUpDetails? _]) {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _stopMoving();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _startMoving,
        onTapUp: _stopMoving,
        onTapCancel: _stopMoving,
        child: Container(
          width: 54,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF49321F),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFFB77C3D), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Colors.black45, offset: Offset(2, 2)),
            ],
          ),
          child: Icon(widget.icon, size: 28, color: const Color(0xFFF0D7A0)),
        ),
      ),
    );
  }
}
