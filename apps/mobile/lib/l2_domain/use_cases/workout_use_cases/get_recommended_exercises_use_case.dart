import '../../models/exercise.dart';
import '../../../l3_data/repositories/exercise_repository.dart';

// Use Case: Get recommended exercises for workout session
//
// Responsibility:
// - Load all available exercises from data source
// - Apply user preferences/filters if any
// - Sort by recommendation logic (e.g., recently used, favorites)
//
// Used by: WorkoutHomePage on app start

class GetRecommendedExercisesUseCase {
  final ExerciseRepository _repository;

  GetRecommendedExercisesUseCase(this._repository);

  Future<List<Exercise>> execute() async {
    // Load all available exercises
    final exercises = await _repository.getAllExercises();

    // TODO: Apply user preferences/filters if any
    // TODO: Sort by recommendation logic (e.g., recently used, favorites, etc.)

    // For testing: Return diverse exercises with different field configurations
    // This ensures we test all field types and counts (1-3 fields)
    final Map<String, Exercise> exerciseMap = {
      for (var e in exercises) e.id: e,
    };

    final testExercises = <Exercise>[];

    // Cardio with 3 fields (duration + reps + height) - test max field count first
    if (exerciseMap.containsKey('cardio_17'))
      testExercises.add(exerciseMap['cardio_17']!); // Box Step-Ups: 3 fields

    // Strength exercises (2 fields: weight + reps)
    if (exerciseMap.containsKey('legs_1'))
      testExercises.add(exerciseMap['legs_1']!);
    if (exerciseMap.containsKey('chest_1'))
      testExercises.add(exerciseMap['chest_1']!);
    if (exerciseMap.containsKey('back_1'))
      testExercises.add(exerciseMap['back_1']!);

    // Cardio exercises (2 fields, varying types)
    if (exerciseMap.containsKey('cardio_1'))
      testExercises.add(exerciseMap['cardio_1']!); // 2 fields: duration + speed
    if (exerciseMap.containsKey('cardio_5'))
      testExercises.add(
        exerciseMap['cardio_5']!,
      ); // 2 fields: duration + distance

    // Flexibility exercises (1-2 fields, different combos)
    if (exerciseMap.containsKey('flex_6'))
      testExercises.add(exerciseMap['flex_6']!); // 1 field: reps only
    if (exerciseMap.containsKey('flex_1'))
      testExercises.add(exerciseMap['flex_1']!); // 2 fields: holdTime + side
    if (exerciseMap.containsKey('flex_3'))
      testExercises.add(exerciseMap['flex_3']!); // 2 fields: holdTime + reps

    // If we don't have enough test exercises, fill with remaining
    if (testExercises.length < 10) {
      for (var exercise in exercises) {
        if (!testExercises.contains(exercise)) {
          testExercises.add(exercise);
          if (testExercises.length >= 10) break;
        }
      }
    }

    return testExercises;
  }
}
