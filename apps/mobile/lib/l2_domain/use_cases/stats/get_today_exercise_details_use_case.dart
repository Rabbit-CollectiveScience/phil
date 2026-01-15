import '../../models/workout_sets/weighted_workout_set.dart';
import '../../models/workout_sets/bodyweight_workout_set.dart';
import '../../models/workout_sets/assisted_machine_workout_set.dart';
import '../../models/workout_sets/isometric_workout_set.dart';
import '../../models/workout_sets/distance_cardio_workout_set.dart';
import '../../models/workout_sets/duration_cardio_workout_set.dart';
import '../../models/personal_records/weight_pr.dart';
import '../../models/personal_records/reps_pr.dart';
import '../../models/personal_records/volume_pr.dart';
import '../../models/personal_records/duration_pr.dart';
import '../../models/personal_records/distance_pr.dart';
import '../workout_sets/get_workout_sets_by_date_use_case.dart';
import '../../../l3_data/repositories/personal_record_repository.dart';

/// Use case to get detailed exercise breakdown for today's workout
class GetTodayExerciseDetailsUseCase {
  final GetWorkoutSetsByDateUseCase _getWorkoutSetsByDateUseCase;
  final PersonalRecordRepository? _prRepository;

  GetTodayExerciseDetailsUseCase(
    this._getWorkoutSetsByDateUseCase, {
    PersonalRecordRepository? prRepository,
  }) : _prRepository = prRepository;

