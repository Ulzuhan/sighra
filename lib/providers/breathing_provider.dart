import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/breathing_pattern.dart';
import '../models/session_log.dart';
import '../services/database_service.dart';
import '../services/haptic_service.dart';
import '../services/health_sync_service.dart';

enum BreathingState { idle, inhale, holdIn, exhale, holdOut, completed }

class BreathingProvider with ChangeNotifier {
  final _db = DatabaseService.instance;
  final _haptic = HapticService.instance;
  final _uuid = const Uuid();

  // List of offline breathing patterns
  final List<BreathingPattern> _defaultPatterns = [
    const BreathingPattern(
      id: 'box_breathing',
      name: 'Box Breathing',
      description: 'Equal duration box ratios for calming nerves.',
      inhaleSeconds: 4,
      holdInSeconds: 4,
      exhaleSeconds: 4,
      holdOutSeconds: 4,
    ),
    const BreathingPattern(
      id: '478_technique',
      name: '4-7-8 Technique',
      description: 'Natural neural relaxer, useful before sleep.',
      inhaleSeconds: 4,
      holdInSeconds: 7,
      exhaleSeconds: 8,
      holdOutSeconds: 0,
    ),
    const BreathingPattern(
      id: 'cardiac_coherence',
      name: 'Cardiac Coherence',
      description: 'Harmonize your pulse rhythm and calm anxiety.',
      inhaleSeconds: 5,
      holdInSeconds: 0,
      exhaleSeconds: 5,
      holdOutSeconds: 0,
    ),
    const BreathingPattern(
      id: 'physiological_sigh',
      name: 'Physiological Sigh',
      description: 'Double nasal inhale followed by one long mouth exhale to ground nerves instantly.',
      inhaleSeconds: 3,
      holdInSeconds: 1,
      exhaleSeconds: 6,
      holdOutSeconds: 0,
    ),
  ];

  List<BreathingPattern> _patterns = [];
  late BreathingPattern _currentPattern;
  BreathingState _state = BreathingState.idle;

  // Timers & Counters
  Timer? _timer;
  int _secondsRemaining = 0;
  int _cyclesCompleted = 0;
  final int _targetCycles = 4; // 4 cycles is an excellent standard calming set
  int _secondsBreathedInSession = 0;
  
  // Settings sync
  bool _hapticsEnabled = true;
  String _hapticSignature = 'hum';

  BreathingProvider() {
    _patterns = List.from(_defaultPatterns);
    _currentPattern = _patterns.first;
    loadCustomPatterns();
  }

  List<BreathingPattern> get patterns => _patterns;
  BreathingPattern get currentPattern => _currentPattern;
  BreathingState get state => _state;
  int get secondsRemaining => _secondsRemaining;
  int get cyclesCompleted => _cyclesCompleted;
  int get targetCycles => _targetCycles;

  // Dynamic animation scale (0.0 to 1.0) consumed by animated canvas ring
  double get animationScale {
    if (_state == BreathingState.idle || _state == BreathingState.completed) {
      return 0.2;
    }

    final total = _getPhaseDuration(_state);
    if (total == 0) return 0.2;

    final elapsed = total - _secondsRemaining;
    final ratio = elapsed / total;

    switch (_state) {
      case BreathingState.inhale:
        return 0.2 + (ratio * 0.8); // 0.2 -> 1.0
      case BreathingState.holdIn:
        return 1.0;
      case BreathingState.exhale:
        return 1.0 - (ratio * 0.8); // 1.0 -> 0.2
      case BreathingState.holdOut:
        return 0.2;
      default:
        return 0.2;
    }
  }

