import 'personal_record.dart';

/// View model for displaying a single PR with exercise context
class PRItemWithExercise {
  final PersonalRecord prRecord;
  final String exerciseName;
  final List<String> exerciseCategories;

  PRItemWithExercise({
    required this.prRecord,
    required this.exerciseName,
    required this.exerciseCategories,
  });

  /// Get days since this PR was achieved
  int get daysAgo {
    final now = DateTime.now();
    final difference = now.difference(prRecord.achievedAt);
    return difference.inDays;
  }

  /// Format the PR value based on type
  String get formattedValue {
    final value = prRecord.value;
    final type = prRecord.type;

    if (type == 'maxWeight' || type == 'maxVolume') {
      return '${value.toInt()} kg';
    } else if (type == 'maxReps') {
      return '${value.toInt()} reps';
    } else if (type == 'maxDistance') {
      return '${value.toInt()} m';
    } else if (type == 'maxDuration') {
      final seconds = value.toInt();
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (minutes > 0) {
        return '${minutes}m ${remainingSeconds}s';
      }
      return '${seconds}s';
    }
    return value.toStringAsFixed(1);
  }

  /// Format the PR type for display
  String get formattedType {
    final type = prRecord.type;
    // Remove 'max' prefix and add spaces
    final withoutMax = type.substring(3); // Remove 'max'
    final spaced = withoutMax
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim();
    return spaced.toUpperCase();
  }

  /// Format date for display
  String get formattedDate {
    final date = prRecord.achievedAt;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
