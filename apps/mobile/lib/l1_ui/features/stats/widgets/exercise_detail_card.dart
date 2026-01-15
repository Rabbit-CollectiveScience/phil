import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../view_models/exercise_detail_today.dart';
import '../../../../l2_domain/models/exercises/isometric_exercise.dart';
import '../../../../l2_domain/models/exercises/distance_cardio_exercise.dart';
import '../../../../l2_domain/models/exercises/duration_cardio_exercise.dart';
import '../../../../l2_domain/models/exercises/bodyweight_exercise.dart';

/// Detail card for individual exercise stats with PR tracking
class ExerciseDetailCard extends StatelessWidget {
  final String exerciseName;
  final int sets;
  final double volumeToday;
  final double? maxWeightToday;
  final int? maxReps;
  final Duration? maxDuration;
  final double? maxDistance;
  final double? maxAdditionalWeight;
  final List<PRToday> prsToday;
  final dynamic exercise;

  const ExerciseDetailCard({
    super.key,
    required this.exerciseName,
    required this.sets,
    required this.volumeToday,
    this.maxWeightToday,
    this.maxReps,
    this.maxDuration,
    this.maxDistance,
    this.maxAdditionalWeight,
    this.prsToday = const [],
    this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final hasPRs = prsToday.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: hasPRs ? AppColors.limeGreen : const Color(0xFFE0E0E0),
          width: hasPRs ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasPRs
                ? AppColors.limeGreen.withOpacity(0.15)
                : Colors.white.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Exercise name + sets badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exerciseName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkGrey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$sets SETS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Metrics grid - dynamic based on exercise type
          _buildMetricsGrid(),
          // PR badges at the bottom (if any)
          if (prsToday.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sortPRsByDisplayOrder().map((pr) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.limeGreen,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        _formatPRType(pr.type),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    // Determine exercise type and build appropriate metrics
    if (exercise is IsometricExercise) {
      return _buildIsometricMetrics();
    } else if (exercise is DistanceCardioExercise) {
      return _buildDistanceCardioMetrics();
    } else if (exercise is DurationCardioExercise) {
      return _buildDurationCardioMetrics();
    } else if (exercise is BodyweightExercise) {
      return _buildBodyweightMetrics();
    } else {
      // Default: weighted strength exercises
      return _buildWeightedMetrics();
    }
  }

  Widget _buildIsometricMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricColumn(
            'Max Duration',
            maxDuration != null ? '${maxDuration!.inSeconds} sec' : '-',
            isPR: _hasPR('maxDuration'),
          ),
        ),
        _buildDivider(),
        Expanded(
          child: _buildMetricColumn(
            'Max Reps',
            maxReps != null ? '$maxReps' : '-',
            isPR: _hasPR('maxReps'),
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceCardioMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricColumn(
            'Max Distance',
            maxDistance != null
                ? '${(maxDistance! / 1000).toStringAsFixed(1)} km'
                : '-',
            isPR: _hasPR('maxDistance'),
          ),
        ),
        _buildDivider(),
        Expanded(
          child: _buildMetricColumn(
            'Max Duration',
            maxDuration != null ? '${maxDuration!.inMinutes} min' : '-',
            isPR: _hasPR('maxDuration'),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationCardioMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricColumn(
            'Max Duration',
            maxDuration != null ? '${maxDuration!.inMinutes} min' : '-',
            isPR: _hasPR('maxDuration'),
          ),
        ),
        _buildDivider(),
        Expanded(
          child: _buildMetricColumn(
            'Volume',
            volumeToday > 0 ? '${volumeToday.toInt()} min' : '-',
            isPR: _hasPR('maxVolume'),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyweightMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricColumn(
            'Max Reps',
            maxReps != null ? '$maxReps' : '-',
            isPR: _hasPR('maxReps'),
          ),
        ),
        _buildDivider(),
        Expanded(
          child: _buildMetricColumn(
            'Max Added Weight',
            (maxAdditionalWeight != null && maxAdditionalWeight! > 0)
                ? '${maxAdditionalWeight!.toInt()} kg'
                : '-',
            isPR:
                false, // Additional weight doesn't have separate PR tracking yet
          ),
        ),
      ],
    );
  }

  Widget _buildWeightedMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricColumn(
            'Volume',
            volumeToday > 0 ? '${volumeToday.toInt()} kg' : '-',
            isPR: _hasPR('maxVolume'),
          ),
        ),
        _buildDivider(),
        Expanded(
          child: _buildMetricColumn(
            'Max Weight',
            (maxWeightToday != null && maxWeightToday! > 0)
                ? '${maxWeightToday!.toInt()} kg'
                : '-',
            isPR: _hasPR('maxWeight'),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: AppColors.darkGrey.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildMetricColumn(String label, String value, {bool isPR = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText.withOpacity(0.5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        isPR
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.limeGreen,
                  borderRadius: BorderRadius.zero,
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    height: 1.0,
                  ),
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkText,
                  height: 1.0,
                ),
              ),
      ],
    );
  }

  bool _hasPR(String prType) {
    return prsToday.any((pr) => pr.type == prType);
  }

  List<PRToday> _sortPRsByDisplayOrder() {
    // Define the order based on how metrics are displayed
    final orderPriority = {
      'maxVolume': 0,
      'maxWeight': 1,
      'maxReps': 2,
      'maxDistance': 3,
      'maxDuration': 4,
    };

    final sorted = List<PRToday>.from(prsToday);
    sorted.sort((a, b) {
      final aPriority = orderPriority[a.type] ?? 999;
      final bPriority = orderPriority[b.type] ?? 999;
      return aPriority.compareTo(bPriority);
    });
    return sorted;
  }

  String _formatPRType(String type) {
    // Convert 'maxWeight' to 'Max Weight', 'maxReps' to 'Max Reps', etc.
    final withoutMax = type.substring(3); // Remove 'max' prefix
    // Add space before capital letters
    final spaced = withoutMax
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim();
    return 'PR ${spaced.toUpperCase()}';
  }
}
