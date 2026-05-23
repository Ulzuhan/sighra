class SessionLog {
  final String id;
  final String patternId;
  final int durationSeconds;
  final DateTime timestamp;

  const SessionLog({
    required this.id,
    required this.patternId,
    required this.durationSeconds,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patternId': patternId,
      'durationSeconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SessionLog.fromMap(Map<String, dynamic> map) {
    return SessionLog(
      id: map['id'] as String,
      patternId: map['patternId'] as String,
      durationSeconds: map['durationSeconds'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
