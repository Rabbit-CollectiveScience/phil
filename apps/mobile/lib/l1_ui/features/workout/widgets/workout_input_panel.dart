import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../../l2_domain/models/exercises/exercise.dart';
import '../../../../l2_domain/models/exercises/strength_exercise.dart';
import '../../../../l2_domain/use_cases/personal_records/calculate_pr_percentages_use_case.dart';

/// Custom input panel for entering workout values
/// Provides a number pad and quick action buttons for efficient data entry
class WorkoutInputPanel extends StatefulWidget {
  final Exercise exercise;
  final CalculatePRPercentagesUseCase calculatePRUseCase;
  final String fieldName;
  final String unit;
  final void Function(double weight, bool shouldClose) onWeightSelected;

  const WorkoutInputPanel({
    super.key,
    required this.exercise,
    required this.calculatePRUseCase,
    required this.fieldName,
    required this.unit,
    required this.onWeightSelected,
  });

  @override
  State<WorkoutInputPanel> createState() => _WorkoutInputPanelState();
}

class _WorkoutInputPanelState extends State<WorkoutInputPanel> {
  PRPercentages? _prPercentages;
  bool _isLoading = false;
  String _currentInput = '';

  @override
  void initState() {
    super.initState();
    _loadPRData();
  }

  void _handleNumberInput(String number) {
    setState(() {
      if (number == '⌫') {
        // Backspace
        if (_currentInput.isNotEmpty) {
          _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        }
      } else if (number == '.') {
        // Only allow one decimal point
        if (!_currentInput.contains('.')) {
          _currentInput += number;
        }
      } else {
        // Append digit
        _currentInput += number;
      }
    });

    // Update parent field in real-time (without closing panel)
    final parsedValue = double.tryParse(_currentInput);
    if (parsedValue != null && parsedValue > 0) {
      widget.onWeightSelected(parsedValue, false);
    }
  }

  Future<void> _loadPRData() async {
    if (widget.exercise is! StrengthExercise) {
      // Only strength exercises have PR percentages
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await widget.calculatePRUseCase.execute(widget.exercise);
      if (mounted) {
        setState(() {
          _prPercentages = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
                _handleNumberInput(number);
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(String label) {
    String subtitle = '';
    double opacity = 0.4;
    double? weightValue;

    if (_isLoading) {
      subtitle = '...';
      opacity = 0.3;
    } else if (_prPercentages != null) {
      // Use real PR data
      final unit = _prPercentages!.isMetric ? 'kg' : 'lbs';

      if (label == '100%') {
        weightValue = _prPercentages!.percent100;
        subtitle =
            '${weightValue.toStringAsFixed(weightValue % 1 == 0 ? 0 : 1)} $unit';
        opacity = 1.0;
      } else if (label == '90%') {
        weightValue = _prPercentages!.percent90;
        subtitle =
            '${weightValue.toStringAsFixed(weightValue % 1 == 0 ? 0 : 1)} $unit';
        opacity = 0.8;
      } else if (label == '80%') {
        weightValue = _prPercentages!.percent80;
        subtitle =
            '${weightValue.toStringAsFixed(weightValue % 1 == 0 ? 0 : 1)} $unit';
        opacity = 0.6;
      } else if (label == '50%') {
        weightValue = _prPercentages!.percent50;
        subtitle =
            '${weightValue.toStringAsFixed(weightValue % 1 == 0 ? 0 : 1)} $unit';
        opacity = 0.4;
      }
    } else {
      // No PR available
      subtitle = 'No PR';
      opacity = 0.2;
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: AppColors.darkGrey,
        child: InkWell(
          onTap: weightValue != null
              ? () {
                  HapticFeedback.lightImpact();
                  widget.onWeightSelected(weightValue!, true);
                }
              : null,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Weight value on top (primary info)
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.offWhite.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                // Percentage label below (context)
                const SizedBox(height: 2),
                Text(
                  '$label PR',
                  style: TextStyle(
                    color: AppColors.limeGreen.withOpacity(opacity),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
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
