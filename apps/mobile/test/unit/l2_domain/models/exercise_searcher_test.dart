import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercise_searcher.dart';
import 'package:phil/l2_domain/models/exercises/exercise.dart';
import 'package:phil/l2_domain/models/exercises/free_weight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/machine_exercise.dart';
import 'package:phil/l2_domain/models/exercises/bodyweight_exercise.dart';
import 'package:phil/l2_domain/models/common/muscle_group.dart';

void main() {
  group('ExerciseSearcher', () {
    late ExerciseSearcher searcher;
    late List<Exercise> exercises;

    setUp(() {
      searcher = ExerciseSearcher();
      exercises = [
        FreeWeightExercise(
          id: 'ex1',
          name: 'Barbell Bench Press',
          description:
              'Lie on a bench and press a barbell upward from chest level.',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
        ),
        MachineExercise(
          id: 'ex2',
          name: 'Calf Raise Machine',
          description:
              'Stand in a calf raise machine with shoulders under the pads and balls of feet on the platform.',
          isCustom: false,
          targetMuscles: [MuscleGroup.legs],
        ),
        MachineExercise(
          id: 'ex3',
          name: 'Seated Shoulder Press Machine',
          description:
              'Sit in the machine and press handles overhead using your shoulders.',
          isCustom: false,
          targetMuscles: [MuscleGroup.shoulders],
        ),
        BodyweightExercise(
          id: 'ex4',
          name: 'Pull-Up',
          description:
              'Hang from a bar and pull yourself up until chin is over the bar.',
          isCustom: false,
          targetMuscles: [MuscleGroup.back],
          canAddWeight: true,
        ),
        FreeWeightExercise(
          id: 'ex5',
          name: 'Lateral Raise',
          description:
              'Stand holding dumbbells at your sides and raise them to shoulder height.',
          isCustom: false,
          targetMuscles: [MuscleGroup.shoulders],
        ),
      ];
    });

    test('finds exercise when query matches name exactly', () {
      final results = searcher.search(exercises, 'Barbell Bench Press');

      expect(results, isNotEmpty);
      expect(results.first.name, 'Barbell Bench Press');
    });

    test('finds exercise when query matches name partially', () {
      final results = searcher.search(exercises, 'bench press');

      expect(results, isNotEmpty);
      expect(results.first.name, 'Barbell Bench Press');
    });

    test('finds exercise when query matches description', () {
      final results = searcher.search(exercises, 'standing calf');

      expect(results, isNotEmpty);
      expect(results.any((ex) => ex.name == 'Calf Raise Machine'), isTrue);
    });

    test('ranks name match higher than description match', () {
      final results = searcher.search(exercises, 'shoulder press');

      expect(results, isNotEmpty);
      // "Seated Shoulder Press Machine" should rank higher than "Barbell Bench Press"
      // even though both contain "press"
      expect(
        results.first.name,
        contains('Shoulder'),
        reason: 'Name match should score higher',
      );
    });

    test('handles multi-word queries', () {
      final results = searcher.search(exercises, 'machine shoulder seated');

      expect(results, isNotEmpty);
      expect(results.first.name, 'Seated Shoulder Press Machine');
    });

    test('matches based on target muscles', () {
      final results = searcher.search(exercises, 'shoulder');

      expect(results, isNotEmpty);
      expect(results.length, greaterThanOrEqualTo(2));
      expect(
        results.any((ex) => ex.name == 'Seated Shoulder Press Machine'),
        isTrue,
      );
      expect(results.any((ex) => ex.name == 'Lateral Raise'), isTrue);
    });

    test('returns empty list when no matches above threshold', () {
      final results = searcher.search(exercises, 'xyz123nonexistent');

      expect(results, isEmpty);
    });

    test('returns empty list for empty query', () {
      final results = searcher.search(exercises, '');

      expect(results, isEmpty);
    });

    test('returns empty list for whitespace-only query', () {
      final results = searcher.search(exercises, '   ');

      expect(results, isEmpty);
    });

    test('ignores very short tokens (1-2 chars)', () {
      final results = searcher.search(exercises, 'a b bench');

      // Should still find bench press, ignoring "a" and "b"
      expect(results, isNotEmpty);
      expect(results.first.name, contains('Bench'));
    });

    test('is case-insensitive', () {
      final results1 = searcher.search(exercises, 'BENCH PRESS');
      final results2 = searcher.search(exercises, 'bench press');
      final results3 = searcher.search(exercises, 'BeNcH pReSs');

      expect(results1, isNotEmpty);
      expect(results2, isNotEmpty);
      expect(results3, isNotEmpty);
      expect(results1.first.name, results2.first.name);
      expect(results2.first.name, results3.first.name);
    });

    test('sorts results by relevance score descending', () {
      final results = searcher.search(exercises, 'press');

      expect(results, isNotEmpty);
      expect(results.length, greaterThanOrEqualTo(2));

      // "Seated Shoulder Press Machine" has "press" in name
      // "Barbell Bench Press" has "press" in name
      // Both should appear, with name matches scoring high
      final firstResult = results.first;
      expect(firstResult.name, contains('Press'));
    });

    test('combines multiple matching factors for higher score', () {
      final results = searcher.search(exercises, 'shoulder machine');

      expect(results, isNotEmpty);
      // "Seated Shoulder Press Machine" should score highest:
      // - "shoulder" in name (10 pts)
      // - "machine" in name (10 pts)
      // - "shoulder" in target muscles (5 pts)
      // - both words in description (3+3 pts)
      expect(results.first.name, 'Seated Shoulder Press Machine');
    });

    test('returns results for single token query', () {
      final results = searcher.search(exercises, 'calf');

      expect(results, isNotEmpty);
      expect(results.first.name, 'Calf Raise Machine');
    });

    test('handles special characters in query', () {
      final results = searcher.search(exercises, 'pull-up');

      expect(results, isNotEmpty);
      expect(results.any((ex) => ex.name == 'Pull-Up'), isTrue);
    });

    test('filters out results below minimum score threshold', () {
      final results = searcher.search(exercises, 'xyz nonexistent word');

      // Words that don't match anything should return empty
      expect(results, isEmpty);
    });
  });
}
