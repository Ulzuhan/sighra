import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  HapticService._privateConstructor();
  static final HapticService instance = HapticService._privateConstructor();

  bool _isVibrating = false;

  // Single brief pulse indicating transitions
  Future<void> triggerTransitionPulse() async {
    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(duration: 80);
      }
    } catch (e) {
      debugPrint("Haptic exception: $e");
    }
  }

  // Dual tap indicating cycle completion / breath hold out
  Future<void> triggerCompletionPulse() async {
    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(pattern: [0, 100, 100, 100]);
      }
    } catch (e) {
      debugPrint("Haptic exception: $e");
    }
  }

  // Continuous gentle pulses synced during inhalation state
  Future<void> startInhaleVibration(String signature) async {
    try {
      if (await Vibration.hasVibrator()) {
        cancelActiveVibration();
        _isVibrating = true;
        
        List<int> pattern;
        if (signature == 'wave') {
          pattern = [0, 80, 120, 80, 120];
        } else if (signature == 'heartbeat') {
          pattern = [0, 40, 60, 40, 300];
        } else {
          // Gentle Hum default
          pattern = [0, 50, 250, 50, 250];
        }

        await Vibration.vibrate(
          pattern: pattern,
          repeat: 0, // repeat from start index
        );
      }
    } catch (e) {
      debugPrint("Haptic exception: $e");
    }
  }

  // Slower gentle pulses during exhalation state
  Future<void> startExhaleVibration(String signature) async {
    try {
      if (await Vibration.hasVibrator()) {
        cancelActiveVibration();
        _isVibrating = true;
        
        List<int> pattern;
        if (signature == 'wave') {
          pattern = [0, 120, 250, 120, 250];
        } else if (signature == 'heartbeat') {
          pattern = [0, 50, 80, 50, 450];
        } else {
          pattern = [0, 80, 420, 80, 420];
        }

        await Vibration.vibrate(
          pattern: pattern,
          repeat: 0,
        );
      }
    } catch (e) {
      debugPrint("Haptic exception: $e");
    }
  }

  // Cancel any ongoing haptic loops
  Future<void> cancelActiveVibration() async {
    try {
      if (_isVibrating) {
        await Vibration.cancel();
        _isVibrating = false;
      }
    } catch (e) {
      debugPrint("Haptic exception: $e");
    }
  }
}
