import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Validates exercise names and parameters against the exercise database
class ExerciseValidator {
  static ExerciseValidator? _instance;
  List<Map<String, dynamic>>? _exercises;
  bool _isInitialized = false;

  ExerciseValidator._();

  /// Get singleton instance
  static ExerciseValidator getInstance() {
    _instance ??= ExerciseValidator._();
    return _instance!;
  }

  /// Load exercise database from assets
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle
          .loadString('assets/data/exercises/index.json');
      final jsonData = json.decode(jsonString);
      _exercises = List<Map<String, dynamic>>.from(
        jsonData['exercises'].map((e) => Map<String, dynamic>.from(e)),
      );
      _isInitialized = true;
    } catch (e) {
      print('Error loading exercise database: $e');
      _exercises = [];
    }
  }

  /// Find exercise by exact name match
  Map<String, dynamic>? findExerciseByName(String name) {
    if (!_isInitialized || _exercises == null) {
      throw StateError('ExerciseValidator not initialized. Call initialize() first.');
    }

    // Try exact match first (case-insensitive)
    final normalizedName = name.toLowerCase().trim();
    for (final exercise in _exercises!) {
      if (exercise['name'].toString().toLowerCase() == normalizedName) {
        return exercise;
      }
    }

    return null;
  }

  /// Find exercise by ID
  Map<String, dynamic>? findExerciseById(String id) {
    if (!_isInitialized || _exercises == null) {
      throw StateError('ExerciseValidator not initialized. Call initialize() first.');
    }

    for (final exercise in _exercises!) {
      if (exercise['id'] == id) {
        return exercise;
      }
    }

    return null;
  }

  /// Find closest matching exercise using fuzzy matching
  /// Returns the best match and its similarity score (0-1)
  ({Map<String, dynamic>? exercise, double similarity})? findClosestMatch(
    String name,
    {String? category, double minSimilarity = 0.6}
  ) {
    if (!_isInitialized || _exercises == null) {
      throw StateError('ExerciseValidator not initialized. Call initialize() first.');
    }

    Map<String, dynamic>? bestMatch;
    double bestScore = 0.0;

    final normalizedSearch = name.toLowerCase().trim();

    for (final exercise in _exercises!) {
      // Filter by category if specified
      if (category != null && exercise['category'] != category) {
        continue;
      }

      final exerciseName = exercise['name'].toString().toLowerCase();
      final score = _calculateSimilarity(normalizedSearch, exerciseName);

      if (score > bestScore) {
        bestScore = score;
        bestMatch = exercise;
      }
    }

    if (bestScore >= minSimilarity && bestMatch != null) {
      return (exercise: bestMatch, similarity: bestScore);
    }

    return null;
  }

  /// Calculate similarity between two strings using Levenshtein distance
  /// Returns a score between 0 (completely different) and 1 (identical)
  double _calculateSimilarity(String s1, String s2) {
    // Handle exact matches
    if (s1 == s2) return 1.0;

    // Handle empty strings
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    // Calculate Levenshtein distance
    final distance = _levenshteinDistance(s1, s2);
    final maxLength = s1.length > s2.length ? s1.length : s2.length;

    // Convert distance to similarity score
    return 1.0 - (distance / maxLength);
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    // Create a matrix
    final matrix = List.generate(
      len1 + 1,
      (i) => List.generate(len2 + 1, (j) => 0),
    );

    // Initialize first row and column
    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    // Fill in the rest of the matrix
    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  /// Validate that an exercise belongs to the expected category
  bool validateCategory(String exerciseName, String expectedCategory) {
    final exercise = findExerciseByName(exerciseName);
    if (exercise == null) return false;
    return exercise['category'] == expectedCategory;
  }

  /// Get all exercises for a specific category
  List<Map<String, dynamic>> getExercisesByCategory(String category) {
    if (!_isInitialized || _exercises == null) {
      throw StateError('ExerciseValidator not initialized. Call initialize() first.');
    }

    return _exercises!
        .where((e) => e['category'] == category)
        .toList();
  }

  /// Check if exercise database is loaded
  bool get isInitialized => _isInitialized;

  /// Get total number of exercises
  int get totalExercises => _exercises?.length ?? 0;
}
