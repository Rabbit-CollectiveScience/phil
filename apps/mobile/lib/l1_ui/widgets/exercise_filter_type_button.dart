import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../view_models/exercise_filter_type_option.dart';

/// Filter button shown at top-center of home page
/// Displays icon of currently selected filter type
class ExerciseFilterTypeButton extends StatelessWidget {
  final String selectedFilterId;
  final VoidCallback onTap;
  final double size;

  const ExerciseFilterTypeButton({
    super.key,
    required this.selectedFilterId,
    required this.onTap,
    this.size = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    final selectedOption = ExerciseFilterTypeOption.getById(selectedFilterId);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.limeGreen,
          borderRadius: BorderRadius.zero, // Sharp corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset(
          selectedOption.imagePath,
          width: size * 0.55,
          height: size * 0.55,
          color: AppColors.pureBlack,
          errorBuilder: (context, error, stackTrace) {
            // Fallback icon if image not found
            return Icon(
              Icons.fitness_center,
              color: AppColors.pureBlack,
              size: size * 0.25,
            );
          },
        ),
      ),
    );
  }
}
