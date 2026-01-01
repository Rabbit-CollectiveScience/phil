import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/exercises/search_exercises_use_case.dart';
import 'package:phil/l3_data/repositories/exercise_repository.dart';
import 'package:phil/l3_data/repositories/stub_exercise_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ExerciseRepository exerciseRepository;
  late SearchExercisesUseCase useCase;

  setUp(() {
    exerciseRepository = StubExerciseRepository();
    useCase = SearchExercisesUseCase(exerciseRepository);
  });

  group('SearchExercisesUseCase', () {
    test('returns empty list when search query is empty', () async {
      final result = await useCase.execute(searchQuery: '');

      expect(result, isEmpty);
    });

    test('returns empty list when search query is only whitespace', () async {
      final result = await useCase.execute(searchQuery: '   ');

      expect(result, isEmpty);
    });

    test('finds exercises matching search query (case-insensitive)', () async {
      final result = await useCase.execute(searchQuery: 'press');

      expect(result.length, greaterThan(0));
      expect(
        result.every((ex) => ex.name.toLowerCase().contains('press')),
        isTrue,
      );
    });

    test('returns exact match first in results', () async {
      final result = await useCase.execute(searchQuery: 'bench press');

      expect(result.isNotEmpty, isTrue);
      expect(result.first.name.toLowerCase(), contains('bench press'));
    });

    test('prioritizes starts-with matches over contains matches', () async {
      final result = await useCase.execute(searchQuery: 'bench');

      expect(result.isNotEmpty, isTrue);
      // First result should start with "bench"
      expect(result.first.name.toLowerCase().startsWith('bench'), isTrue);
    });

    test('searches across all exercises, not just recommended ones', () async {
      // Search should return any exercise, not filtered by personalization
      final result = await useCase.execute(searchQuery: 'a');

      // Should return multiple exercises containing 'a'
      expect(result.length, greaterThan(1));
    });

    test('returns empty list when no exercises match query', () async {
      final result = await useCase.execute(
        searchQuery: 'nonexistentexercise12345',
      );

      expect(result, isEmpty);
    });
  });
}
