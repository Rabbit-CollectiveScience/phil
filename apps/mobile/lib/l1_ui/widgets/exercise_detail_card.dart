import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Detail card for individual exercise stats
class ExerciseDetailCard extends StatelessWidget {
  final String exerciseName;
  final int sets;
  final double volumeToday;
  final double volumeBest;
  final double maxWeightToday;
  final double prMaxWeight;

  const ExerciseDetailCard({
    super.key,
    required this.exerciseName,
    required this.sets,
    required this.volumeToday,
    required this.volumeBest,
    required this.maxWeightToday,
    required this.prMaxWeight,
  });

  bool get isNewPR => maxWeightToday >= prMaxWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        border: isNewPR
            ? Border.all(color: AppColors.limeGreen, width: 2)
            : Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: isNewPR
                ? AppColors.limeGreen.withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
            blurRadius: isNewPR ? 20 : 16,
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
                  '${volumeToday.toInt()} kg',
                  'Best: ${volumeBest.toInt()} kg',
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
                  '${maxWeightToday.toInt()} kg',
                  'PR: ${prMaxWeight.toInt()} kg',
                  highlightValue: isNewPR,
                ),
              ),
            ],
          ),
          if (isNewPR) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.limeGreen,
                borderRadius: BorderRadius.zero,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 14,
                    color: AppColors.pureBlack,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'NEW PR!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.pureBlack,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricColumn(
    String label,
    String value,
    String subtitle, {
    bool highlightValue = false,
  }) {
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
        highlightValue
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.limeGreen,
                  borderRadius: BorderRadius.zero,
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.pureBlack,
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
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}
