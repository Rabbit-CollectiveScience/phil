import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DashboardIconButton extends StatelessWidget {
  final double size;
  final VoidCallback onTap;

  const DashboardIconButton({
    super.key,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
        ),
        child: const Icon(
          Icons.bar_chart_rounded,
          color: Colors.white70,
          size: 24,
        ),
      ),
    );
  }
}
