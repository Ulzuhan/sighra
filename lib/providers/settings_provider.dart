import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/audio_service.dart';
import '../services/health_sync_service.dart';

class SettingsProvider with ChangeNotifier {
  final _prefs = PreferencesService.instance;
  final _audio = AudioService.instance;

  Locale _locale = const Locale('en');
  bool _isDarkMode = true;
  bool _hapticsEnabled = true;
  String _hapticSignature = 'hum';
  String _activeAudioTrack = 'none';
  double _ambientVolume = 0.5;
  bool _healthSyncEnabled = false;

  // Multi-track focus mixer state
  final Map<String, double> _trackVolumes = {
    'brown_noise': 0.0,
    'ocean': 0.0,
    'rain': 0.0,
    'pink_noise': 0.0,
    'solfeggio': 0.0,
  };

  Locale get locale => _locale;
  bool get isDarkMode => _isDarkMode;
  bool get hapticsEnabled => _hapticsEnabled;
  String get hapticSignature => _hapticSignature;
  String get activeAudioTrack => _activeAudioTrack;
  double get ambientVolume => _ambientVolume;
  bool get healthSyncEnabled => _healthSyncEnabled;
  Map<String, double> get trackVolumes => _trackVolumes;

  // Load preferences saved locally
  Future<void> loadSettings() async {
    final lang = await _prefs.getLanguageLocale();
    _locale = Locale(lang);

    _isDarkMode = await _prefs.getDarkMode();
    _hapticsEnabled = await _prefs.getHapticsEnabled();
    _hapticSignature = await _prefs.getHapticSignature();
    _healthSyncEnabled = await HealthSyncService.instance.isHealthSyncEnabled();
    
    // Load and sync individual mixer tracks
    for (final track in _trackVolumes.keys) {
      final vol = await _prefs.getTrackVolume(track);
      _trackVolumes[track] = vol;
      await _audio.setTrackVolume(track, vol);
    }
    
    // Sync fallback legacy parameters
    _activeAudioTrack = _audio.currentTrack;
    _ambientVolume = _audio.volume;
    
    notifyListeners();
  }

  // Toggle language locale
  Future<void> changeLanguage(String langCode) async {
    _locale = Locale(langCode);
    await _prefs.setLanguageLocale(langCode);
    notifyListeners();
  }

  // Toggle Dark Mode appearance
  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    await _prefs.setDarkMode(value);
    notifyListeners();
  }

  // Toggle Haptic Guides
  Future<void> toggleHaptics(bool value) async {
    _hapticsEnabled = value;
    await _prefs.setHapticsEnabled(value);
    notifyListeners();
  }

  // Change Somatic Haptic Pattern Signature
  Future<void> changeHapticSignature(String signature) async {
    _hapticSignature = signature;
    await _prefs.setHapticSignature(signature);
    notifyListeners();
  }

  // Set/Adjust specific mixer loop track volume
  Future<void> setMixerTrackVolume(String trackId, double val) async {
    final cleanVal = val.clamp(0.0, 1.0);
    _trackVolumes[trackId] = cleanVal;
    await _prefs.setTrackVolume(trackId, cleanVal);
    await _audio.setTrackVolume(trackId, cleanVal);
    
    _activeAudioTrack = _audio.currentTrack;
    _ambientVolume = _audio.volume;
    notifyListeners();
  }

  // Toggle/Set Active focus sound loops (Preset selections)
  Future<void> setAudioTrack(String trackId) async {
    _activeAudioTrack = trackId;
    await _prefs.setAudioTrack(trackId);
    
    if (trackId == 'none') {
      for (final track in _trackVolumes.keys) {
        _trackVolumes[track] = 0.0;
        await _prefs.setTrackVolume(track, 0.0);
        await _audio.setTrackVolume(track, 0.0);
      }
    } else {
      // Set chosen preset to 0.4 and silence others for quick, clean preset load
      for (final track in _trackVolumes.keys) {
        final targetVal = (track == trackId) ? 0.4 : 0.0;
        _trackVolumes[track] = targetVal;
        await _prefs.setTrackVolume(track, targetVal);
        await _audio.setTrackVolume(track, targetVal);
      }
    }
    notifyListeners();
  }

  // Adjust volume levels (Legacy support: updates all active mixer volumes)
  Future<void> setAmbientVolume(double val) async {
    _ambientVolume = val.clamp(0.0, 1.0);
    final activeTracks = _trackVolumes.entries.where((e) => e.value > 0.0).map((e) => e.key).toList();
    for (final trackId in activeTracks) {
      await setMixerTrackVolume(trackId, _ambientVolume);
    }
    notifyListeners();
  }

  // Toggle Health Registry Synchronization
  Future<void> toggleHealthSync(bool value) async {
    _healthSyncEnabled = value;
    await HealthSyncService.instance.setHealthSyncEnabled(value);
    notifyListeners();
  }
}
