import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

/// Detail card for individual exercise stats with PR tracking
class ExerciseDetailCard extends StatelessWidget {
  final String exerciseName;
  final int sets;
  final double volumeToday;
  final double? maxWeightToday;
  final double? prMaxWeight;
  final bool isPRToday;

  const ExerciseDetailCard({
    super.key,
    required this.exerciseName,
    required this.sets,
    required this.volumeToday,
    this.maxWeightToday,
    this.prMaxWeight,
    this.isPRToday = false,
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
                  isPR: isPRToday,
                  prValue: prMaxWeight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(
    String label,
    String value, {
    bool isPR = false,
    double? prValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            if (isPR) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.limeGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PR!',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        isPR
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.limeGreen,
                  borderRadius: BorderRadius.circular(4),
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
        if (prValue != null && prValue > 0 && !isPR) ...[
          const SizedBox(height: 2),
          Text(
            'Best: ${prValue.toInt()} kg',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText.withOpacity(0.4),
              height: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}
