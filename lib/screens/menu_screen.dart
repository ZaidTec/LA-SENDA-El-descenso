import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/progress_service.dart';
import 'camp_screen.dart';
import 'intro_screen.dart';
import 'options_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late Future<ProgressData> _progressFuture;
  late final AnimationController _coverAnimation;

  @override
  void initState() {
    super.initState();
    _progressFuture = ProgressService.load();
    _coverAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _coverAnimation.dispose();
    super.dispose();
  }

  void _retryLoading() {
    setState(() => _progressFuture = ProgressService.load());
  }

  void _openOptions() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const OptionsScreen()));
  }

  Future<void> _play() async {
    try {
      final progress = await _progressFuture;
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              progress.introSeen ? const CampScreen() : const IntroScreen(),
        ),
      );
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo iniciar la expedición: $error')),
        );
      }
    }
  }

  Future<void> _exitGame() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1B2925),
        title: const Text('Abandonar expedición'),
        content: const Text('¿Deseas abandonar la expedición?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('SALIR'),
          ),
        ],
      ),
    );
    if (shouldExit != true || !mounted) {
      return;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      SystemNavigator.pop();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Puedes cerrar esta ventana para salir del juego.'),
      ),
    );
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

        return Scaffold(
          body: ColoredBox(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: 966 / 542,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/la_senda_cover.png',
                          key: const ValueKey('cover-image'),
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.none,
                          excludeFromSemantics: true,
                        ),
                        IgnorePointer(
                          child: RepaintBoundary(
                            child: CustomPaint(
                              key: const ValueKey('cover-animation'),
                              painter: _AnimatedCoverPainter(_coverAnimation),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                        Positioned(
                          left: constraints.maxWidth * .28,
                          top: constraints.maxHeight * .755,
                          width: constraints.maxWidth * .44,
                          height: constraints.maxHeight * .075,
                          child: _CoverHotspot(
                            key: const ValueKey('cover-play'),
                            label: 'JUGAR',
                            onPressed: _play,
                          ),
                        ),
                        Positioned(
                          left: constraints.maxWidth * .28,
                          top: constraints.maxHeight * .835,
                          width: constraints.maxWidth * .44,
                          height: constraints.maxHeight * .075,
                          child: _CoverHotspot(
                            key: const ValueKey('cover-options'),
                            label: 'OPCIONES',
                            onPressed: _openOptions,
                          ),
                        ),
                        Positioned(
                          left: constraints.maxWidth * .28,
                          top: constraints.maxHeight * .915,
                          width: constraints.maxWidth * .44,
                          height: constraints.maxHeight * .075,
                          child: _CoverHotspot(
                            key: const ValueKey('cover-exit'),
                            label: 'SALIR',
                            onPressed: _exitGame,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CoverHotspot extends StatelessWidget {
  const _CoverHotspot({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _InteractiveCoverHotspot(label: label, onPressed: onPressed);
  }
}

class _InteractiveCoverHotspot extends StatefulWidget {
  const _InteractiveCoverHotspot({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  State<_InteractiveCoverHotspot> createState() =>
      _InteractiveCoverHotspotState();
}

class _InteractiveCoverHotspotState extends State<_InteractiveCoverHotspot> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            decoration: BoxDecoration(
              color: _pressed
                  ? const Color(0x55FFC34D)
                  : _hovering
                  ? const Color(0x22FFC34D)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: _hovering
                  ? Border.all(color: const Color(0x66FFC34D), width: 1)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedCoverPainter extends CustomPainter {
  _AnimatedCoverPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;
  static const _canvasSize = Size(320, 180);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / _canvasSize.width,
      size.height / _canvasSize.height,
    );
    final time = animation.value * math.pi * 2;
    _drawFlame(canvas, const Offset(58.5, 57), time, 1);
    _drawFlame(canvas, const Offset(261.5, 57), time + 1.8, 1);
    _drawFlame(canvas, const Offset(176.5, 95), time + .8, .83);
    _drawFlame(canvas, const Offset(180, 145), time + 2.7, .4);
    _drawEmbers(canvas, time);
    _drawKeyGlints(canvas, time);
    _drawMovingKey(canvas, time);
    _drawTitleSparkles(canvas, time);
    _drawTorchlight(canvas, time);
    canvas.restore();
  }

  void _drawFlame(Canvas canvas, Offset base, double time, double scale) {
    final sway = math.sin(time * 2.1) * 1.7 * scale;
    final pulse = .82 + (math.sin(time * 3.2) + 1) * .09;
    final x = base.dx + sway;
    final y = base.dy + math.sin(time * 2.8) * 1.1 * scale;
    void block(double dx, double dy, double w, double h, Color color) {
      canvas.drawRect(
        Rect.fromLTWH(x + dx * scale, y + dy * scale, w * scale, h * scale),
        Paint()..color = color.withValues(alpha: color.a * pulse),
      );
    }

    block(-2, -11, 4, 3, const Color(0xFFFF7628));
    block(-4, -8, 8, 4, const Color(0xFFFF8B2C));
    block(-6, -5, 12, 4, const Color(0xFFFFA52E));
    block(-5, -2, 10, 4, const Color(0xFFFFC548));
    block(-3, 1, 6, 3, const Color(0xFFFFDA62));
    block(-2, -7, 4, 7, const Color(0xFFFFE987));
    block(-1, -6, 2, 5, const Color(0xFFFFF2B2));
    block(-7, -3, 2, 3, const Color(0xFFE95F26));
    block(5, -6, 2, 3, const Color(0xFFFF7025));
    block(
      -1,
      -14 - (math.sin(time * 4).abs() * 3).floorToDouble(),
      2,
      2,
      const Color(0xFFFFD35A),
    );
  }

  void _drawEmbers(Canvas canvas, double time) {
    for (var index = 0; index < 18; index++) {
      final phase = (animation.value + index * .173) % 1;
      final rising = phase * 25;
      final sourceX = 47 + ((index * 37) % 227);
      final sway = math.sin(time * 1.5 + index) * 2.2;
      final x = sourceX + sway;
      final y = 124 - rising - ((index * 13) % 35);
      final size = index % 4 == 0 ? 1.7 : 1.1;
      final opacity = (1 - phase) * .85;
      canvas.drawRect(
        Rect.fromLTWH(x, y, size, size),
        Paint()
          ..color =
              (index.isEven ? const Color(0xFFFFB33E) : const Color(0xFFFF7130))
                  .withValues(alpha: opacity),
      );
    }
  }

  void _drawKeyGlints(Canvas canvas, double time) {
    final bob = math.sin(time * 2) * 1.4;
    final glints = [
      Offset(133 + math.sin(time * 2.4) * 3, 143 + bob),
      Offset(140 + math.sin(time * 1.9 + 1) * 2, 146 - bob),
      Offset(136 + math.sin(time * 2.7 + 2) * 3, 139 + bob),
    ];
    for (var i = 0; i < glints.length; i++) {
      final point = glints[i];
      final alpha = .35 + (math.sin(time * 4 + i * 2) + 1) * .3;
      final color = const Color(0xFFFFE58B).withValues(alpha: alpha);
      canvas.drawRect(
        Rect.fromLTWH(point.dx, point.dy, 2, 1),
        Paint()..color = color,
      );
      canvas.drawRect(
        Rect.fromLTWH(point.dx + .5, point.dy - 1.5, 1, 4),
        Paint()..color = color,
      );
    }
  }

  void _drawMovingKey(Canvas canvas, double time) {
    final center = Offset(136.5, 144 + math.sin(time * 1.7) * 1.2);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.sin(time * 1.3) * .1);
    canvas.translate(-center.dx, -center.dy);
    final dark = Paint()..color = const Color(0xFF2C2118);
    final gold = Paint()..color = const Color(0xFFFFC34D);
    final shine = Paint()..color = const Color(0xFFFFE99B);
    final cutout = Paint()..color = const Color(0xFF57412C);
    canvas
      ..drawRect(const Rect.fromLTWH(132, 141, 6, 6), dark)
      ..drawRect(const Rect.fromLTWH(133, 142, 4, 4), gold)
      ..drawRect(const Rect.fromLTWH(134, 143, 2, 2), cutout)
      ..drawRect(const Rect.fromLTWH(137, 143, 7, 2), dark)
      ..drawRect(const Rect.fromLTWH(138, 143, 6, 1), gold)
      ..drawRect(const Rect.fromLTWH(141, 144, 2, 3), dark)
      ..drawRect(const Rect.fromLTWH(142, 144, 1, 2), gold)
      ..drawRect(const Rect.fromLTWH(133, 142, 2, 1), shine)
      ..drawRect(const Rect.fromLTWH(139, 143, 2, 1), shine);
    canvas.restore();
  }

  void _drawTitleSparkles(Canvas canvas, double time) {
    const points = [
      Offset(84, 36),
      Offset(237, 31),
      Offset(95, 56),
      Offset(224, 56),
      Offset(160, 24),
    ];
    for (var index = 0; index < points.length; index++) {
      final phase = time * 1.3 + index * 1.7;
      final alpha = .15 + (math.sin(phase) + 1) * .32;
      final point = points[index] + Offset(math.sin(phase) * 1.5, 0);
      final paint = Paint()
        ..color = const Color(0xFFFFC75A).withValues(alpha: alpha);
      canvas
        ..drawRect(Rect.fromLTWH(point.dx, point.dy, 2, 1), paint)
        ..drawRect(Rect.fromLTWH(point.dx + .5, point.dy - 1.5, 1, 4), paint);
    }
  }

  void _drawTorchlight(Canvas canvas, double time) {
    final alpha = .025 + (math.sin(time * 3) + 1) * .012;
    for (final center in [
      const Offset(58, 60),
      const Offset(262, 60),
      const Offset(177, 101),
    ]) {
      final color = const Color(0xFFFFB347).withValues(alpha: alpha);
      canvas.drawRect(
        Rect.fromLTWH(center.dx - 8, center.dy + 6, 16, 5),
        Paint()..color = color,
      );
      canvas.drawRect(
        Rect.fromLTWH(center.dx - 5, center.dy + 11, 10, 4),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedCoverPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
