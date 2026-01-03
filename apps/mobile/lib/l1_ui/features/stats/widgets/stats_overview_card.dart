import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import 'metric_tile.dart';
import '../../../shared/widgets/exercise_type_chip.dart';

/// Overview card showing today's workout summary
class StatsOverviewCard extends StatelessWidget {
  final int setsCount;
  final int exercisesCount;
  final double totalVolume;
  final double avgReps;
  final List<String> exerciseTypes;

  const StatsOverviewCard({
    super.key,
    required this.setsCount,
    required this.exercisesCount,
    required this.totalVolume,
    required this.avgReps,
    required this.exerciseTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2x2 Grid of metrics
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              MetricTile(value: setsCount.toString(), label: 'SETS'),
              MetricTile(value: exercisesCount.toString(), label: 'EXERCISES'),
              MetricTile(value: '${totalVolume.toInt()}', label: 'VOLUME (KG)'),
              MetricTile(value: avgReps.toStringAsFixed(1), label: 'AVG REPS'),
            ],
          ),
          if (exerciseTypes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.darkGrey),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exerciseTypes
                  .map((type) => ExerciseTypeChip(type: type))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
