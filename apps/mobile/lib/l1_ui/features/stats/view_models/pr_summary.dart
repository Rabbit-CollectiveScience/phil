import '../../../../l2_domain/legacy_models/pr_item_with_exercise.dart';

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
      lastPRDate = prs.first.formattedDate;
    }

    // Get 5 most recent PRs (already sorted)
    final recentPRs = prs.take(5).toList();

    // Group PRs by exercise category
    final prsByCategory = <String, List<PRItemWithExercise>>{};
    for (var pr in prs) {
      // Each PR can belong to multiple categories
      // Add it to each category it belongs to
      for (var category in pr.exerciseCategories) {
        final categoryKey = category.toUpperCase();
        if (!prsByCategory.containsKey(categoryKey)) {
          prsByCategory[categoryKey] = [];
        }
        prsByCategory[categoryKey]!.add(pr);
      }
    }

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
