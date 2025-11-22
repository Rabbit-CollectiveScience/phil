class Workout {
  final String id;
  final DateTime dateTime;
  final List<WorkoutExercise> exercises;
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
}

class WorkoutExercise {
  final String exerciseId;
  final String name;
  final String category;
  final String muscleGroup;
  final Map<String, dynamic> parameters;

  WorkoutExercise({
    required this.exerciseId,
    required this.name,
    required this.category,
    required this.muscleGroup,
    required this.parameters,
  });

  String get formattedParameters {
    final parts = <String>[];

    if (parameters.containsKey('sets') && parameters.containsKey('reps')) {
      parts.add('${parameters['sets']} × ${parameters['reps']}');
    }

    if (parameters.containsKey('weight')) {
      final unit = parameters['weightUnit'] ?? 'lbs';
      parts.add('${parameters['weight']} $unit');
    }

    if (parameters.containsKey('duration')) {
      final duration = parameters['duration'];
      if (duration is int) {
        parts.add('${duration} min');
      } else {
        parts.add(duration.toString());
      }
    }

    if (parameters.containsKey('distance')) {
      final unit = parameters['distanceUnit'] ?? 'miles';
      parts.add('${parameters['distance']} $unit');
    }

    if (parameters.containsKey('holdDuration')) {
      parts.add('${parameters['holdDuration']} sec hold');
    }

    return parts.join(' • ');
  }
}
