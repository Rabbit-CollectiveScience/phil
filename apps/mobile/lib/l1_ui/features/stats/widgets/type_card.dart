import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/providers/preferences_provider.dart';
import 'metric_item.dart';

class TypeCard extends StatelessWidget {
  final String type;
  final int exercises;
  final int sets;
  final double volume;
  final double? duration; // in minutes
  final String? prExercise;
  final String? prValue;
  final String? bestVolumeExercise;
  final String? bestVolumeValue;

  const TypeCard({
    super.key,
    required this.type,
    required this.exercises,
    required this.sets,
    required this.volume,
    this.duration,
    this.prExercise,
    this.prValue,
    this.bestVolumeExercise,
    this.bestVolumeValue,
  });

  @override
  Widget build(BuildContext context) {
    final formatters = context.watch<PreferencesProvider>().formatters;
    final typeKey = type.toLowerCase();
    final iconPath = 'assets/images/exercise_types/$typeKey.png';
    final isCardio = typeKey == 'cardio';
    final hasData =
        exercises > 0 ||
        sets > 0 ||
        (isCardio ? (duration ?? 0) > 0 : volume > 0);
    final hasPR = prExercise != null && prValue != null;
    final hasBestVolume = bestVolumeExercise != null && bestVolumeValue != null;
    final hasNotableOutcome = hasPR || hasBestVolume;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: hasNotableOutcome
              ? AppColors.limeGreen
              : const Color(0xFFE0E0E0),
          width: hasNotableOutcome ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasNotableOutcome
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
          Row(
            children: [
              Image.asset(
                iconPath,
                width: 24,
                height: 24,
                color: hasData
                    ? AppColors.darkText
                    : AppColors.darkText.withOpacity(0.3),
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.fitness_center,
                    size: 24,
                    color: hasData
                        ? AppColors.darkText
                        : AppColors.darkText.withOpacity(0.3),
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                type,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: hasData
                      ? AppColors.darkText
                      : AppColors.darkText.withOpacity(0.3),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MetricItem(
                value: '$exercises',
                label: 'Exercises',
                hasData: hasData,
              ),
              MetricItem(value: '$sets', label: 'Sets', hasData: hasData),
              MetricItem(
                value: isCardio
                    ? '${(duration ?? 0).toInt()}'
                    : formatters.formatVolume(volume),
                label: isCardio ? 'Duration (min)' : 'Volume',
                hasData: hasData,
              ),
            ],
          ),
          if (hasNotableOutcome) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.limeGreen,
                borderRadius: BorderRadius.zero,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasPR) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: AppColors.pureBlack,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'NEW PR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.pureBlack,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$prExercise • $prValue',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pureBlack,
                      ),
                    ),
                  ],
                  if (hasPR && hasBestVolume) const SizedBox(height: 12),
                  if (hasBestVolume) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppColors.pureBlack,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'BEST VOLUME',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.pureBlack,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$bestVolumeExercise • $bestVolumeValue',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pureBlack,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
