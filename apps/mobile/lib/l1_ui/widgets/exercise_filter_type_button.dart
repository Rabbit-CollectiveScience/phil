import 'package:flutter/material.dart';
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
          color: const Color(0xFFB9E479), // Lime green accent color
          borderRadius: BorderRadius.zero, // Sharp corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          selectedOption.icon,
          color: Colors.black, // Almost black icon
          size: size * 0.55,
        ),
      ),
    );
  }
}
