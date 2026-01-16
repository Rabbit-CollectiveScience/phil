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
    final panelHeight = (MediaQuery.of(context).size.height * 0.4).clamp(
      300.0,
      400.0,
    );

    return Container(
      width: double.infinity,
      height: panelHeight,
      decoration: BoxDecoration(color: AppColors.darkGrey),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left: Number pad (3 columns)
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(child: _buildNumberRow(['1', '2', '3'])),
                  Expanded(child: _buildNumberRow(['4', '5', '6'])),
                  Expanded(child: _buildNumberRow(['7', '8', '9'])),
                  Expanded(child: _buildNumberRow(['.', '0', '⌫'])),
                ],
              ),
            ),

            Container(
              width: 1.5,
              color: AppColors.limeGreen.withOpacity(0.3),
            ),

            // Right: Action buttons (1 column)
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(child: _buildActionButton('100%')),
                  Container(
                    height: 1.5,
                    color: AppColors.limeGreen.withOpacity(0.3),
                  ),
                  Expanded(child: _buildActionButton('90%')),
                  Container(
                    height: 1.5,
                    color: AppColors.limeGreen.withOpacity(0.3),
                  ),
                  Expanded(child: _buildActionButton('80%')),
                  Container(
                    height: 1.5,
                    color: AppColors.limeGreen.withOpacity(0.3),
                  ),
                  Expanded(child: _buildActionButton('50%')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      children: numbers.map((number) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: _buildButton(
              number,
              onTap: () {
                HapticFeedback.lightImpact();
                // TODO: Handle number input
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(String label) {
    // Mock PR values - will be dynamic later
    String subtitle = '';
    double opacity = 0.4; // Default

    if (label == '100%') {
      subtitle = '100 kg';
      opacity = 1.0;
    } else if (label == '90%') {
      subtitle = '90 kg';
      opacity = 0.8;
    } else if (label == '80%') {
      subtitle = '80 kg';
      opacity = 0.6;
    } else if (label == '50%') {
      subtitle = '50 kg';
      opacity = 0.4;
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: AppColors.darkGrey,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            // TODO: Handle action
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.limeGreen.withOpacity(opacity),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.offWhite.withOpacity(opacity * 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    String label, {
    required VoidCallback onTap,
    bool isAction = false,
  }) {
    return Material(
      color: isAction
          ? AppColors.limeGreen.withOpacity(0.2)
          : AppColors.darkGrey,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isAction ? AppColors.limeGreen : AppColors.offWhite,
              fontSize: isAction ? 14 : 24,
              fontWeight: isAction ? FontWeight.w600 : FontWeight.w300,
              letterSpacing: isAction ? 1.2 : 0,
            ),
          ),
        ),
      ),
    );
  }
}
