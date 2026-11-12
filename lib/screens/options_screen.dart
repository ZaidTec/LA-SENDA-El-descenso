import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import 'credits_screen.dart';
import 'instructions_screen.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  late Future<ProgressData> _progressFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _progressFuture = ProgressService.load();
  }

  Future<void> _save(Future<void> Function() action) async {
    setState(() => _saving = true);
    try {
      await action();
      if (mounted) {
        setState(() => _progressFuture = ProgressService.load());
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar la opción: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opciones de expedición')),
      body: FutureBuilder<ProgressData>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'No se pudieron cargar las opciones: ${snapshot.error}',
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final settings = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _SettingSection(
                title: 'AUDIO',
                icon: Icons.volume_up_outlined,
                child: Column(
                  children: [
                    _VolumeSetting(
                      label: 'Música',
                      value: settings.musicVolume,
                      enabled: !_saving,
                      onChanged: (value) =>
                          _save(() => ProgressService.setMusicVolume(value)),
                    ),
                    _VolumeSetting(
                      label: 'Efectos de sonido',
                      value: settings.sfxVolume,
                      enabled: !_saving,
                      onChanged: (value) =>
                          _save(() => ProgressService.setSfxVolume(value)),
                    ),
                    const Text(
                      'Los niveles se guardan para integrar audio en una próxima actualización.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingSection(
                title: 'CONTROLES',
                icon: Icons.gamepad_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Elige cómo quieres moverte durante la partida.',
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'dpad',
                          icon: Icon(Icons.control_camera),
                          label: Text('Táctil'),
                        ),
                        ButtonSegment(
                          value: 'joystick',
                          icon: Icon(Icons.gamepad),
                          label: Text('Joystick'),
                        ),
                      ],
                      selected: {settings.controlMode},
                      onSelectionChanged: _saving
                          ? null
                          : (selected) => _save(
                              () => ProgressService.setControlMode(
                                selected.first,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingSection(
                title: 'INFORMACIÓN',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.menu_book_outlined),
                      title: const Text('Instrucciones'),
                      subtitle: const Text('Cómo recorrer la senda'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const InstructionsScreen(),
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.groups_outlined),
                      title: const Text('Créditos'),
                      subtitle: const Text('Equipo y agradecimientos'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CreditsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_saving) ...[
                const SizedBox(height: 18),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  const _SettingSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF24211C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: const BorderSide(color: Color(0xFF59442E)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFFFB94A)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _VolumeSetting extends StatefulWidget {
  const _VolumeSetting({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  State<_VolumeSetting> createState() => _VolumeSettingState();
}

class _VolumeSettingState extends State<_VolumeSetting> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant _VolumeSetting oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 125, child: Text(widget.label)),
        Expanded(
          child: Slider(
            value: _value.clamp(0, 1).toDouble(),
            onChanged: widget.enabled
                ? (value) => setState(() => _value = value)
                : null,
            onChangeEnd: widget.enabled ? widget.onChanged : null,
            divisions: 10,
          ),
        ),
        SizedBox(width: 38, child: Text('${(_value * 100).round()}%')),
      ],
    );
  }
}
