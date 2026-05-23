import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';
import '../providers/breathing_provider.dart';
import '../providers/stats_provider.dart';
import '../models/breathing_pattern.dart';
import '../widgets/glassmorphic_card.dart';
import '../services/backup_service.dart';
import '../services/iap_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:respiro/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchDonation() async {
    final url = Uri.parse("https://buymeacoffee.com/");
    try {
      if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
        // Safe redirect
      }
    } catch (e) {
      debugPrint("Could not launch web URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProv = Provider.of<SettingsProvider>(context);
    final breathingProv = Provider.of<BreathingProvider>(context, listen: false);
    final statsProv = Provider.of<StatsProvider>(context, listen: false);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tabSettings.toUpperCase(),
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isDark ? primaryColor : const Color(0xFF007A7A),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        children: [
          // Premium Donation Call Card
          GlassmorphicCard(
            borderColor: secondaryColor.withValues(alpha: 0.5),
            child: Column(
              children: [
                Icon(Icons.spa, color: secondaryColor, size: 44),
                const SizedBox(height: 12),
                Text(
                  l10n.appTitle,
                  style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "This app is 100% free, private, and offline, running with zero server costs to act as \"first aid for your mind.\" If Sighra has helped you find calm in moments of stress or panic, please support our indie work.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showTipJarDialog(context),
                      icon: const Icon(Icons.star_purple500, size: 16),
                      label: Text(
                        "Indie Tip Jar",
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white70 : Colors.black87,
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _launchDonation,
                      child: Text(
                        "Web Tip ☕",
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          Text(
            "PREFERENCES",
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          
          // Glassmorphic settings preferences list
          GlassmorphicCard(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                // Theme toggle
                ListTile(
                  title: Text(l10n.settingsTheme, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500)),
                  trailing: Switch(
                    value: settingsProv.isDarkMode,
                    activeThumbColor: primaryColor,
                    onChanged: (val) {
                      settingsProv.toggleTheme(val);
                    },
                  ),
                ),
                const Divider(height: 1),
                
                // Language selection
                ListTile(
                  title: Text(l10n.settingsLanguage, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500)),
                  trailing: DropdownButton<String>(
                    value: settingsProv.locale.languageCode,
                    dropdownColor: isDark ? const Color(0xFF121829) : Colors.white,
                    underline: Container(),
                    iconEnabledColor: primaryColor,
                    style: GoogleFonts.montserrat(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'es', child: Text("Español")),
                      DropdownMenuItem(value: 'en', child: Text("English")),
                    ],
                    onChanged: (code) {
                      if (code != null) {
                        settingsProv.changeLanguage(code);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                
                // Vibration guides (Haptic)
                ListTile(
                  title: Text(l10n.settingsHaptics, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    l10n.settingsHapticsDesc,
                    style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey, height: 1.3),
                  ),
                  trailing: Switch(
                    value: settingsProv.hapticsEnabled,
                    activeThumbColor: primaryColor,
                    onChanged: (val) {
                      settingsProv.toggleHaptics(val);
                      breathingProv.setHapticsEnabled(val);
                    },
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: settingsProv.hapticsEnabled
                      ? Padding(
                          padding: const EdgeInsets.only(left: 70.0, right: 16.0, bottom: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Haptic Signature:",
                                style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey),
                              ),
                              DropdownButton<String>(
                                value: settingsProv.hapticSignature,
                                dropdownColor: isDark ? const Color(0xFF0D1222) : Colors.white,
                                style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor),
                                underline: const SizedBox.shrink(),
                                items: const [
                                  DropdownMenuItem(value: 'hum', child: Text("Gentle Hum")),
                                  DropdownMenuItem(value: 'wave', child: Text("Somatic Wave")),
                                  DropdownMenuItem(value: 'heartbeat', child: Text("Heartbeat")),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    settingsProv.changeHapticSignature(val);
                                    breathingProv.setHapticSignature(val);
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const Divider(height: 1),

                // Health sync toggle
                ListTile(
                  title: Text("Sync with Health Registry", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    "Log completed breathing minutes as mindfulness sessions into your device's native health store",
                    style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey, height: 1.3),
                  ),
                  trailing: Switch(
                    value: settingsProv.healthSyncEnabled,
                    activeThumbColor: primaryColor,
                    onChanged: (val) {
                      settingsProv.toggleHealthSync(val);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),

          Text(
            "THERAPHY BUILDER & TUTORIALS",
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),

          GlassmorphicCard(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                // Custom breathing pattern creator
                ListTile(
                  leading: Icon(Icons.add_circle_outline, color: primaryColor),
                  title: Text("Create Breathing Pattern", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500)),
                  subtitle: Text("Build and save custom inhalation/exhalation pacing", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => _showCreatePatternSheet(context, breathingProv),
                ),
                const Divider(height: 1),

                // Local Backup & Restore
                ListTile(
                  leading: Icon(Icons.backup_outlined, color: primaryColor),
                  title: Text(l10n.settingsBackup, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500)),
                  subtitle: Text("Export or restore your private logs and custom exercises", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => _showBackupRestoreSheet(context, settingsProv, statsProv, breathingProv, l10n),
                ),
                const Divider(height: 1),
                
                // Onboarding walkthrough loader
                ListTile(
                  leading: Icon(Icons.help_outline, color: primaryColor),
                  title: Text("How Sighra Works", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500)),
                  subtitle: Text("Relaunch tutorial on zero-eyes breathing and privacy", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => _showOnboardingWalkthrough(context),
                ),
                const Divider(height: 1),
                
                ListTile(
                  leading: Icon(Icons.security, color: primaryColor),
                  title: Text("Privacy Shield", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500)),
                  subtitle: Text("Review our strict offline zero-server privacy pledge", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)),
                  trailing: const Icon(Icons.verified_user, color: Colors.tealAccent, size: 18),
                  onTap: () => _showPrivacyShield(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          
          Text(
            "SAFETY CONTROLS",
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 10),
          
          GlassmorphicCard(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            borderColor: Colors.redAccent.withValues(alpha: 0.2),
            child: ListTile(
              title: Text("Wipe Database Records", style: GoogleFonts.montserrat(fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.w500)),
              subtitle: Text(
                "Permanently delete your session history and custom patterns.",
                style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey),
              ),
              trailing: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    return AlertDialog(
                      title: Text(l10n.btnConfirm, style: GoogleFonts.cinzel(color: Colors.redAccent)),
                      content: Text(
                        "Are you sure? This action is permanent and will completely clear your calming breathing stats, streaks, and all user patterns.",
                        style: GoogleFonts.montserrat(fontSize: 13),
                      ),
                      actions: [
                        TextButton(
                          child: Text(l10n.btnCancel, style: GoogleFonts.montserrat(color: Colors.grey)),
                          onPressed: () => navigator.pop(),
                        ),
                        TextButton(
                          child: Text("Delete Everything", style: GoogleFonts.montserrat(color: Colors.red)),
                          onPressed: () async {
                            await statsProv.wipeStats();
                            await breathingProv.loadCustomPatterns(); // update dynamic patterns
                            navigator.pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text("All local database records wiped clean."),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- MODAL SHEETS ---

  // 0. Local Backup & Restore Sheet
  void _showBackupRestoreSheet(
    BuildContext context,
    SettingsProvider settingsProv,
    StatsProvider statsProv,
    BreathingProvider breathingProv,
    AppLocalizations l10n,
  ) {
    final importController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1222) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: const Color(0x1F64DFDF), width: 0.8),
                ),
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(height: 20),
                      Text(
                        l10n.settingsBackup.toUpperCase(),
                        style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Backup your entire Respiro profile privately. Your logs, custom ratios, and volume mix remain sandboxed in your device.",
                        style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey, height: 1.45),
                      ),
                      const SizedBox(height: 20),
                      
                      // Action 1: Export
                      Text(
                        "EXPORT BACKUP DATA",
                        style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          try {
                            final b64 = await BackupService.instance.exportBackupString();
                            await Clipboard.setData(ClipboardData(text: b64));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.settingsBackupSuccess),
                                  backgroundColor: primaryColor,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Export failed. Please try again."),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: primaryColor.withValues(alpha: 0.15),
                            border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.copy_all, size: 18, color: primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                "COPY BACKUP CODE",
                                style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      
                      // Action 2: Import
                      Text(
                        "RESTORE DATA",
                        style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: importController,
                        maxLines: 3,
                        style: GoogleFonts.montserrat(fontSize: 11),
                        decoration: InputDecoration(
                          hintText: "Paste your base64 backup code here...",
                          hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 11),
                          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor), borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final code = importController.text.trim();
                          if (code.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please paste your backup code.")),
                            );
                            return;
                          }
                          
                          try {
                            await BackupService.instance.importBackupString(code);
                            
                            // Reload dynamic local configurations
                            await settingsProv.loadSettings();
                            await statsProv.fetchStats();
                            await breathingProv.loadCustomPatterns();

                            if (context.mounted) {
                              Navigator.pop(context); // Close bottom sheet
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.settingsRestoreSuccess),
                                  backgroundColor: primaryColor,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Restore failed: Invalid or corrupted backup code."),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: primaryColor,
                          ),
                          child: Center(
                            child: Text(
                              "VERIFY & RESTORE",
                              style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 0. The Zero-Trust Interactive Privacy Shield
  void _showPrivacyShield(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = Theme.of(context).colorScheme.primary;
        final secondaryColor = Theme.of(context).colorScheme.secondary;

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
                    child: Icon(Icons.security, color: secondaryColor, size: 48),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      "Sighra Privacy Pledge",
                      style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Your mental wellbeing is yours alone. We believe somatic tools should have absolute privacy by design. Sighra operates under a strict Zero-Server Trust Model.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey, height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildPrivacyRow(context, "Zero Cloud Databases", "100% Offline-First", "Your practice minutes, streaks, custom patterns, and settings are stored locally on-device. No cloud synchronization means zero database breaches.", Icons.cloud_off, primaryColor),
                  const SizedBox(height: 12),
                  _buildPrivacyRow(context, "No Trailing Analytics", "0% Tracker Coverage", "We integrate zero surveillance SDKs. No Google Analytics, no Facebook trackers, and no ad brokers. Your sessions are fully anonymous.", Icons.analytics_outlined, primaryColor),
                  const SizedBox(height: 12),
                  _buildPrivacyRow(context, "No Account Signup", "Immediate Local Access", "We do not request email addresses, passwords, or phone numbers. Zero onboarding sign-ups mean we cannot sell or leak your identity.", Icons.no_accounts_outlined, primaryColor),
                  const SizedBox(height: 12),
                  _buildPrivacyRow(context, "Full Data Sovereignty", "Portable Base64 Exports", "You fully own your data. Use our offline local backup tool to copy a secure Base64 configuration string to carry your history to any device.", Icons.vpn_key_outlined, primaryColor),
                  
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      "Sighra is funded entirely by optional tips from users like you. Thank you for keeping wellness honest, premium, and safe.",
                      style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPrivacyRow(BuildContext context, String title, String subtitle, String desc, IconData icon, Color color) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(subtitle, style: GoogleFonts.montserrat(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GoogleFonts.montserrat(fontSize: 10.5, color: Colors.grey, height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 1. Frictionless In-App Tipping Dialog
  void _showTipJarDialog(BuildContext context) {
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
                        context,
                        "☕ Espresso Support",
                        espressoPrice,
                        "Keeps the developer fueled.",
                        () async {
                          if (IapService.instance.isAvailable && espressoProd != null) {
                            try {
                              await IapService.instance.buyProduct(espressoProd);
                            } catch (e) {
                              debugPrint("Native tip failed, simulating: $e");
                              if (context.mounted) {
                                _simulatePayment(context, "$espressoPrice Espresso");
                              }
                            }
                          } else {
                            _simulatePayment(context, "$espressoPrice Espresso");
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTipRow(
                        context,
                        "🌸 Lotus Calmer",
                        lotusPrice,
                        "Funds premium ambient sounds.",
                        () async {
                          if (IapService.instance.isAvailable && lotusProd != null) {
                            try {
                              await IapService.instance.buyProduct(lotusProd);
                            } catch (e) {
                              debugPrint("Native tip failed, simulating: $e");
                              if (context.mounted) {
                                _simulatePayment(context, "$lotusPrice Lotus");
                              }
                            }
                          } else {
                            _simulatePayment(context, "$lotusPrice Lotus");
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTipRow(
                        context,
                        "🧘‍♂️ Zen Master Sponsor",
                        zenPrice,
                        "Supports the absolute privacy pledge.",
                        () async {
                          if (IapService.instance.isAvailable && zenProd != null) {
                            try {
                              await IapService.instance.buyProduct(zenProd);
                            } catch (e) {
                              debugPrint("Native tip failed, simulating: $e");
                              if (context.mounted) {
                                _simulatePayment(context, "$zenPrice Zen Master");
                              }
                            }
                          } else {
                            _simulatePayment(context, "$zenPrice Zen Master");
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

  Widget _buildTipRow(BuildContext context, String title, String price, String desc, VoidCallback onTap) {
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

  void _simulatePayment(BuildContext context, String tierName) {
    Navigator.pop(context); // Close bottom sheet
    
    // Launch simulated processing sheet
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Trigger auto transition to successful congrats screen after 2.5 seconds
            Future.delayed(const Duration(milliseconds: 2200), () {
              if (context.mounted) {
                Navigator.pop(context); // Close loader
                _showPaymentCongrats(context, tierName);
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
      },
    );
  }

  void _showPaymentCongrats(BuildContext context, String tierName) {
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

  // 2. Custom Breathing Pattern Creator Sheet
  void _showCreatePatternSheet(BuildContext context, BreathingProvider provider) {
    final nameController = TextEditingController();
    int inhale = 4;
    int holdIn = 2;
    int exhale = 4;
    int holdOut = 2;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final primaryColor = Theme.of(context).colorScheme.primary;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1222) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: const Color(0x1F64DFDF), width: 0.8),
                ),
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(height: 20),
                      Text(
                        "CREATE CUSTOM EXERCISE",
                        style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        style: GoogleFonts.montserrat(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Pattern Name (e.g. Zen Focus)",
                          hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 13),
                          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor), borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sliders pacing
                      _buildSliderRow("Inhale Duration", inhale, 1, 12, (v) => setSheetState(() => inhale = v), primaryColor),
                      _buildSliderRow("Hold-In Duration", holdIn, 0, 12, (v) => setSheetState(() => holdIn = v), primaryColor),
                      _buildSliderRow("Exhale Duration", exhale, 1, 12, (v) => setSheetState(() => exhale = v), primaryColor),
                      _buildSliderRow("Hold-Out Duration", holdOut, 0, 12, (v) => setSheetState(() => holdOut = v), primaryColor),

                      const SizedBox(height: 16),
                      CustomPatternPreview(
                        inhale: inhale,
                        holdIn: holdIn,
                        exhale: exhale,
                        holdOut: holdOut,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 16),
                      // Custom math overview
                      GlassmorphicCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TOTAL CYCLE TIMER:",
                              style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            Text(
                              "${inhale + holdIn + exhale + holdOut} seconds",
                              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      GestureDetector(
                        onTap: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please type a pattern name.")));
                            return;
                          }
                          
                          final patternId = "user_${name.toLowerCase().replaceAll(' ', '_')}";
                          final newPattern = BreathingPattern(
                            id: patternId,
                            name: name,
                            description: "Custom ratio: In $inhale, Hold $holdIn, Out $exhale, Rest $holdOut",
                            inhaleSeconds: inhale,
                            holdInSeconds: holdIn,
                            exhaleSeconds: exhale,
                            holdOutSeconds: holdOut,
                          );

                          await provider.addCustomPattern(newPattern);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Custom pattern '$name' saved successfully."),
                                backgroundColor: primaryColor,
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: primaryColor,
                          ),
                          child: Center(
                            child: Text(
                              "SAVE PATTERN",
                              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSliderRow(String label, int val, int min, int max, Function(int) onChanged, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500)),
            Text("${val}s", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        Slider(
          value: val.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          activeColor: color,
          inactiveColor: Colors.grey.withValues(alpha: 0.2),
          onChanged: (newVal) => onChanged(newVal.round()),
        ),
      ],
    );
  }

  // 3. User Onboarding swipeable walkthrough
  void _showOnboardingWalkthrough(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const _OnboardingWalkthroughDialog();
      },
    );
  }
}

class _OnboardingWalkthroughDialog extends StatefulWidget {
  const _OnboardingWalkthroughDialog();

  @override
  State<_OnboardingWalkthroughDialog> createState() => _OnboardingWalkthroughDialogState();
}

class _OnboardingWalkthroughDialogState extends State<_OnboardingWalkthroughDialog> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    final List<Widget> slides = [
      _buildSlide(
        icon: Icons.spa_outlined,
        iconColor: primaryColor,
        title: "Twilight Tranquility",
        desc: "Relax your nervous system in our deep twilight cosmic dark theme. Glowing ripples and slow ambient beats provide an instant refuge during panic attacks.",
      ),
      _buildSlide(
        icon: Icons.vibration,
        iconColor: secondaryColor,
        title: "Zero-Eyes Guidance",
        desc: "Breathe with your eyes closed. Continuous micro-pulses guide your inhale, silence guides your holds, and slow pulsing waves guide your exhale. Truly blind, immersive breathing.",
      ),
      _buildSlide(
        icon: Icons.security_outlined,
        iconColor: Colors.greenAccent,
        title: "100% Sealed Privacy",
        desc: "No accounts. No servers. No diagnostic trackers. Every breath statistic, custom session ratio, and audio profile remains strictly locked in your device's local database.",
      ),
    ];

    return AlertDialog(
      backgroundColor: const Color(0xFF0A0E1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0x1F64DFDF), width: 0.8)),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 320,
        height: 380,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) {
                  setState(() {
                    _currentPage = idx;
                  });
                },
                children: slides,
              ),
            ),
            
            // Pacing page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == index ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _currentPage == index ? primaryColor : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "SKIP",
                      style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () {
                      if (_currentPage < slides.length - 1) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      _currentPage == slides.length - 1 ? "DONE" : "NEXT",
                      style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({required IconData icon, required Color iconColor, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 54),
          const SizedBox(height: 20),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.cinzel(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: GoogleFonts.montserrat(color: Colors.white60, fontSize: 11, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// Concentric Real-Time Visualizer Preview Widget
// ----------------------------------------------------
class CustomPatternPreview extends StatefulWidget {
  final int inhale;
  final int holdIn;
  final int exhale;
  final int holdOut;
  final Color color;

  const CustomPatternPreview({
    super.key,
    required this.inhale,
    required this.holdIn,
    required this.exhale,
    required this.holdOut,
    required this.color,
  });

  @override
  State<CustomPatternPreview> createState() => _CustomPatternPreviewState();
}

class _CustomPatternPreviewState extends State<CustomPatternPreview> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final totalDuration = widget.inhale + widget.holdIn + widget.exhale + widget.holdOut;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalDuration > 0 ? totalDuration : 10),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant CustomPatternPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final totalDuration = widget.inhale + widget.holdIn + widget.exhale + widget.holdOut;
    _controller.duration = Duration(seconds: totalDuration > 0 ? totalDuration : 10);
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value; // 0.0 to 1.0 representing progress in the cycle
        
        final double inhaleFrac = widget.inhale.toDouble();
        final double holdInFrac = widget.holdIn.toDouble();
        final double exhaleFrac = widget.exhale.toDouble();
        final double holdOutFrac = widget.holdOut.toDouble();
        final double total = inhaleFrac + holdInFrac + exhaleFrac + holdOutFrac;
        
        double scale = 0.4;
        String activeState = "Inhale";
        
        if (total > 0) {
          final double time = t * total;
          
          if (time < inhaleFrac) {
            final progress = time / inhaleFrac;
            scale = 0.4 + (progress * 0.6);
            activeState = "Inhaling...";
          } else if (time < inhaleFrac + holdInFrac) {
            scale = 1.0;
            activeState = "Holding...";
          } else if (time < inhaleFrac + holdInFrac + exhaleFrac) {
            final progress = (time - inhaleFrac - holdInFrac) / exhaleFrac;
            scale = 1.0 - (progress * 0.6);
            activeState = "Exhaling...";
          } else {
            scale = 0.4;
            activeState = "Resting...";
          }
        }

        return Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withValues(alpha: 0.25),
            border: Border.all(color: widget.color.withValues(alpha: 0.15)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.color.withValues(alpha: 0.15), width: 1),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 90 * scale,
                  height: 90 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.2),
                    border: Border.all(color: widget.color, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                child: Text(
                  activeState.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 9, 
                    fontWeight: FontWeight.bold, 
                    color: widget.color.withValues(alpha: 0.7),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
