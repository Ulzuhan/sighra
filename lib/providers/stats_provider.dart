import 'package:flutter/material.dart';
import '../models/session_log.dart';
import '../services/database_service.dart';

class StatsProvider with ChangeNotifier {
  final _db = DatabaseService.instance;

  List<SessionLog> _history = [];
  int _totalMinutes = 0;
  int _totalSessions = 0;
  int _streak = 0;
  bool _isLoading = false;
  
  // Daily breathing minutes aggregated for Monday to Sunday (weekday index 1 to 7)
  Map<int, double> _weeklyCalmMinutes = {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0, 7: 0.0};

  List<SessionLog> get history => _history;
  int get totalMinutes => _totalMinutes;
  int get totalSessions => _totalSessions;
  int get streak => _streak;
  bool get isLoading => _isLoading;
  Map<int, double> get weeklyCalmMinutes => _weeklyCalmMinutes;

  // Retrieve session data and rebuild streak metrics
  Future<void> fetchStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _history = await _db.getAllSessionLogs();
      _totalSessions = _history.length;
      
      final totalSeconds = await _db.getTotalBreathingSeconds();
      _totalMinutes = (totalSeconds / 60).round();

      // Compute current practice streak in days
      final dates = await _db.getUniquePracticeDates();
      _streak = _calculateStreak(dates);
      
      // Compute weekly aggregated daily practice times (Monday-Sunday)
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      
      _weeklyCalmMinutes = {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0, 7: 0.0};
      for (final log in _history) {
        if (log.timestamp.isAfter(startOfWeek.subtract(const Duration(seconds: 1)))) {
          final wd = log.timestamp.weekday;
          _weeklyCalmMinutes[wd] = (_weeklyCalmMinutes[wd] ?? 0.0) + (log.durationSeconds / 60.0);
        }
      }
    } catch (e) {
      debugPrint("Error fetching statistics: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate successive practice dates streak
  int _calculateStreak(List<String> dates) {
    if (dates.isEmpty) return 0;

    final today = DateTime.now();
    final todayStr = _formatDate(today);
    final yesterdayStr = _formatDate(today.subtract(const Duration(days: 1)));

    // If the latest practice is neither today nor yesterday, the streak is broken (0)
    if (dates.first != todayStr && dates.first != yesterdayStr) {
      return 0;
    }

    int currentStreak = 1;
    for (int i = 0; i < dates.length - 1; i++) {
      final current = DateTime.parse(dates[i]);
      final next = DateTime.parse(dates[i + 1]);
      
      final difference = current.difference(next).inDays;
      if (difference == 1) {
        currentStreak++;
      } else if (difference > 1) {
        break; // streak ended
      }
    }
    return currentStreak;
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Clear all statistics database records
  Future<void> wipeStats() async {
    await _db.clearAllData();
    await fetchStats();
  }
}
