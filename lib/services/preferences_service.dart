import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._privateConstructor();
  static final PreferencesService instance = PreferencesService._privateConstructor();

  static const String _keyPatternId = 'breathing_pattern_id';
  static const String _keyAudioTrack = 'ambient_audio_track';
  static const String _keyHapticsEnabled = 'haptics_enabled';
  static const String _keyDarkMode = 'is_dark_mode';
  static const String _keyLanguage = 'language_locale';
  static const String _keyHapticSignature = 'haptic_signature';

  // Get active breathing pattern
  Future<String> getPatternId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPatternId) ?? 'box_breathing';
  }

  Future<void> setPatternId(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPatternId, value);
  }

  // Get active background sound track selection
  Future<String> getAudioTrack() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAudioTrack) ?? 'none';
  }

  Future<void> setAudioTrack(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAudioTrack, value);
  }

  // Check if vibration guides are enabled
  Future<bool> getHapticsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHapticsEnabled) ?? true;
  }

  Future<void> setHapticsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHapticsEnabled, value);
  }

  // Check if dark mode theme is enabled
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? true;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  // Get language code locale (e.g. 'en', 'es')
  Future<String> getLanguageLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'en';
  }

  Future<void> setLanguageLocale(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, value);
  }

  // Get track volume (defaults to 0.0 for mixer except brown_noise which starts at 0.4 for standard demo)
  Future<double> getTrackVolume(String trackId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('track_volume_$trackId') ?? (trackId == 'brown_noise' ? 0.4 : 0.0);
  }

  Future<void> setTrackVolume(String trackId, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('track_volume_$trackId', value);
  }

  // Get active somatic haptic pattern signature
  Future<String> getHapticSignature() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyHapticSignature) ?? 'hum';
  }

  Future<void> setHapticSignature(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHapticSignature, value);
  }
}
