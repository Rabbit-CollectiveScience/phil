import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/app_colors.dart';

/// Custom input panel for entering workout values
/// Provides a number pad and quick action buttons for efficient data entry
class WorkoutInputPanel extends StatelessWidget {
  final String fieldName;
  final String unit;

  const WorkoutInputPanel({
    super.key,
    required this.fieldName,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final panelHeight = (MediaQuery.of(context).size.height * 0.4).clamp(300.0, 400.0);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        height: panelHeight,
        decoration: BoxDecoration(
          color: AppColors.boldGrey,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Custom Input Panel',
              style: TextStyle(
                color: AppColors.offWhite,
                fontSize: 24,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Field: $fieldName',
              style: TextStyle(
                color: AppColors.offWhite.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unit: $unit',
              style: TextStyle(
                color: AppColors.offWhite.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Tap anywhere to close',
              style: TextStyle(
                color: AppColors.limeGreen,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
