import '../../../../l2_domain/models/pr_item_with_exercise.dart';

/// Summary data for the PR view
class PRSummary {
  final int totalPRs;
  final int daysSinceLastPR;
  final List<PRItemWithExercise> recentPRs;
  final Map<String, List<PRItemWithExercise>> prsByCategory;

  PRSummary({
    required this.totalPRs,
    required this.daysSinceLastPR,
    required this.recentPRs,
    required this.prsByCategory,
  });

  /// Create summary from list of enriched PRs
  /// PRs should already be sorted by date (newest first)
  factory PRSummary.fromPRList(List<PRItemWithExercise> prs) {
    final totalPRs = prs.length;

    // Calculate days since last PR
    int daysSinceLastPR = 999;
    if (prs.isNotEmpty) {
      daysSinceLastPR = prs.first.daysAgo;
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
      daysSinceLastPR: daysSinceLastPR,
      recentPRs: recentPRs,
      prsByCategory: sortedCategories,
    );
  }

  /// Empty summary for when there are no PRs
  factory PRSummary.empty() {
    return PRSummary(
      totalPRs: 0,
      daysSinceLastPR: 999,
      recentPRs: [],
      prsByCategory: {},
    );
  }
}
