import '../../../../l2_domain/use_cases/personal_records/get_all_prs_use_case.dart';

/// Summary data for the PR view
class PRSummary {
  final int totalPRs;
  final String lastPRDate;
  final List<PRItemWithExercise> recentPRs;
  final Map<String, List<PRItemWithExercise>> prsByCategory;

  PRSummary({
    required this.totalPRs,
    required this.lastPRDate,
    required this.recentPRs,
    required this.prsByCategory,
  });

  /// Create summary from list of enriched PRs
  /// PRs should already be sorted by date (newest first)
  factory PRSummary.fromPRList(List<PRItemWithExercise> prs) {
    final totalPRs = prs.length;

    // Get formatted date of last PR
    String lastPRDate = 'Never';
    if (prs.isNotEmpty) {
      final date = prs.first.prRecord.achievedAt;
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      lastPRDate = '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    }

    // Get 5 most recent PRs (already sorted)
    final recentPRs = prs.take(5).toList();

    // Group PRs by muscle group (simplified - using first muscle group only)
    final prsByCategory = <String, List<PRItemWithExercise>>{};
    // Note: The prsByCategory feature is simplified for now since we don't have
    // the exerciseCategories field anymore. This would need a more sophisticated
    // implementation based on the Exercise model's targetMuscles property.

    // Sort categories alphabetically
    final sortedCategories = Map.fromEntries(
      prsByCategory.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    return PRSummary(
      totalPRs: totalPRs,
      lastPRDate: lastPRDate,
      recentPRs: recentPRs,
      prsByCategory: sortedCategories,
    );
  }

  /// Empty summary for when there are no PRs
  factory PRSummary.empty() {
    return PRSummary(
      totalPRs: 0,
      lastPRDate: 'Never',
      recentPRs: [],
      prsByCategory: {},
    );
  }
}
