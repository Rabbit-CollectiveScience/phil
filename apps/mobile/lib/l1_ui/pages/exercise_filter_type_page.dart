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

class _ExerciseFilterTypePageState extends State<ExerciseFilterTypePage>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Only allow upward drag (negative values)
      _dragOffset += details.delta.dy;

      // Prevent downward drag completely
      if (_dragOffset > 0) {
        _dragOffset = 0;
      }
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    // If dragged up more than 150 pixels, dismiss (matching completed page)
    if (_dragOffset < -150) {
      Navigator.of(context).pop();
    } else {
      // Bounce back to original position with elastic animation
      _bounceAnimation = Tween<double>(begin: _dragOffset, end: 0.0).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
      );

      _bounceController.forward(from: 0.0).then((_) {
        setState(() {
          _dragOffset = 0.0;
        });
      });

      // Update position during animation
      _bounceController.addListener(() {
        setState(() {
          _dragOffset = _bounceAnimation.value;
        });
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
        body: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Training Focus',
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
