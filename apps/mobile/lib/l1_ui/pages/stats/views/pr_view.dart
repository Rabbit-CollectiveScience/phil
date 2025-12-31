import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class PRView extends StatelessWidget {
  const PRView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'PR View - Coming Soon',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.offWhite.withOpacity(0.5),
        ),
      ),
    );
  }
}
