import 'package:uuid/uuid.dart';
import '../../models/personal_records/weight_pr.dart';
import '../../models/personal_records/reps_pr.dart';
import '../../models/personal_records/volume_pr.dart';
import '../../models/personal_records/duration_pr.dart';
import '../../models/personal_records/distance_pr.dart';
import '../../models/personal_records/pace_pr.dart';
import '../../models/workout_sets/weighted_workout_set.dart';
import '../../models/workout_sets/bodyweight_workout_set.dart';
import '../../models/workout_sets/isometric_workout_set.dart';
import '../../models/workout_sets/distance_cardio_workout_set.dart';
import '../../models/workout_sets/duration_cardio_workout_set.dart';
import '../../models/exercises/strength_exercise.dart';
import '../../models/exercises/cardio_exercise.dart';
import '../../../l3_data/repositories/personal_record_repository.dart';
import '../../../l3_data/repositories/workout_set_repository.dart';
import '../../../l3_data/repositories/exercise_repository.dart';

/// Use case to recalculate PRs for an exercise
///
/// This scans all workout sets for the exercise and creates new PR records
/// based on max values found. Old PRs are deleted first.
class RecalculatePRsForExerciseUseCase {
  final PersonalRecordRepository _prRepository;
  final WorkoutSetRepository _workoutSetRepository;
  final ExerciseRepository _exerciseRepository;
  final _uuid = const Uuid();

  RecalculatePRsForExerciseUseCase(
    this._prRepository,
    this._workoutSetRepository,
    this._exerciseRepository,
  );

  Future<void> execute(String exerciseId) async {
    try {
      // 1. Get exercise info
      final exercise = await _exerciseRepository.getById(exerciseId);
      if (exercise == null) return;

      // 2. Get all workout sets for this exercise
      final setsForExercise = await _workoutSetRepository.getByExerciseId(
        exerciseId,
      );

      // 3. Delete all existing PRs for this exercise
      await _prRepository.deleteByExerciseId(exerciseId);

      // If no sets remain, we're done
      if (setsForExercise.isEmpty) return;

      // 4. Calculate PRs based on exercise type
      if (exercise is StrengthExercise) {
        await _calculateStrengthPRs(exerciseId, setsForExercise);
      } else if (exercise is CardioExercise) {
        await _calculateCardioPRs(exerciseId, setsForExercise);
      }
    } catch (e) {
      // Exercise not found or error - skip recalculation
      return;
    }
  }

