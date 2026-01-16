import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/providers/preferences_provider.dart';
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
    final formatters = context.watch<PreferencesProvider>().formatters;

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
          Text(
            'OVERVIEW',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText.withOpacity(0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 32),
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
              MetricTile(
                value: formatters.formatVolume(totalVolume, includeUnit: false),
                label: formatters.getVolumeLabel(),
              ),
              MetricTile(value: avgReps.toStringAsFixed(1), label: 'AVG REPS'),
            ],
          ),
          const SizedBox(height: 8),
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
