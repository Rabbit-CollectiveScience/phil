import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../view_models/exercise_detail_today.dart';

/// Detail card for individual exercise stats with PR tracking
class ExerciseDetailCard extends StatelessWidget {
  final String exerciseName;
  final int sets;
  final double volumeToday;
  final double? maxWeightToday;
  final List<PRToday> prsToday;

  const ExerciseDetailCard({
    super.key,
    required this.exerciseName,
    required this.sets,
    required this.volumeToday,
    this.maxWeightToday,
    this.prsToday = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
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
          // Metrics grid
          Row(
            children: [
              Expanded(
                child: _buildMetricColumn(
                  'Volume',
                  volumeToday > 0
                      ? '${volumeToday.toInt()} kg'
                      : volumeToday == 0
                      ? '-'
                      : '${volumeToday.toInt()} reps',
                  isPR: _hasPR('maxVolume'),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.darkGrey.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
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
          ),
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

  String _formatPRValue(String type, double value) {
    // Format based on PR type
    if (type == 'maxWeight' || type == 'maxVolume') {
      return '${value.toInt()} kg';
    } else if (type == 'maxReps') {
      return '${value.toInt()} reps';
    } else if (type == 'maxDistance') {
      return '${value.toInt()} m';
    } else if (type == 'maxDuration') {
      return '${value.toInt()} s';
    }
    return value.toStringAsFixed(1);
  }
}
