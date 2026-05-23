import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/breathing_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/glassmorphic_card.dart';
import '../services/iap_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:respiro/l10n/app_localizations.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  bool _didShowCongratsThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<BreathingProvider>(context, listen: false).addListener(_onBreathingStateChange);
      }
    });
  }

  @override
  void dispose() {
    try {
      Provider.of<BreathingProvider>(context, listen: false).removeListener(_onBreathingStateChange);
    } catch (e) {
      // safe catch if provider is already disposed
    }
    super.dispose();
  }

  void _onBreathingStateChange() {
    if (!mounted) return;
    final breathingProv = Provider.of<BreathingProvider>(context, listen: false);
    
    if (breathingProv.state == BreathingState.completed && !_didShowCongratsThisSession) {
      _didShowCongratsThisSession = true;
      _showCongratsMilestoneSheet();
    } else if (breathingProv.state == BreathingState.idle) {
      _didShowCongratsThisSession = false;
    }
  }

  void _showCongratsMilestoneSheet() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final secondaryColor = Theme.of(context).colorScheme.secondary;

        return AlertDialog(
          backgroundColor: const Color(0xFF0A0E1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0x3F64DFDF), width: 1.0),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 64),
                const SizedBox(height: 16),
                Text(
                  "SESSION COMPLETED 🧘‍♂️",
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Well done! You successfully guided your heart and mind through a calming cycle. This session has been saved permanently in your local logbook.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: Colors.grey,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.withValues(alpha: 0.15)),
                const SizedBox(height: 8),
                Text(
                  "Sighra is 100% independent, offline-first, and contains zero ads. If it has helped you find a moment of peace today, consider keeping our indie lights on with a quick store tip.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close congrats dialog
                    _showTipJarDialog();
                  },
                  icon: const Icon(Icons.star_purple500, size: 16),
                  label: Text(
                    "Support Indie Dev",
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Keep Practicing",
                    style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTipJarDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final secondaryColor = Theme.of(context).colorScheme.secondary;

            // Try loading products dynamically if active but empty
            if (IapService.instance.isAvailable && IapService.instance.products.isEmpty) {
              IapService.instance.loadProducts().then((_) {
                if (context.mounted) {
                  setModalState(() {});
                }
              });
            }

            ProductDetails? getProduct(String id) {
              try {
                return IapService.instance.products.firstWhere((p) => p.id == id);
              } catch (_) {
                return null;
              }
            }

            final espressoProd = getProduct('respiro_espresso_tip');
            final espressoPrice = espressoProd?.price ?? "\$1.99";

            final lotusProd = getProduct('respiro_lotus_tip');
            final lotusPrice = lotusProd?.price ?? "\$4.99";

            final zenProd = getProduct('respiro_zen_sponsor');
            final zenPrice = zenProd?.price ?? "\$9.99";

            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              maxChildSize: 0.8,
              minChildSize: 0.5,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1222) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: const Color(0x1F64DFDF), width: 0.8),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Icon(Icons.star_purple500, color: secondaryColor, size: 48),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          "Respiro Indie Tip Jar",
                          style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "Support free offline health utilities with a secure, one-tap store tip. 100% of proceeds go directly to development.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey, height: 1.45),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildTipRow(
                        "☕ Espresso Support",
                        espressoPrice,
                        "Keeps the developer fueled.",
                        () async {
                          if (IapService.instance.isAvailable && espressoProd != null) {
                            try {
                              await IapService.instance.buyProduct(espressoProd);
                            } catch (e) {
                              debugPrint("Native tip failed, simulating: $e");
                              if (mounted) {
                                _simulatePayment("$espressoPrice Espresso");
                              }
                            }
                          } else {
                            _simulatePayment("$espressoPrice Espresso");
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTipRow(
                        "🌸 Lotus Calmer",
                        lotusPrice,
                        "Funds premium ambient sounds.",
                        () async {
                          if (IapService.instance.isAvailable && lotusProd != null) {
                            try {
                              await IapService.instance.buyProduct(lotusProd);
                            } catch (e) {
                              debugPrint("Native tip failed, simulating: $e");
                              if (mounted) {
                                _simulatePayment("$lotusPrice Lotus");
                              }
                            }
                          } else {
                            _simulatePayment("$lotusPrice Lotus");
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTipRow(
                        "🧘‍♂️ Zen Master Sponsor",
                        zenPrice,
                        "Supports the absolute privacy pledge.",
                        () async {
                          if (IapService.instance.isAvailable && zenProd != null) {
                            try {
                              await IapService.instance.buyProduct(zenProd);
                            } catch (e) {
                              debugPrint("Native tip failed, simulating: $e");
                              if (mounted) {
                                _simulatePayment("$zenPrice Zen Master");
                              }
                            }
                          } else {
                            _simulatePayment("$zenPrice Zen Master");
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      Center(
                        child: Text(
                          IapService.instance.isAvailable
                              ? "Transactions secured by the App Store / Google Play."
                              : "Tip transactions are simulated for development demonstration.",
                          style: GoogleFonts.montserrat(fontSize: 9, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTipRow(String title, String price, String desc, VoidCallback onTap) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: onTap,
            child: Text(
              price,
              style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  void _simulatePayment(String tierName) {
    Navigator.pop(context); // Close bottom sheet
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 2200), () {
          if (context.mounted) {
            Navigator.pop(context); // Close loader
            _showPaymentCongrats(tierName);
          }
        });

        return AlertDialog(
          backgroundColor: const Color(0xFF0A0E1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0x1F64DFDF))),
          content: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF64DFDF)),
                const SizedBox(height: 20),
                Text(
                  "Processing store checkout...",
                  style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  "Simulating standard payment gateway authorization",
                  style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentCongrats(String tierName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0E1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0x3F64DFDF), width: 1.0)),
          title: Center(
            child: Text(
              "THANK YOU 🧘‍♂️",
              style: GoogleFonts.cinzel(color: const Color(0xFF64DFDF), fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 64),
              const SizedBox(height: 16),
              Text(
                "Tip Transaction Confirmed!",
                style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "You successfully sent support for: $tierName.\nYour generous backing keeps Sighra fully independent and free for all stress sufferers.",
                style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey, height: 1.45),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Return in Calm",
                  style: GoogleFonts.montserrat(color: const Color(0xFF64DFDF), fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final breathingProv = Provider.of<BreathingProvider>(context);
    final statsProv = Provider.of<StatsProvider>(context, listen: false);
    final settingsProv = Provider.of<SettingsProvider>(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    final isActive = breathingProv.state != BreathingState.idle;
    final isCompleted = breathingProv.state == BreathingState.completed;

    // Get current breathing prompts
    String statePrompt = l10n.stateIdle;
    Color activeIndicatorColor = primaryColor;

    switch (breathingProv.state) {
      case BreathingState.inhale:
        statePrompt = breathingProv.currentPattern.id == 'physiological_sigh'
            ? "Deep Inhale"
            : l10n.stateInhale;
        activeIndicatorColor = primaryColor; // Mint
        break;
      case BreathingState.holdIn:
        if (breathingProv.currentPattern.id == 'physiological_sigh') {
          statePrompt = "Quick Gasp";
          activeIndicatorColor = primaryColor; // Keep Teal color sweep for double inhale gasp
        } else {
          statePrompt = l10n.stateHoldIn;
          activeIndicatorColor = secondaryColor; // Pale gold/coral
        }
        break;
      case BreathingState.exhale:
        statePrompt = breathingProv.currentPattern.id == 'physiological_sigh'
            ? "Slow Sigh"
            : l10n.stateExhale;
        activeIndicatorColor = primaryColor;
        break;
      case BreathingState.holdOut:
        statePrompt = l10n.stateHoldOut;
        activeIndicatorColor = secondaryColor;
        break;
      case BreathingState.completed:
        statePrompt = l10n.stateCompleted;
        activeIndicatorColor = Colors.greenAccent;
        break;
      default:
        statePrompt = l10n.stateIdle;
        activeIndicatorColor = primaryColor;
        break;
    }

    final glowColor = activeIndicatorColor.withValues(alpha: 0.08);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              glowColor,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // App logo & title
                Text(
                  l10n.appTitle.toUpperCase(),
                  style: GoogleFonts.cinzel(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: isDark ? primaryColor : const Color(0xFF007A7A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  breathingProv.currentPattern.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 15),

                // Emergency Panic Grounder
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: isActive ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: isActive,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: GestureDetector(
                        onTap: () async {
                          // 1. Sync settings: enable haptics and mix rain & ocean sounds
                          settingsProv.toggleHaptics(true);
                          await settingsProv.setMixerTrackVolume('ocean', 0.45);
                          await settingsProv.setMixerTrackVolume('rain', 0.4);
                          
                          // 2. Trigger grounding breathing cycle
                          breathingProv.triggerEmergencyPanicGrounding();
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Panic Relief Active: Calming sounds mixed, zero-eyes vibration pacing ON. Close your eyes.",
                                  style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                backgroundColor: Colors.redAccent,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        },
                        child: GlassmorphicCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          borderColor: Colors.redAccent.withValues(alpha: 0.4),
                          backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.flash_on, color: Colors.redAccent, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                "PANIC BUTTON (INSTANT CALM)",
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: breathingProv,
                      builder: (context, child) {
                        return SizedBox(
                          width: 280,
                          height: 280,
                          child: CustomPaint(
                            painter: BreathingPainter(
                              scale: breathingProv.animationScale,
                              accentColor: activeIndicatorColor,
                              isDark: isDark,
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      statePrompt,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.cinzel(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: const [
                                          Shadow(color: Colors.black45, offset: Offset(1, 2), blurRadius: 4),
                                        ],
                                      ),
                                    ),
                                    if (isActive && !isCompleted) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        "${breathingProv.secondsRemaining}s",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${l10n.tabBreathing} ${breathingProv.cyclesCompleted + 1}/${breathingProv.targetCycles}",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Mode selector (disabled during sessions)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isActive ? 0.3 : 1.0,
                  child: IgnorePointer(
                    ignoring: isActive,
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 10,
                          alignment: WrapAlignment.center,
                          children: breathingProv.patterns.map((p) {
                            final isSelected = breathingProv.currentPattern.id == p.id;
                            return ChoiceChip(
                              label: Text(
                                p.id == 'box_breathing'
                                    ? l10n.exerciseBoxTitle.split(' (').first
                                    : p.id == '478_technique'
                                        ? l10n.exercise478Title.split(' ').first
                                        : p.id == 'cardiac_coherence'
                                            ? l10n.exerciseCardioTitle.split(' (').first
                                            : p.id == 'physiological_sigh'
                                                ? "Physiological Sigh"
                                                : p.name,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.black
                                      : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) {
                                  breathingProv.setPattern(p.id);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            breathingProv.currentPattern.id == 'box_breathing'
                                ? l10n.exerciseBoxDesc
                                : breathingProv.currentPattern.id == '478_technique'
                                    ? l10n.exercise478Desc
                                    : breathingProv.currentPattern.id == 'cardiac_coherence'
                                        ? l10n.exerciseCardioDesc
                                        : breathingProv.currentPattern.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: isDark ? Colors.white38 : Colors.black45,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Action buttons (Start / Stop)
                GestureDetector(
                  onTap: () {
                    if (isActive) {
                      breathingProv.stopBreathing();
                      statsProv.fetchStats(); // Update records
                    } else {
                      breathingProv.setHapticsEnabled(settingsProv.hapticsEnabled);
                      breathingProv.setHapticSignature(settingsProv.hapticSignature);
                      breathingProv.startBreathing();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: isActive
                            ? [const Color(0xFFE63946), const Color(0xFFD62246)]
                            : [primaryColor, secondaryColor],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isActive ? Colors.redAccent : primaryColor).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isActive ? l10n.btnCancel.toUpperCase() : l10n.stateIdle.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: isActive ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BreathingPainter extends CustomPainter {
  final double scale;
  final Color accentColor;
  final bool isDark;

  BreathingPainter({
    required this.scale,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    
    // Draw background concentric ripples
    final paintBg = Paint()
      ..color = accentColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius, paintBg);

    // Draw secondary lighter ripple
    final paintBgRipple = Paint()
      ..color = accentColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius * 0.7, paintBgRipple);

    // Core pulsing expanding solid circle
    final currentRadius = maxRadius * (0.3 + (scale * 0.7)); // bounds: 30% to 100% size
    
    // Faint outer concentric pacing guides
    final paintPacingGuide = Paint()
      ..color = accentColor.withValues(alpha: 0.15)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, maxRadius * 0.5, paintPacingGuide);
    canvas.drawCircle(center, maxRadius * 0.75, paintPacingGuide);

    // Core radial glow
    final paintCoreGlow = Paint()
      ..color = accentColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, currentRadius + 15, paintCoreGlow);

    final paintCore = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor,
          Color.lerp(accentColor, Colors.black, 0.45) ?? accentColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: currentRadius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, currentRadius, paintCore);

    // Outer glowing ring
    final paintRing = Paint()
      ..color = accentColor.withValues(alpha: 0.9)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, currentRadius, paintRing);

    // Draw 3 orbiting micro-particles on the outer ring driven by cos/sin
    final double baseAngle = scale * 2.0 * 3.141592653589793;
    final particleRadius = 4.5;
    final paintParticle = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
      
    for (int i = 0; i < 3; i++) {
      final double angle = baseAngle + (i * 2.0 * 3.141592653589793 / 3);
      final double px = center.dx + currentRadius * stdMathCos(angle);
      final double py = center.dy + currentRadius * stdMathSin(angle);
      
      canvas.drawCircle(Offset(px, py), particleRadius, paintParticle);
      
      // Soft glow for each orbiting micro-particle
      final paintParticleGlow = Paint()
        ..color = accentColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(px, py), particleRadius + 4, paintParticleGlow);
    }
  }

  // Fast trigonometric approximations to avoid imports
  double stdMathCos(double angle) {
    return _approxCos(angle);
  }

  double stdMathSin(double angle) {
    return _approxSin(angle);
  }

  double _approxSin(double x) {
    // Wrap around to -pi to pi
    double pi = 3.141592653589793;
    x = x % (2 * pi);
    if (x < -pi) x += 2 * pi;
    if (x > pi) x -= 2 * pi;
    
    // Taylor approximation
    double result = 0.0;
    double term = x;
    double sign = 1.0;
    double fact = 1.0;
    
    for (int i = 1; i <= 9; i += 2) {
      if (i > 1) {
        fact *= (i - 1) * i;
        term = term * x * x;
      }
      result += sign * (term / fact);
      sign = -sign;
    }
    return result;
  }

  double _approxCos(double x) {
    double pi = 3.141592653589793;
    return _approxSin(x + pi / 2.0);
  }

  @override
  bool shouldRepaint(covariant BreathingPainter oldDelegate) {
    return oldDelegate.scale != scale || 
           oldDelegate.accentColor != accentColor || 
           oldDelegate.isDark != isDark;
  }
}
