// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sighra';

  @override
  String get tabBreathing => 'Breathe';

  @override
  String get tabStats => 'Stats';

  @override
  String get tabSounds => 'Sounds';

  @override
  String get tabSettings => 'Settings';

  @override
  String get exerciseBoxTitle => 'Box Breathing (4-4-4-4)';

  @override
  String get exerciseBoxDesc =>
      'Equal duration inhale, hold, exhale, and hold for deep neural balance.';

  @override
  String get exercise478Title => '4-7-8 Technique';

  @override
  String get exercise478Desc =>
      'Dr. Weil\'s natural tranquilizer for the nervous system, helpful for sleep.';

  @override
  String get exerciseCardioTitle => 'Cardiac Coherence (5-5)';

  @override
  String get exerciseCardioDesc =>
      'Stabilizes heart rate, reduces cortisol levels and general stress.';

  @override
  String get stateIdle => 'Tap to Start';

  @override
  String get stateInhale => 'Inhale';

  @override
  String get stateHoldIn => 'Hold';

  @override
  String get stateExhale => 'Exhale';

  @override
  String get stateHoldOut => 'Rest & Hold';

  @override
  String get stateCompleted => 'Well Done';

  @override
  String get statsHeader => 'Calm Stats';

  @override
  String get statsMinutesBreathed => 'Total Minutes';

  @override
  String get statsSessionsCount => 'Sessions Done';

  @override
  String get statsActiveStreak => 'Daily Streak';

  @override
  String get statsHistoryTitle => 'Recent Calming Sessions';

  @override
  String get statsEmptyHistory =>
      'No breathing sessions logged. Practice now to find calm.';

  @override
  String get soundTitle => 'Focus Sounds';

  @override
  String get soundSubtitle =>
      'High-fidelity ambient noise mixer, available completely offline.';

  @override
  String get soundBrownNoise => 'Brown Noise';

  @override
  String get soundOcean => 'Calm Ocean';

  @override
  String get soundRain => 'Forest Rain';

  @override
  String get soundPinkNoise => 'Pink Noise';

  @override
  String get soundSolfeggio => 'Solfeggio 528 Hz';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Appearance (Dark Mode)';

  @override
  String get settingsHaptics => 'Vibration Guides';

  @override
  String get settingsHapticsDesc =>
      'Pulse guides during state transitions for zero-eyes breathing.';

  @override
  String get settingsAbout => 'About Sighra';

  @override
  String get settingsDonate => 'Support Sighra (Buy Me a Coffee)';

  @override
  String get settingsBackup => 'Local Backup & Restore';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnSave => 'Save';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnConfirm => 'Confirm';

  @override
  String get btnBuyCoffee => 'Buy me a coffee ☕';

  @override
  String get settingsBackupSuccess => 'Data exported successfully';

  @override
  String get settingsRestoreSuccess => 'Data restored successfully';
}
