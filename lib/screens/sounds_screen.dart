import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';
import '../widgets/glassmorphic_card.dart';
import 'package:respiro/l10n/app_localizations.dart';

class SoundsScreen extends StatelessWidget {
  const SoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProv = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = Theme.of(context).colorScheme.primary;

    final isAudioActive = settingsProv.activeAudioTrack != 'none';

    // List of audio loops mapped with metadata
    final List<Map<String, dynamic>> tracks = [
      {
        'id': 'brown_noise',
        'title': l10n.soundBrownNoise,
        'subtitle': 'Deep, low-frequency rumble for grounding focus',
        'icon': Icons.waves,
        'color': const Color(0xFF64DFDF),
      },
      {
        'id': 'ocean',
        'title': l10n.soundOcean,
        'subtitle': 'Rhythmic shore washes to stabilize breathing',
        'icon': Icons.water_drop,
        'color': const Color(0xFF4EA8DE),
      },
      {
        'id': 'rain',
        'title': l10n.soundRain,
        'subtitle': 'Gentle overhead rain to dissolve ambient stress',
        'icon': Icons.grain,
        'color': const Color(0xFFFFB3C1),
      },
      {
        'id': 'pink_noise',
        'title': l10n.soundPinkNoise,
        'subtitle': 'Soft, balanced static to filter sharp interruptions',
        'icon': Icons.blur_on,
        'color': const Color(0xFFB5E2FA),
      },
      {
        'id': 'solfeggio',
        'title': l10n.soundSolfeggio,
        'subtitle': '✨ 528 Hz transformation frequency for deep somatic peace',
        'icon': Icons.brightness_high,
        'color': const Color(0xFFFFD166),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tabSounds.toUpperCase(),
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isDark ? primaryColor : const Color(0xFF007A7A),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          children: [
            // Equalizer visualizer card
            GlassmorphicCard(
              blur: 16,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(9, (index) {
                      return _EqualizerBar(
                        isActive: isAudioActive,
                        color: primaryColor,
                        index: index,
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.soundTitle.toUpperCase(),
                    style: GoogleFonts.cinzel(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.soundSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "AMBIENT CHANNELS",
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  ),
                ),
                if (isAudioActive)
                  TextButton.icon(
                    onPressed: () {
                      settingsProv.setAudioTrack('none');
                    },
                    icon: const Icon(Icons.volume_off, size: 14, color: Colors.grey),
                    label: Text(
                      "MUTE ALL",
                      style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Ambient list tracks sliders
            ...tracks.map((track) {
              final String id = track['id'] as String;
              final double vol = settingsProv.trackVolumes[id] ?? 0.0;
              final bool isTrackPlaying = vol > 0.0;
              final Color trackColor = track['color'] as Color;

              return Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: GlassmorphicCard(
                  padding: const EdgeInsets.all(12.0),
                  borderColor: isTrackPlaying
                      ? trackColor.withValues(alpha: 0.3)
                      : const Color(0x1F64DFDF),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isTrackPlaying
                                ? trackColor.withValues(alpha: 0.15)
                                : (isDark ? Colors.white10 : Colors.black12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            track['icon'] as IconData,
                            color: isTrackPlaying ? trackColor : Colors.grey,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          track['title'] as String,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isTrackPlaying
                                ? (isDark ? Colors.white : Colors.black87)
                                : Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                          track['subtitle'] as String,
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            color: Colors.grey,
                            height: 1.3,
                          ),
                        ),
                        trailing: Switch(
                          value: isTrackPlaying,
                          activeThumbColor: trackColor,
                          onChanged: (val) {
                            settingsProv.setMixerTrackVolume(id, val ? 0.4 : 0.0);
                          },
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: isTrackPlaying
                            ? Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.volume_down, size: 14, color: Colors.grey),
                                      Expanded(
                                        child: Slider(
                                          value: vol,
                                          activeColor: trackColor,
                                          inactiveColor: isDark ? Colors.white10 : Colors.black12,
                                          onChanged: (newVol) {
                                            settingsProv.setMixerTrackVolume(id, newVol);
                                          },
                                        ),
                                      ),
                                      const Icon(Icons.volume_up, size: 14, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 32,
                                        child: Text(
                                          "${(vol * 100).round()}%",
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: trackColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _EqualizerBar extends StatefulWidget {
  final bool isActive;
  final Color color;
  final int index;

  const _EqualizerBar({
    required this.isActive,
    required this.color,
    required this.index,
  });

  @override
  State<_EqualizerBar> createState() => _EqualizerBarState();
}

class _EqualizerBarState extends State<_EqualizerBar> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  // Distinct wave speeds to create a dynamic visual signature
  final List<int> _durations = [350, 480, 280, 600, 420, 520, 320, 450, 380];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _durations[widget.index % _durations.length]),
    );

    _animation = Tween<double>(begin: 8.0, end: 45.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _EqualizerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animController.repeat(reverse: true);
      } else {
        _animController.stop();
        _animController.animateTo(0.0, duration: const Duration(milliseconds: 200));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final height = widget.isActive ? _animation.value : 8.0;
        return Container(
          width: 5,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 3.5),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: widget.isActive ? 0.9 : 0.4),
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
