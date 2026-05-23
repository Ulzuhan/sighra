import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import '../models/session_log.dart';
import '../models/breathing_pattern.dart';

class BackupService {
  BackupService._privateConstructor();
  static final BackupService instance = BackupService._privateConstructor();

  final _db = DatabaseService.instance;

  // Key names in SharedPreferences to backup
  static const List<String> _prefKeys = [
    'is_dark_mode',
    'haptics_enabled',
    'language_locale',
    'track_volume_brown_noise',
    'track_volume_ocean',
    'track_volume_rain',
    'track_volume_pink_noise',
    'track_volume_solfeggio',
    'haptic_signature',
  ];

  // Serializes the entire app state (Preferences + SQLite database) into a Base64 String
  Future<String> exportBackupString() async {
    try {
      final Map<String, dynamic> backupData = {
        'version': 2,
        'exportedAt': DateTime.now().toIso8601String(),
        'preferences': {},
        'custom_patterns': [],
        'session_logs': [],
      };

      // 1. Export Preferences
      final sp = await SharedPreferences.getInstance();
      for (final key in _prefKeys) {
        if (sp.containsKey(key)) {
          backupData['preferences'][key] = sp.get(key);
        }
      }

      // 2. Export Custom Patterns
      final patterns = await _db.getCustomPatterns();
      backupData['custom_patterns'] = patterns.map((p) => p.toMap()).toList();

      // 3. Export Session Logs
      final logs = await _db.getAllSessionLogs();
      backupData['session_logs'] = logs.map((l) => l.toMap()).toList();

      // Convert to JSON and then Base64
      final jsonStr = jsonEncode(backupData);
      final bytes = utf8.encode(jsonStr);
      return base64Encode(bytes);
    } catch (e) {
      debugPrint("Backup export failed: $e");
      rethrow;
    }
  }

  // Parses a Base64 string and imports settings, logs, and exercises defensively
  Future<void> importBackupString(String b64string) async {
    try {
      final cleanB64 = b64string.trim();
      final bytes = base64Decode(cleanB64);
      final jsonStr = utf8.decode(bytes);
      final Map<String, dynamic> backupData = jsonDecode(jsonStr);

      if (!backupData.containsKey('version')) {
        throw const FormatException("Invalid backup format: missing version metadata.");
      }

      // 1. Wipe current SQLite tables
      await _db.clearAllData();

      // 2. Restore Custom Patterns
      if (backupData.containsKey('custom_patterns')) {
        final List<dynamic> patternsJson = backupData['custom_patterns'] as List<dynamic>;
        for (final pMap in patternsJson) {
          final pattern = BreathingPattern.fromMap(Map<String, dynamic>.from(pMap as Map));
          await _db.insertCustomPattern(pattern);
        }
      }

      // 3. Restore Session Logs
      if (backupData.containsKey('session_logs')) {
        final List<dynamic> logsJson = backupData['session_logs'] as List<dynamic>;
        for (final lMap in logsJson) {
          final log = SessionLog.fromMap(Map<String, dynamic>.from(lMap as Map));
          await _db.insertSessionLog(log);
        }
      }

      // 4. Restore Preferences
      if (backupData.containsKey('preferences')) {
        final sp = await SharedPreferences.getInstance();
        final Map<String, dynamic> prefsJson = Map<String, dynamic>.from(backupData['preferences'] as Map);
        
        for (final entry in prefsJson.entries) {
          final key = entry.key;
          final value = entry.value;

          if (value is bool) {
            await sp.setBool(key, value);
          } else if (value is double) {
            await sp.setDouble(key, value);
          } else if (value is String) {
            await sp.setString(key, value);
          } else if (value is int) {
            await sp.setInt(key, value.toDouble().round());
          }
        }
      }
    } catch (e) {
      debugPrint("Backup restore failed: $e");
      rethrow;
    }
  }
}
