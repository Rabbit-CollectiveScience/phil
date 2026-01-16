import 'exercises/exercise.dart';
import 'exercises/strength_exercise.dart';

/// Domain model for searching exercises using token-based weighted matching.
///
/// This searcher implements a sophisticated search algorithm that:
/// - Breaks queries into tokens (words)
/// - Searches across name, description, and target muscles
/// - Weights matches: name (10pts) > target muscles (5pts) > description (3pts)
/// - Filters results by minimum score threshold
/// - Sorts results by relevance
///
/// Example:
/// ```dart
/// final searcher = ExerciseSearcher();
/// final results = searcher.search(exercises, 'shoulder machine standing');
/// // Returns exercises matching those tokens, ranked by relevance
/// ```
class ExerciseSearcher {
  // Scoring weights
  static const int _nameMatchScore = 10;
  static const int _descriptionMatchScore = 3;
  static const int _targetMuscleMatchScore = 5;

  // Minimum token length to consider (ignore "a", "in", "at", etc.)
  static const int _minTokenLength = 3;

  /// Search exercises using token-based matching with weighted scoring.
  ///
  /// Returns exercises sorted by relevance (highest score first).
  /// Returns empty list if query is empty or no matches found.
  List<Exercise> search(List<Exercise> exercises, String query) {
    // Extract tokens from query
    final tokens = _extractTokens(query);

    if (tokens.isEmpty) {
      return [];
    }

    // Score each exercise
    final scoredExercises = <_ScoredExercise>[];

    for (final exercise in exercises) {
      final score = _calculateScore(exercise, tokens);

      // Only include if meets minimum threshold
      // Threshold: at least one match per token on average
      if (score >= tokens.length * _descriptionMatchScore) {
        scoredExercises.add(_ScoredExercise(exercise, score));
      }
    }

    // Sort by score descending
    scoredExercises.sort((a, b) => b.score.compareTo(a.score));

    // Return exercises only (strip scores)
    return scoredExercises.map((se) => se.exercise).toList();
  }

  /// Extract searchable tokens from query string.
  ///
  /// Filters out very short words and trims whitespace.
  List<String> _extractTokens(String query) {
    return query
        .toLowerCase()
        .split(RegExp(r'\s+')) // Split on whitespace
        .where((token) => token.length >= _minTokenLength)
        .toList();
  }

  /// Calculate weighted score for an exercise based on token matches.
  int _calculateScore(Exercise exercise, List<String> tokens) {
    int score = 0;

    final nameLower = exercise.name.toLowerCase();
    final descLower = exercise.description.toLowerCase();

    for (final token in tokens) {
      // Name match (highest priority)
      if (nameLower.contains(token)) {
        score += _nameMatchScore;
      }

      // Description match
      if (descLower.contains(token)) {
        score += _descriptionMatchScore;
      }

      // Target muscles match (for strength exercises)
      if (exercise is StrengthExercise) {
        if (exercise.targetMuscles
            .any((muscle) => muscle.name.toLowerCase().contains(token))) {
          score += _targetMuscleMatchScore;
        }
      }
    }

    return score;
  }
}

/// Internal class to hold exercise with its relevance score.
class _ScoredExercise {
  final Exercise exercise;
  final int score;

  _ScoredExercise(this.exercise, this.score);
}
