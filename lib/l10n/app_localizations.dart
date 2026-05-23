import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Sighra'**
  String get appTitle;

  /// No description provided for @tabBreathing.
  ///
  /// In en, this message translates to:
  /// **'Breathe'**
  String get tabBreathing;

  /// No description provided for @tabStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get tabStats;

  /// No description provided for @tabSounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get tabSounds;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @exerciseBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Box Breathing (4-4-4-4)'**
  String get exerciseBoxTitle;

  /// No description provided for @exerciseBoxDesc.
  ///
  /// In en, this message translates to:
  /// **'Equal duration inhale, hold, exhale, and hold for deep neural balance.'**
  String get exerciseBoxDesc;

  /// No description provided for @exercise478Title.
  ///
  /// In en, this message translates to:
  /// **'4-7-8 Technique'**
  String get exercise478Title;

  /// No description provided for @exercise478Desc.
  ///
  /// In en, this message translates to:
  /// **'Dr. Weil\'s natural tranquilizer for the nervous system, helpful for sleep.'**
  String get exercise478Desc;

  /// No description provided for @exerciseCardioTitle.
  ///
  /// In en, this message translates to:
  /// **'Cardiac Coherence (5-5)'**
  String get exerciseCardioTitle;

  /// No description provided for @exerciseCardioDesc.
  ///
  /// In en, this message translates to:
  /// **'Stabilizes heart rate, reduces cortisol levels and general stress.'**
  String get exerciseCardioDesc;

  /// No description provided for @stateIdle.
  ///
  /// In en, this message translates to:
  /// **'Tap to Start'**
  String get stateIdle;

  /// No description provided for @stateInhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get stateInhale;

  /// No description provided for @stateHoldIn.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get stateHoldIn;

  /// No description provided for @stateExhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get stateExhale;

  /// No description provided for @stateHoldOut.
  ///
  /// In en, this message translates to:
  /// **'Rest & Hold'**
  String get stateHoldOut;

  /// No description provided for @stateCompleted.
  ///
  /// In en, this message translates to:
  /// **'Well Done'**
  String get stateCompleted;

  /// No description provided for @statsHeader.
  ///
  /// In en, this message translates to:
  /// **'Calm Stats'**
  String get statsHeader;

  /// No description provided for @statsMinutesBreathed.
  ///
  /// In en, this message translates to:
  /// **'Total Minutes'**
  String get statsMinutesBreathed;

  /// No description provided for @statsSessionsCount.
  ///
  /// In en, this message translates to:
  /// **'Sessions Done'**
  String get statsSessionsCount;

  /// No description provided for @statsActiveStreak.
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get statsActiveStreak;

  /// No description provided for @statsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Calming Sessions'**
  String get statsHistoryTitle;

  /// No description provided for @statsEmptyHistory.
  ///
  /// In en, this message translates to:
  /// **'No breathing sessions logged. Practice now to find calm.'**
  String get statsEmptyHistory;

  /// No description provided for @soundTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus Sounds'**
  String get soundTitle;

  /// No description provided for @soundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'High-fidelity ambient noise mixer, available completely offline.'**
  String get soundSubtitle;

  /// No description provided for @soundBrownNoise.
  ///
  /// In en, this message translates to:
  /// **'Brown Noise'**
  String get soundBrownNoise;

  /// No description provided for @soundOcean.
  ///
  /// In en, this message translates to:
  /// **'Calm Ocean'**
  String get soundOcean;

  /// No description provided for @soundRain.
  ///
  /// In en, this message translates to:
  /// **'Forest Rain'**
  String get soundRain;

  /// No description provided for @soundPinkNoise.
  ///
  /// In en, this message translates to:
  /// **'Pink Noise'**
  String get soundPinkNoise;

  /// No description provided for @soundSolfeggio.
  ///
  /// In en, this message translates to:
  /// **'Solfeggio 528 Hz'**
  String get soundSolfeggio;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance (Dark Mode)'**
  String get settingsTheme;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Vibration Guides'**
  String get settingsHaptics;

  /// No description provided for @settingsHapticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Pulse guides during state transitions for zero-eyes breathing.'**
  String get settingsHapticsDesc;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Sighra'**
  String get settingsAbout;

  /// No description provided for @settingsDonate.
  ///
  /// In en, this message translates to:
  /// **'Support Sighra (Buy Me a Coffee)'**
  String get settingsDonate;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Local Backup & Restore'**
  String get settingsBackup;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// No description provided for @btnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btnConfirm;

  /// No description provided for @btnBuyCoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee ☕'**
  String get btnBuyCoffee;

  /// No description provided for @settingsBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get settingsBackupSuccess;

  /// No description provided for @settingsRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully'**
  String get settingsRestoreSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
