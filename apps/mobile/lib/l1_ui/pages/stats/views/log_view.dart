import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class LogView extends StatelessWidget {
  const LogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'LOG coming soon',
        style: TextStyle(
          fontSize: 16,
          color: AppColors.offWhite.withOpacity(0.5),
        ),
      ),
    );
  }
}