  Future<void> loadCustomPatterns() async {
    try {
      final customs = await _db.getCustomPatterns();
      _patterns = List.from(_defaultPatterns)..addAll(customs);
      
      // Ensure currently selected pattern remains valid
      final currentExists = _patterns.any((p) => p.id == _currentPattern.id);
      if (!currentExists) {
        _currentPattern = _patterns.first;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading custom patterns: $e");
    }
  }

  Future<void> addCustomPattern(BreathingPattern pattern) async {
    await _db.insertCustomPattern(pattern);
    await loadCustomPatterns();
  }

  Future<void> removeCustomPattern(String id) async {
    await _db.deleteCustomPattern(id);
    await loadCustomPatterns();
  }

  void setPattern(String id) {
    if (_state != BreathingState.idle) return;
    _currentPattern = _patterns.firstWhere((p) => p.id == id, orElse: () => _patterns.first);
    notifyListeners();
  }

  void setHapticsEnabled(bool enabled) {
    _hapticsEnabled = enabled;
  }

  String get hapticSignature => _hapticSignature;

  void setHapticSignature(String val) {
    _hapticSignature = val;
    notifyListeners();
  }

  // Toggle session state
  void startBreathing() {
    if (_state != BreathingState.idle) return;

    _cyclesCompleted = 0;
    _secondsBreathedInSession = 0;
    _transitionToState(BreathingState.inhale);
    
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  // Emergency Panic override action
  void triggerEmergencyPanicGrounding() {
    stopBreathing();
    _currentPattern = _patterns.firstWhere((p) => p.id == 'cardiac_coherence', orElse: () => _patterns.first);
    _hapticsEnabled = true;
    startBreathing();
  }

  void stopBreathing() {
    _timer?.cancel();
    _haptic.cancelActiveVibration();
    
    // If the user practiced at least 10 seconds, save the partial session!
    if (_secondsBreathedInSession >= 10) {
      _saveSession();
    }
    
    _state = BreathingState.idle;
    notifyListeners();
  }

  void _tick(Timer timer) {
    _secondsBreathedInSession++;
    _secondsRemaining--;

    if (_secondsRemaining <= 0) {
      _transitionToNextState();
    } else {
      notifyListeners();
    }
  }

  void _transitionToNextState() {
    switch (_state) {
      case BreathingState.inhale:
        if (_currentPattern.holdInSeconds > 0) {
          _transitionToState(BreathingState.holdIn);
        } else {
          _transitionToState(BreathingState.exhale);
        }
        break;
      case BreathingState.holdIn:
        _transitionToState(BreathingState.exhale);
        break;
      case BreathingState.exhale:
        if (_currentPattern.holdOutSeconds > 0) {
          _transitionToState(BreathingState.holdOut);
        } else {
          _cyclesCompleted++;
          if (_cyclesCompleted >= _targetCycles) {
            _completeSession();
          } else {
            _transitionToState(BreathingState.inhale);
          }
        }
        break;
      case BreathingState.holdOut:
        _cyclesCompleted++;
        if (_cyclesCompleted >= _targetCycles) {
          _completeSession();
        } else {
          _transitionToState(BreathingState.inhale);
        }
        break;
      default:
        break;
    }
  }

  void _transitionToState(BreathingState newState) {
    _state = newState;
    _secondsRemaining = _getPhaseDuration(newState);
    notifyListeners();

    if (!_hapticsEnabled) return;

    // Trigger state-specific vibration guides
    switch (newState) {
      case BreathingState.inhale:
        _haptic.startInhaleVibration(_hapticSignature);
        break;
      case BreathingState.holdIn:
        _haptic.cancelActiveVibration();
        _haptic.triggerTransitionPulse();
        break;
      case BreathingState.exhale:
        _haptic.startExhaleVibration(_hapticSignature);
        break;
      case BreathingState.holdOut:
        _haptic.cancelActiveVibration();
        _haptic.triggerTransitionPulse();
        break;
      default:
        _haptic.cancelActiveVibration();
        break;
    }
  }

  void _completeSession() {
    _timer?.cancel();
    _haptic.cancelActiveVibration();
    _haptic.triggerCompletionPulse();
    
    _state = BreathingState.completed;
    notifyListeners();

    _saveSession();

    // Auto return to idle after 4 seconds of completed congrats splash
    Future.delayed(const Duration(seconds: 4), () {
      if (_state == BreathingState.completed) {
        _state = BreathingState.idle;
        notifyListeners();
      }
    });
  }

  Future<void> _saveSession() async {
    final log = SessionLog(
      id: _uuid.v4(),
      patternId: _currentPattern.id,
      durationSeconds: _secondsBreathedInSession,
      timestamp: DateTime.now(),
    );
    await _db.insertSessionLog(log);
    
    // Sync mindfulness duration with OS health registry
    try {
      await HealthSyncService.instance.syncSession(_secondsBreathedInSession, log.timestamp);
    } catch (e) {
      debugPrint("HealthSync auto sync error: $e");
    }
    
    _secondsBreathedInSession = 0; // reset
  }

  int _getPhaseDuration(BreathingState s) {
    switch (s) {
      case BreathingState.inhale:
        return _currentPattern.inhaleSeconds;
      case BreathingState.holdIn:
        return _currentPattern.holdInSeconds;
      case BreathingState.exhale:
        return _currentPattern.exhaleSeconds;
      case BreathingState.holdOut:
        return _currentPattern.holdOutSeconds;
      default:
        return 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _haptic.cancelActiveVibration();
    super.dispose();
  }
}
