import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioService._privateConstructor() {
    _initPlayers();
  }
  static final AudioService instance = AudioService._privateConstructor();

  final Map<String, AudioPlayer> _players = {};
  final Map<String, double> _volumes = {};
  bool _isInitialized = false;

  void _initPlayers() {
    try {
      final tracks = ['brown_noise', 'ocean', 'rain', 'pink_noise', 'solfeggio'];
      for (final track in tracks) {
        final player = AudioPlayer();
        player.setLoopMode(LoopMode.one);
        player.setVolume(0.0);
        _players[track] = player;
        _volumes[track] = 0.0;
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint("Audio init exception: $e");
    }
  }

  // Adjust volume of a specific loop and handle play/stop states
  Future<void> setTrackVolume(String trackId, double volume) async {
    if (!_isInitialized) return;
    try {
      final player = _players[trackId];
      if (player == null) return;

      final cleanVol = volume.clamp(0.0, 1.0);
      _volumes[trackId] = cleanVol;

      if (cleanVol > 0.0) {
        await player.setVolume(cleanVol);
        if (!player.playing) {
          final assetPath = 'assets/sounds/$trackId.mp3';
          try {
            await player.setAsset(assetPath);
            await player.play();
          } catch (e) {
            debugPrint("Error loading focus loop '$trackId': $e. (Please make sure asset exists. Catching defensively.)");
          }
        }
      } else {
        await player.stop();
      }
    } catch (e) {
      debugPrint("Error setting track volume for '$trackId': $e");
    }
  }

  // Stop all ambient playback
  Future<void> stopAll() async {
    if (!_isInitialized) return;
    for (final entry in _players.entries) {
      try {
        await entry.value.stop();
        _volumes[entry.key] = 0.0;
      } catch (e) {
        debugPrint("Audio stop exception: $e");
      }
    }
  }

  // Legacy method support to keep other dependencies running without breakages
  Future<void> playTrack(String trackId) async {
    await stopAll();
    if (trackId != 'none') {
      await setTrackVolume(trackId, 0.4);
    }
  }

  Future<void> setVolume(double value) async {
    // Legacy behavior: adjusts volume of the active track(s)
    if (!_isInitialized) return;
    final activeTracks = _volumes.entries.where((e) => e.value > 0.0).map((e) => e.key).toList();
    for (final trackId in activeTracks) {
      await setTrackVolume(trackId, value);
    }
  }

  Future<void> stop() async {
    await stopAll();
  }

  String get currentTrack {
    final active = _volumes.entries.where((e) => e.value > 0.0).map((e) => e.key).toList();
    if (active.isEmpty) return 'none';
    if (active.length == 1) return active.first;
    return 'mixer';
  }

  double get volume {
    final active = _volumes.values.where((v) => v > 0.0);
    if (active.isEmpty) return 0.0;
    return active.reduce((a, b) => a + b) / active.length;
  }

  Map<String, double> get trackVolumes => _volumes;
}