  Future<void> _calculateStrengthPRs(
    String exerciseId,
    List<dynamic> sets,
  ) async {
    // Track max values
    double? maxWeight;
    int? maxReps;
    double? maxVolume;
    Duration? maxDuration;
    String? maxWeightSetId;
    String? maxRepsSetId;
    String? maxVolumeSetId;
    String? maxDurationSetId;

    for (final set in sets) {
      if (set is WeightedWorkoutSet) {
        // Weight PR
        if (set.weight != null &&
            (maxWeight == null || set.weight!.kg > maxWeight)) {
          maxWeight = set.weight!.kg;
          maxWeightSetId = set.id;
        }

        // Reps PR
        if (set.reps != null && (maxReps == null || set.reps! > maxReps)) {
          maxReps = set.reps;
          maxRepsSetId = set.id;
        }

        // Volume PR
        final volume = set.getVolume();
        if (volume != null && (maxVolume == null || volume > maxVolume)) {
          maxVolume = volume;
          maxVolumeSetId = set.id;
        }
      } else if (set is BodyweightWorkoutSet) {
        // Reps PR
        if (set.reps != null && (maxReps == null || set.reps! > maxReps)) {
          maxReps = set.reps;
          maxRepsSetId = set.id;
        }
      } else if (set is IsometricWorkoutSet) {
        // Duration PR - only if duration was tracked
        if (set.duration != null &&
            (maxDuration == null || set.duration! > maxDuration)) {
          maxDuration = set.duration;
          maxDurationSetId = set.id;
        }

        // Weight PR - only if NOT bodyweight-based (loaded static holds)
        if (!set.isBodyweightBased &&
            set.weight != null &&
            (maxWeight == null || set.weight!.kg > maxWeight)) {
          maxWeight = set.weight!.kg;
          maxWeightSetId = set.id;
        }
      }
    }

    // Create PR records
    if (maxWeight != null && maxWeightSetId != null) {
      await _prRepository.save(
        WeightPR(
          id: _uuid.v4(),
          exerciseId: exerciseId,
          workoutSetId: maxWeightSetId,
          achievedAt: _getSetTimestamp(sets, maxWeightSetId),
        ),
      );
    }

    if (maxReps != null && maxRepsSetId != null) {
      await _prRepository.save(
        RepsPR(
          id: _uuid.v4(),
          exerciseId: exerciseId,
          workoutSetId: maxRepsSetId,
          achievedAt: _getSetTimestamp(sets, maxRepsSetId),
        ),
      );
    }

    if (maxVolume != null && maxVolumeSetId != null) {
      await _prRepository.save(
        VolumePR(
          id: _uuid.v4(),
          exerciseId: exerciseId,
          workoutSetId: maxVolumeSetId,
          achievedAt: _getSetTimestamp(sets, maxVolumeSetId),
        ),
      );
    }

    if (maxDuration != null && maxDurationSetId != null) {
      await _prRepository.save(
        DurationPR(
          id: _uuid.v4(),
          exerciseId: exerciseId,
          workoutSetId: maxDurationSetId,
          achievedAt: _getSetTimestamp(sets, maxDurationSetId),
        ),
      );
    }
  }

  Future<void> _calculateCardioPRs(
    String exerciseId,
    List<dynamic> sets,
  ) async {
    // Track max values
    Duration? maxDuration;
    double? maxDistance;
    double? minPace; // Lower is better for pace
    String? maxDurationSetId;
    String? maxDistanceSetId;
    String? minPaceSetId;

    for (final set in sets) {
      if (set is DistanceCardioWorkoutSet) {
        // Duration PR
        if (set.duration != null &&
            (maxDuration == null || set.duration! > maxDuration)) {
          maxDuration = set.duration;
          maxDurationSetId = set.id;
        }

        // Distance PR
        if (set.distance != null &&
            (maxDistance == null || set.distance!.meters > maxDistance)) {
          maxDistance = set.distance!.meters;
          maxDistanceSetId = set.id;
        }

        // Pace PR (best/fastest pace)
        final pace = set.getPace();
        if (minPace == null || pace < minPace) {
          minPace = pace;
          minPaceSetId = set.id;
        }
      } else if (set is DurationCardioWorkoutSet) {
        // Duration PR
        if (set.duration != null &&
            (maxDuration == null || set.duration! > maxDuration)) {
          maxDuration = set.duration;
          maxDurationSetId = set.id;
        }
      }
    }

    // Create PR records
    if (maxDuration != null && maxDurationSetId != null) {
      await _prRepository.save(
        DurationPR(
          id: _uuid.v4(),
          exerciseId: exerciseId,
          workoutSetId: maxDurationSetId,
          achievedAt: _getSetTimestamp(sets, maxDurationSetId),
        ),
      );
    }

    if (maxDistance != null && maxDistanceSetId != null) {
      await _prRepository.save(
        DistancePR(
          id: _uuid.v4(),
          exerciseId: exerciseId,
          workoutSetId: maxDistanceSetId,
          achievedAt: _getSetTimestamp(sets, maxDistanceSetId),
        ),
      );
    }

    if (minPace != null && minPaceSetId != null) {
      await _prRepository.save(
        PacePR(
          id: _uuid.v4(),
          exerciseId: exerciseId,
          workoutSetId: minPaceSetId,
          achievedAt: _getSetTimestamp(sets, minPaceSetId),
        ),
      );
    }
  }

  DateTime _getSetTimestamp(List<dynamic> sets, String setId) {
    return sets.firstWhere((s) => s.id == setId).timestamp;
  }
}
