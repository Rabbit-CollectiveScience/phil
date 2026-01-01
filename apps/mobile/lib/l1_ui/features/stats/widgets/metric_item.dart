import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class MetricItem extends StatelessWidget {
  final String value;
  final String label;
  final bool hasData;

  const MetricItem({
    super.key,
    required this.value,
    required this.label,
    required this.hasData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: hasData
                ? AppColors.darkText
                : AppColors.darkText.withOpacity(0.3),
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: hasData
                ? AppColors.darkText.withOpacity(0.5)
                : AppColors.darkText.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
