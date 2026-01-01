import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class CompletionCounter extends StatelessWidget {
  final int count;
  final double size;
  final VoidCallback onTap;
  final VoidCallback? onSwipeUp;

  const CompletionCounter({
    super.key,
    required this.count,
    required this.size,
    required this.onTap,
    this.onSwipeUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onVerticalDragUpdate: (details) {
        // Detect upward swipe (negative delta)
        if (details.primaryDelta != null && details.primaryDelta! < -5) {
          onSwipeUp?.call();
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.limeGreen,
        ),
        child: Center(
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: AppColors.deepCharcoal,
              fontSize: 24,
              fontWeight: FontWeight.w900, // Ultra bold
            ),
          ),
        ),
      ),
    );
  }
}
