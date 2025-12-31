import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class TrendView extends StatelessWidget {
  const TrendView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Trend View - Coming Soon',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.offWhite.withOpacity(0.5),
        ),
      ),
    );
  }
}
