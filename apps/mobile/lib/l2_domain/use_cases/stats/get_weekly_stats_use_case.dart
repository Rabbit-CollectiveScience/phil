import '../workout_sets/get_workout_sets_by_date_use_case.dart';
import '../../../l3_data/repositories/exercise_repository.dart';

/// Use case to get weekly workout statistics including attendance and exercise type breakdown
class GetWeeklyStatsUseCase {
  final GetWorkoutSetsByDateUseCase _getWorkoutSetsByDateUseCase;
  final ExerciseRepository _exerciseRepository;

  GetWeeklyStatsUseCase(
    this._getWorkoutSetsByDateUseCase,
    this._exerciseRepository,
  );

  /// Executes the use case to get weekly statistics
  ///
  /// Parameters:
  /// - weekOffset: 0 = current week, -1 = last week, etc.
  ///
  /// Returns a Map containing:
  /// - attendance: {daysTrained, avgSetsPerDay}
  /// - exerciseTypes: List of type stats {type, exercises, sets, volume, duration}
  Future<Map<String, dynamic>> execute({int weekOffset = 0}) async {
    // Calculate week start (Monday) and end (Sunday)
    final now = DateTime.now();
    final currentWeekday = now.weekday; // Monday = 1, Sunday = 7

    // Get Monday of the target week
    final startOfCurrentWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: currentWeekday - 1));
    final startOfTargetWeek = startOfCurrentWeek.add(
      Duration(days: weekOffset * 7),
    );
    final endOfTargetWeek = startOfTargetWeek.add(const Duration(days: 6));

    // Collect all workout sets for the week
    final List<dynamic> allWorkoutSets = [];
    final Set<String> uniqueDates = {};

    for (int i = 0; i < 7; i++) {
      final date = startOfTargetWeek.add(Duration(days: i));
      final setsForDay = await _getWorkoutSetsByDateUseCase.execute(date: date);

      if (setsForDay.isNotEmpty) {
        allWorkoutSets.addAll(setsForDay);
        uniqueDates.add('${date.year}-${date.month}-${date.day}');
      }
    }

    // Calculate attendance metrics
    final daysTrained = uniqueDates.length;
    final totalSets = allWorkoutSets.length;
    final avgSetsPerDay = daysTrained > 0 ? totalSets / daysTrained : 0.0;

    // Group by exercise type
    final Map<String, Map<String, dynamic>> typeStats = {};

    for (final setWithDetails in allWorkoutSets) {
      final exerciseId = setWithDetails.workoutSet.exerciseId;
      final values = setWithDetails.workoutSet.values;

      // Get exercise to determine type
      final exercise = await _exerciseRepository.getExerciseById(exerciseId);
      if (exercise == null) continue;

      // Get category - for strength exercises, take the second category (muscle group)
      // For cardio, take the first category
      String type = 'OTHER';
      if (exercise.categories.isNotEmpty) {
        if (exercise.categories.first.toLowerCase() == 'strength' &&
            exercise.categories.length > 1) {
          // Strength exercise - use the muscle group (second category)
          type = exercise.categories[1].toUpperCase();
        } else {
          // Cardio - use the first category
          type = exercise.categories.first.toUpperCase();
        }
      }

      // Initialize type stats if not exists
      if (!typeStats.containsKey(type)) {
        typeStats[type] = {
          'type': type,
          'exercises': <String>{}, // Use Set to track unique exercises
          'sets': 0,
          'volume': 0.0,
          'duration': 0.0, // in seconds, will convert to minutes
        };
      }

      // Add exercise to unique set
      (typeStats[type]!['exercises'] as Set<String>).add(exerciseId);
      typeStats[type]!['sets'] += 1;

      // Calculate volume or duration based on type
      final isCardio = type == 'CARDIO';

      if (isCardio) {
        // Sum duration for cardio
        if (values != null && values.containsKey('durationInSeconds')) {
          final duration = values['durationInSeconds'];
          if (duration != null) {
            typeStats[type]!['duration'] += (duration as num).toDouble();
          }
        }
      } else {
        // Calculate volume for strength exercises
        if (values != null) {
          double volume = 0.0;

          // Priority: weight × reps
          if (values.containsKey('weight') && values.containsKey('reps')) {
            final weight = values['weight'];
            final reps = values['reps'];
            if (weight != null && reps != null) {
              volume = (weight as num).toDouble() * (reps as num).toDouble();
            }
          }

          typeStats[type]!['volume'] += volume;
        }
      }
    }

    // Convert type stats to list and format
    final List<Map<String, dynamic>> exerciseTypes = typeStats.entries.map((
      entry,
    ) {
      final stats = entry.value;
      final isCardio = entry.key == 'CARDIO';

      return {
        'type': entry.key,
        'exercises': (stats['exercises'] as Set<String>).length,
        'sets': stats['sets'],
        'volume': isCardio ? 0.0 : stats['volume'],
        'duration': isCardio
            ? (stats['duration'] as double) /
                  60.0 // Convert seconds to minutes
            : null,
      };
    }).toList();

    // Sort by type name for consistency
    exerciseTypes.sort((a, b) => a['type'].compareTo(b['type']));

    return {
      'attendance': {
        'daysTrained': daysTrained,
        'avgSetsPerDay': avgSetsPerDay,
      },
      'exerciseTypes': exerciseTypes,
    };
  }
}
