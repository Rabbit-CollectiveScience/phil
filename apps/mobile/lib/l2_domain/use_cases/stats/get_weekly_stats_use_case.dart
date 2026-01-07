import '../../models/workout_sets/weighted_workout_set.dart';
import '../../models/workout_sets/distance_cardio_workout_set.dart';
import '../../models/workout_sets/duration_cardio_workout_set.dart';
import '../../models/exercises/strength_exercise.dart';
import '../../models/exercises/cardio_exercise.dart';
import '../../models/common/muscle_group.dart';
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
      final set = setWithDetails.workoutSet;

      // Get exercise to determine type
      final exercise = await _exerciseRepository.getById(exerciseId);
      if (exercise == null) continue;

      // Determine category
      String type = 'OTHER';
      if (exercise is StrengthExercise) {
        // Use primary muscle group if available
        if (exercise.targetMuscles.isNotEmpty) {
          type = exercise.targetMuscles.first.name.toUpperCase();
        } else {
          type = 'STRENGTH';
        }
      } else if (exercise is CardioExercise) {
        type = 'CARDIO';
      }

      // Initialize type stats if not exists
      if (!typeStats.containsKey(type)) {
        typeStats[type] = {
          'type': type,
          'exercises': <String>{},
          'sets': 0,
          'volume': 0.0,
          'duration': 0.0,
        };
      }

      // Add exercise to unique set
      (typeStats[type]!['exercises'] as Set<String>).add(exerciseId);
      typeStats[type]!['sets'] += 1;

      // Calculate volume or duration
      if (set is WeightedWorkoutSet) {
        final volume = set.getVolume();
        if (volume != null) {
          typeStats[type]!['volume'] += volume;
        }
      } else if (set is DistanceCardioWorkoutSet) {
        if (set.duration != null) {
          typeStats[type]!['duration'] += set.duration!.inSeconds.toDouble();
        }
      } else if (set is DurationCardioWorkoutSet) {
        if (set.duration != null) {
          typeStats[type]!['duration'] += set.duration!.inSeconds.toDouble();
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
                  60.0 // Convert to minutes
            : null,
      };
    }).toList();

    // Sort by type name
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
