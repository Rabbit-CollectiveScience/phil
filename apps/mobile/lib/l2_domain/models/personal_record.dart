class PersonalRecord {
  final String id;
  final String exerciseId;
  final String type;
  final double value;
  final DateTime achievedAt;

  PersonalRecord({
    required this.id,
    required this.exerciseId,
    required this.type,
    required this.value,
    required this.achievedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'type': type,
      'value': value,
      'achievedAt': achievedAt.toIso8601String(),
    };
  }

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    return PersonalRecord(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      achievedAt: DateTime.parse(json['achievedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PersonalRecord &&
        other.id == id &&
        other.exerciseId == exerciseId &&
        other.type == type &&
        other.value == value &&
        other.achievedAt == achievedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, exerciseId, type, value, achievedAt);
  }

  @override
  String toString() {
    return 'PersonalRecord(id: $id, exerciseId: $exerciseId, type: $type, value: $value, achievedAt: $achievedAt)';
  }
}
