import 'package:hive/hive.dart';
import 'workout_exercise.dart';

part 'workout.g.dart';

@HiveType(typeId: 0)
class Workout {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime dateTime;

  @HiveField(2)
  final List<WorkoutExercise> exercises;

  @HiveField(3)
  final int durationMinutes;

  Workout({
    required this.id,
    required this.dateTime,
    required this.exercises,
    required this.durationMinutes,
  });

  int get totalExercises => exercises.length;

  Set<String> get muscleGroups => exercises.map((e) => e.muscleGroup).toSet();

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $year • ${hour == 0 ? 12 : hour}:$minute $period';
  }

  String get exercisePreview {
    if (exercises.isEmpty) return 'No exercises';
    if (exercises.length == 1) return exercises[0].name;
    if (exercises.length == 2) {
      return '${exercises[0].name}, ${exercises[1].name}';
    }
    return '${exercises[0].name}, ${exercises[1].name}, +${exercises.length - 2} more';
  }

  /// Convert to JSON (for MongoDB migration)
  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'durationMinutes': durationMinutes,
  };

  /// Create from JSON (for MongoDB migration)
  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    id: json['id'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    exercises: (json['exercises'] as List)
        .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
    durationMinutes: json['durationMinutes'] as int,
  );
}
