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
  final ScrollController _scrollController = ScrollController();
  bool _isPopping = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Deep charcoal background
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          if (_isPopping) return false;

          if (!_scrollController.hasClients) return false;

          final pixels = _scrollController.position.pixels;
          final maxScroll = _scrollController.position.maxScrollExtent;

          // Track overscroll at the top (pull down to dismiss)
          if (pixels <= 0 && notification.metrics.pixels < -150) {
            _isPopping = true;
            Navigator.of(context).pop();
            return true;
          }

          // Track overscroll at the bottom (pull up to dismiss)
          if (pixels >= maxScroll &&
              notification.metrics.pixels > maxScroll + 150) {
            _isPopping = true;
            Navigator.of(context).pop();
            return true;
          }

          return false;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
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
