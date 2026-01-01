import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

/// Chip/tag displaying exercise type
class ExerciseTypeChip extends StatelessWidget {
  final String type;

  const ExerciseTypeChip({super.key, required this.type});

  String _getIconPath(String type) {
    final typeKey = type.toLowerCase();
    return 'assets/images/exercise_types/$typeKey.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.limeGreen.withOpacity(0.15),
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            _getIconPath(type),
            width: 14,
            height: 14,
            color: AppColors.darkText,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.fitness_center,
                size: 14,
                color: AppColors.darkText,
              );
            },
          ),
          const SizedBox(width: 6),
          Text(
            type,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
