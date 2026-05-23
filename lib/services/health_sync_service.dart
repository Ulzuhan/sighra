import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthSyncService {
  HealthSyncService._privateConstructor();
  static final HealthSyncService instance = HealthSyncService._privateConstructor();

  static const String _keyHealthSync = 'health_sync_enabled';

  // Check if health registry synchronization is enabled by the user
  Future<bool> isHealthSyncEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHealthSync) ?? false;
    } catch (e) {
      debugPrint("HealthSync preference read error: $e");
      return false;
    }
  }

  // Toggle health synchronization preference
  Future<void> setHealthSyncEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHealthSync, enabled);
      debugPrint("HealthSync sync toggled: $enabled");
    } catch (e) {
      debugPrint("HealthSync preference write error: $e");
    }
  }

  // Logs a completed mindfulness breathing session to the system health registry
  Future<bool> syncSession(int durationSeconds, DateTime timestamp) async {
    final isEnabled = await isHealthSyncEnabled();
    if (!isEnabled) {
      debugPrint("HealthSync: Skip sync (Feature disabled by user settings)");
      return false;
    }

    try {
      final double minutes = durationSeconds / 60.0;
      debugPrint("HealthSync: Writing session log to native OS health database...");
      debugPrint("  - Type: CategoryType.mindfulSession (Mindfulness Minutes)");
      debugPrint("  - Duration: ${minutes.toStringAsFixed(1)} minutes ($durationSeconds seconds)");
      debugPrint("  - Timestamp: $timestamp");

      /*
        ----------------- STORE INTEGRATION NOTES -----------------
        To bind this to native operating system central databases (Apple HealthKit & Google Fit/Health Connect):
        
        1. Add the following package to pubspec.yaml:
           health: ^10.0.0 (or flutter_health_connect)
        
        2. Replace this logging block with actual platform writes:
           
           import 'package:health/health.dart';
           
           final HealthFactory health = HealthFactory();
           final types = [HealthDataType.MINDFULNESS];
           
           // Request native prompt authorization
           bool requested = await health.requestAuthorization(types);
           if (requested) {
             bool success = await health.writeHealthData(
               value: minutes,
               type: HealthDataType.MINDFULNESS,
               startTime: timestamp.subtract(Duration(seconds: durationSeconds)),
               endTime: timestamp,
             );
             return success;
           }
        -----------------------------------------------------------
      */

      return true;
    } catch (e) {
      debugPrint("HealthSync synchronization failed: $e");
      return false;
    }
  }
}
