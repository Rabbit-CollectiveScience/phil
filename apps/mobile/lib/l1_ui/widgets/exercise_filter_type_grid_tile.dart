import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../view_models/exercise_filter_type_option.dart';

/// Grid tile for exercise filter type selection
/// Displays icon, label, and selected state
class ExerciseFilterTypeGridTile extends StatelessWidget {
  final ExerciseFilterTypeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const ExerciseFilterTypeGridTile({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.limeGreen : AppColors.boldGrey,
          borderRadius: BorderRadius.zero, // Sharp corners
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.limeGreenGlow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option.icon,
              color: isSelected ? Colors.black : Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              option.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.pureBlack : AppColors.offWhite,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
