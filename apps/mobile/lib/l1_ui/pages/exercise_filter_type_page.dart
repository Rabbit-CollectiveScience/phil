import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../view_models/exercise_filter_type_option.dart';
import '../widgets/exercise_filter_type_grid_tile.dart';

/// Full-screen page for selecting exercise filter type
class ExerciseFilterTypePage extends StatefulWidget {
  final String selectedFilterId;

  const ExerciseFilterTypePage({super.key, required this.selectedFilterId});

  @override
  State<ExerciseFilterTypePage> createState() => _ExerciseFilterTypePageState();
}

class _ExerciseFilterTypePageState extends State<ExerciseFilterTypePage> {
  double _dragOffset = 0.0;

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Only allow upward drag (negative values)
      _dragOffset += details.delta.dy;
      if (_dragOffset > 0) _dragOffset = 0; // Prevent downward drag
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    // If dragged up more than 100 pixels, dismiss
    if (_dragOffset < -100) {
      Navigator.of(context).pop();
    } else {
      // Reset position
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _handleVerticalDragUpdate,
      onVerticalDragEnd: _handleVerticalDragEnd,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A), // Deep charcoal background
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _dragOffset, 0),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Filter Exercises',
                    style: TextStyle(
                      color: Color(0xFFF2F2F2),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: ExerciseFilterTypeOption.allOptions.length,
                      itemBuilder: (context, index) {
                        final option =
                            ExerciseFilterTypeOption.allOptions[index];
                        final isSelected = option.id == widget.selectedFilterId;

                        return ExerciseFilterTypeGridTile(
                          option: option,
                          isSelected: isSelected,
                          onTap: () async {
                            // Haptic feedback
                            if (await Vibration.hasVibrator() ?? false) {
                              Vibration.vibrate(duration: 50);
                            }

                            // Return selected filter ID
                            if (context.mounted) {
                              Navigator.of(context).pop(option.id);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