  /// Returns exercise-level details for today including PR status
  Future<List<Map<String, dynamic>>> execute({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final workoutSetsWithDetails = await _getWorkoutSetsByDateUseCase.execute(
      date: targetDate,
    );

    // Group sets by exercise
    final Map<String, List<dynamic>> exerciseGroups = {};
    for (final setWithDetails in workoutSetsWithDetails) {
      final exerciseId = setWithDetails.workoutSet.exerciseId;
      exerciseGroups.putIfAbsent(exerciseId, () => []);
      exerciseGroups[exerciseId]!.add(setWithDetails);
    }

    // Build exercise detail list
    final List<Map<String, dynamic>> exerciseDetails = [];

    for (final entry in exerciseGroups.entries) {
      final exerciseId = entry.key;
      final sets = entry.value;
      final firstSet = sets.first;

      // Calculate stats
      final setCount = sets.length;
      double? totalVolume;
      int? maxReps;
      double? maxWeight;
      Duration? maxDuration;
      double? maxDistance; // in meters
      double? maxAdditionalWeight; // for bodyweight exercises

      for (final setWithDetails in sets) {
        final set = setWithDetails.workoutSet;

        if (set is WeightedWorkoutSet) {
          final volume = set.getVolume();
          if (volume != null) {
            totalVolume = (totalVolume ?? 0) + volume;
          }

          if (set.weight != null &&
              (maxWeight == null || set.weight!.kg > maxWeight)) {
            maxWeight = set.weight!.kg;
          }

          if (set.reps != null && (maxReps == null || set.reps! > maxReps)) {
            maxReps = set.reps;
          }
        } else if (set is BodyweightWorkoutSet) {
          if (set.reps != null && (maxReps == null || set.reps! > maxReps)) {
            maxReps = set.reps;
          }

          // Track additional weight for bodyweight exercises
          if (set.additionalWeight != null &&
              (maxAdditionalWeight == null ||
                  set.additionalWeight!.kg > maxAdditionalWeight)) {
            maxAdditionalWeight = set.additionalWeight!.kg;
          }
        } else if (set is AssistedMachineWorkoutSet) {
          if (set.reps != null && (maxReps == null || set.reps! > maxReps)) {
            maxReps = set.reps;
          }

          // Track MINIMUM assistance weight (lower = better for assisted machines)
          if (set.assistanceWeight != null &&
              (maxWeight == null || set.assistanceWeight!.kg < maxWeight)) {
            maxWeight = set.assistanceWeight!.kg;
          }
        } else if (set is IsometricWorkoutSet) {
          // Duration tracking for isometric exercises
          if (set.duration != null &&
              (maxDuration == null || set.duration! > maxDuration)) {
            maxDuration = set.duration;
          }

          // Track additional weight for bodyweight-based isometric exercises
          if (set.isBodyweightBased &&
              set.weight != null &&
              (maxAdditionalWeight == null ||
                  set.weight!.kg > maxAdditionalWeight)) {
            maxAdditionalWeight = set.weight!.kg;
          }
        } else if (set is DistanceCardioWorkoutSet) {
          // Duration tracking
          if (set.duration != null &&
              (maxDuration == null || set.duration! > maxDuration)) {
            maxDuration = set.duration;
          }

          // Distance tracking
          if (set.distance != null &&
              (maxDistance == null || set.distance!.meters > maxDistance)) {
            maxDistance = set.distance!.meters;
          }
        } else if (set is DurationCardioWorkoutSet) {
          // Duration tracking
          if (set.duration != null &&
              (maxDuration == null || set.duration! > maxDuration)) {
            maxDuration = set.duration;
          }
        }
      }

      // Check for PRs if repository available
      bool hasWeightPR = false;
      bool hasRepsPR = false;
      bool hasVolumePR = false;
      bool hasDurationPR = false;
      bool hasDistancePR = false;
      final List<Map<String, dynamic>> prsToday = [];

      if (_prRepository != null) {
        final weightPRs = await _prRepository.getByExerciseIdAndType<WeightPR>(
          exerciseId,
        );
        final repsPRs = await _prRepository.getByExerciseIdAndType<RepsPR>(
          exerciseId,
        );
        final volumePRs = await _prRepository.getByExerciseIdAndType<VolumePR>(
          exerciseId,
        );
        final durationPRs = await _prRepository
            .getByExerciseIdAndType<DurationPR>(exerciseId);
        final distancePRs = await _prRepository
            .getByExerciseIdAndType<DistancePR>(exerciseId);

        // Check if any PR was achieved today
        final todayStart = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
        );
        final todayEnd = todayStart.add(const Duration(days: 1));

        hasWeightPR = weightPRs.any(
          (pr) =>
              pr.achievedAt.isAfter(todayStart) &&
              pr.achievedAt.isBefore(todayEnd),
        );
        hasRepsPR = repsPRs.any(
          (pr) =>
              pr.achievedAt.isAfter(todayStart) &&
              pr.achievedAt.isBefore(todayEnd),
        );
        hasVolumePR = volumePRs.any(
          (pr) =>
              pr.achievedAt.isAfter(todayStart) &&
              pr.achievedAt.isBefore(todayEnd),
        );
        hasDurationPR = durationPRs.any(
          (pr) =>
              pr.achievedAt.isAfter(todayStart) &&
              pr.achievedAt.isBefore(todayEnd),
        );
        hasDistancePR = distancePRs.any(
          (pr) =>
              pr.achievedAt.isAfter(todayStart) &&
              pr.achievedAt.isBefore(todayEnd),
        );

        // Build prsToday list with actual values
        if (hasWeightPR && maxWeight != null) {
          prsToday.add({'type': 'maxWeight', 'value': maxWeight});
        }
        if (hasRepsPR && maxReps != null) {
          prsToday.add({'type': 'maxReps', 'value': maxReps.toDouble()});
        }
        if (hasVolumePR && totalVolume != null) {
          prsToday.add({'type': 'maxVolume', 'value': totalVolume});
        }
        if (hasDurationPR && maxDuration != null) {
          prsToday.add({
            'type': 'maxDuration',
            'value': maxDuration.inSeconds.toDouble(),
          });
        }
        if (hasDistancePR && maxDistance != null) {
          prsToday.add({'type': 'maxDistance', 'value': maxDistance});
        }
      }

      exerciseDetails.add({
        'exerciseId': exerciseId,
        'exerciseName': firstSet.exerciseName,
        'exercise': firstSet.exercise,
        'setCount': setCount,
        'totalVolume': totalVolume,
        'maxReps': maxReps,
        'maxWeight': maxWeight,
        'maxDuration': maxDuration,
        'maxDistance': maxDistance,
        'maxAdditionalWeight': maxAdditionalWeight,
        'hasWeightPR': hasWeightPR,
        'hasRepsPR': hasRepsPR,
        'hasVolumePR': hasVolumePR,
        'hasDurationPR': hasDurationPR,
        'hasDistancePR': hasDistancePR,
        'prsToday': prsToday,
      });
    }

    return exerciseDetails;
  }
}
