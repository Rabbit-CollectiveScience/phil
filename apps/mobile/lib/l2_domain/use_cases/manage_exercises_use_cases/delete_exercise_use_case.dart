// Use Case: Delete an exercise (Analyze Mode)
//
// Responsibility:
// - Remove exercise from system
// - Optionally handle related workout sets (cascade delete or warn)
// - Update repository
//
// Used by: Analyze mode pages for removing exercises from catalog

class DeleteExerciseUseCase {
  Future<void> execute(String exerciseId) async {
    // TODO: Implement
    // - Validate exercise exists
    // - Check for related workout sets (optional warning)
    // - Delete from repository
    throw UnimplementedError();
  }
}
