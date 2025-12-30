import 'package:flutter/material.dart';
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
          color: isSelected
              ? const Color(0xFFB9E479) // Lime green for selected
              : const Color(0xFF4A4A4A), // Bold grey for unselected
          borderRadius: BorderRadius.zero, // Sharp corners
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFB9E479).withOpacity(0.3),
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
                color: isSelected ? Colors.black : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
