import 'dart:math';
import 'package:flutter/material.dart';

enum CardEntranceType {
  flip,
  stackGrowth,
}

class FloatingCardEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final bool shouldAnimate;
  final CardEntranceType animationType;

  const FloatingCardEntrance({
    super.key,
    required this.child,
    required this.index,
    this.shouldAnimate = true,
    this.animationType = CardEntranceType.stackGrowth, // Change this to switch animations
  });

  @override
  State<FloatingCardEntrance> createState() => _FloatingCardEntranceState();
}

class _FloatingCardEntranceState extends State<FloatingCardEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.animationType == CardEntranceType.flip) {
      _initFlipAnimation();
    } else {
      _initStackGrowthAnimation();
    }
  }

  void _initFlipAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Flip from -180° (back) to 0° (front) - opposite direction
    _flipAnimation = Tween<double>(
      begin: -pi, // -180 degrees (back facing, flipped other way)
      end: 0.0, // 0 degrees (front facing)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.shouldAnimate) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.value = 1.0;
    }
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

    if (widget.animationType == CardEntranceType.flip) {
      return _buildFlipAnimation();
    } else {
      return _buildStackGrowthAnimation();
    }
  }

  Widget _buildFlipAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _flipAnimation.value;
        final isFrontVisible = angle.abs() < pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Add perspective
            ..rotateY(angle),
          child: isFrontVisible
              ? widget.child
              : Container(
                  width: 330,
                  height: 420,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A), // Background color
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildStackGrowthAnimation() {
    // First card appears immediately without animation
    if (widget.index == 0) {
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
