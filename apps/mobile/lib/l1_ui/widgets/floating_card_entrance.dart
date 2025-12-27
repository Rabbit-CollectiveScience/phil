import 'package:flutter/material.dart';

class FloatingCardEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final bool shouldAnimate;

  const FloatingCardEntrance({
    super.key,
    required this.child,
    required this.index,
    this.shouldAnimate = true,
  });

  @override
  State<FloatingCardEntrance> createState() => _FloatingCardEntranceState();
}

class _FloatingCardEntranceState extends State<FloatingCardEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initStackGrowthAnimation();
  }

  void _initStackGrowthAnimation() {
    _controller = AnimationController(
      duration: Duration.zero,
      vsync: this,
    );

    // Base delay of 0.5 second before starting any cards
    final baseDelay = 500;
    // Cards appear sequentially: index 0 at 500ms, index 1 at 620ms, index 2 at 740ms
    final delay = baseDelay + (widget.index * 120);

    if (widget.shouldAnimate) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          _controller.value = 1.0;
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.shouldAnimate) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Just pop into existence when controller reaches 1.0
        return _controller.value == 1.0
            ? widget.child
            : const SizedBox.shrink();
      },
    );
  }
}
