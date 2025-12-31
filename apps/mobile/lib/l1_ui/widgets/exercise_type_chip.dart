import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Chip/tag displaying exercise type
class ExerciseTypeChip extends StatelessWidget {
  final String type;

  const ExerciseTypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.limeGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
