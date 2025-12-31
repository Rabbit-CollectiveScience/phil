import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Small metric tile for stats overview
/// Shows a big number with a label below
class MetricTile extends StatelessWidget {
  final String value;
  final String label;

  const MetricTile({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.darkText,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText.withOpacity(0.5),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
