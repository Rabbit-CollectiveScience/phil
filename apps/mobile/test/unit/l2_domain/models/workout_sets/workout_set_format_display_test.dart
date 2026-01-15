import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/workout_sets/weighted_workout_set.dart';
import 'package:phil/l2_domain/models/workout_sets/bodyweight_workout_set.dart';
import 'package:phil/l2_domain/models/workout_sets/isometric_workout_set.dart';
import 'package:phil/l2_domain/models/workout_sets/distance_cardio_workout_set.dart';
import 'package:phil/l2_domain/models/workout_sets/duration_cardio_workout_set.dart';
import 'package:phil/l2_domain/models/common/weight.dart';
import 'package:phil/l2_domain/models/common/distance.dart';

void main() {
  group('WorkoutSet formatForDisplay Tests', () {
    group('WeightedWorkoutSet', () {
      test('formats with weight and reps', () {
        final set = WeightedWorkoutSet(
          id: 'test1',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          weight: Weight(50.0),
          reps: 10,
        );
        expect(set.formatForDisplay(), '50.0 kg × 10 reps');
      });

      test('formats with single rep', () {
        final set = WeightedWorkoutSet(
          id: 'test2',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          weight: Weight(100.0),
          reps: 1,
        );
        expect(set.formatForDisplay(), '100.0 kg × 1 rep');
      });

      test('handles null weight', () {
        final set = WeightedWorkoutSet(
          id: 'test3',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          weight: null,
          reps: 5,
        );
        expect(set.formatForDisplay(), '-- kg × 5 reps');
      });

      test('handles null reps', () {
        final set = WeightedWorkoutSet(
          id: 'test4',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          weight: Weight(60.0),
          reps: null,
        );
        expect(set.formatForDisplay(), '60.0 kg × -- rep');
      });
    });

    group('BodyweightWorkoutSet', () {
      test('formats bodyweight only', () {
        final set = BodyweightWorkoutSet(
          id: 'test1',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          reps: 15,
          additionalWeight: null,
        );
        expect(set.formatForDisplay(), '15 reps · Bodyweight');
      });

      test('formats with additional weight', () {
        final set = BodyweightWorkoutSet(
          id: 'test2',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          reps: 8,
          additionalWeight: Weight(10.0),
        );
        expect(set.formatForDisplay(), '8 reps · BW + 10.0 kg');
      });

      test('formats with additional weight as zero', () {
        final set = BodyweightWorkoutSet(
          id: 'test3',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          reps: 12,
          additionalWeight: Weight(0),
        );
        expect(set.formatForDisplay(), '12 reps · Bodyweight');
      });

      test('formats single rep', () {
        final set = BodyweightWorkoutSet(
          id: 'test4',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          reps: 1,
          additionalWeight: Weight(5.0),
        );
        expect(set.formatForDisplay(), '1 rep · BW + 5.0 kg');
      });
    });

    group('IsometricWorkoutSet', () {
      test('formats bodyweight-based with weight', () {
        final set = IsometricWorkoutSet(
          id: 'test1',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          duration: Duration(seconds: 60),
          weight: Weight(10.0),
          isBodyweightBased: true,
        );
        expect(set.formatForDisplay(), '60 sec · BW + 10 kg');
      });

      test('formats bodyweight-based without weight', () {
        final set = IsometricWorkoutSet(
          id: 'test2',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          duration: Duration(seconds: 45),
          weight: null,
          isBodyweightBased: true,
        );
        expect(set.formatForDisplay(), '45 sec · Bodyweight');
      });

      test('formats loaded static hold with weight', () {
        final set = IsometricWorkoutSet(
          id: 'test3',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          duration: Duration(seconds: 30),
          weight: Weight(50.0),
          isBodyweightBased: false,
        );
        expect(set.formatForDisplay(), '30 sec · 50 kg');
      });

      test('formats loaded static hold without weight', () {
        final set = IsometricWorkoutSet(
          id: 'test4',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          duration: Duration(seconds: 20),
          weight: null,
          isBodyweightBased: false,
        );
        expect(set.formatForDisplay(), '20 sec');
      });

      test('formats whole number weight without decimal', () {
        final set = IsometricWorkoutSet(
          id: 'test5',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          duration: Duration(seconds: 40),
          weight: Weight(15.0),
          isBodyweightBased: true,
        );
        expect(set.formatForDisplay(), '40 sec · BW + 15 kg');
      });
    });

    group('DistanceCardioWorkoutSet', () {
      test('formats with distance and duration', () {
        final set = DistanceCardioWorkoutSet(
          id: 'test1',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          distance: Distance(5000.0), // 5km in meters
          duration: Duration(minutes: 30),
        );
        expect(set.formatForDisplay(), '5.0 km · 30 min');
      });

      test('handles null distance', () {
        final set = DistanceCardioWorkoutSet(
          id: 'test2',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          distance: null,
          duration: Duration(minutes: 20),
        );
        expect(set.formatForDisplay(), '-- km · 20 min');
      });

      test('handles null duration', () {
        final set = DistanceCardioWorkoutSet(
          id: 'test3',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          distance: Distance(3500.0), // 3.5km in meters
          duration: null,
        );
        expect(set.formatForDisplay(), '3.5 km · -- min');
      });
    });

    group('DurationCardioWorkoutSet', () {
      test('formats duration', () {
        final set = DurationCardioWorkoutSet(
          id: 'test1',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          duration: Duration(minutes: 45),
        );
        expect(set.formatForDisplay(), '45 min');
      });

      test('handles null duration', () {
        final set = DurationCardioWorkoutSet(
          id: 'test2',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          duration: null,
        );
        expect(set.formatForDisplay(), '-- min');
      });
    });
  });
}
