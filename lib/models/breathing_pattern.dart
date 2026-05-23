class BreathingPattern {
  final String id;
  final String name;
  final String description;
  final int inhaleSeconds;
  final int holdInSeconds;
  final int exhaleSeconds;
  final int holdOutSeconds;

  const BreathingPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.inhaleSeconds,
    required this.holdInSeconds,
    required this.exhaleSeconds,
    required this.holdOutSeconds,
  });

  int get totalCycleDuration =>
      inhaleSeconds + holdInSeconds + exhaleSeconds + holdOutSeconds;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'inhaleSeconds': inhaleSeconds,
      'holdInSeconds': holdInSeconds,
      'exhaleSeconds': exhaleSeconds,
      'holdOutSeconds': holdOutSeconds,
    };
  }

  factory BreathingPattern.fromMap(Map<String, dynamic> map) {
    return BreathingPattern(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      inhaleSeconds: map['inhaleSeconds'] as int,
      holdInSeconds: map['holdInSeconds'] as int,
      exhaleSeconds: map['exhaleSeconds'] as int,
      holdOutSeconds: map['holdOutSeconds'] as int,
    );
  }
}
