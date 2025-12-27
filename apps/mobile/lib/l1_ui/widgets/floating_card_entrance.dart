import 'dart:math';
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
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();

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
      _controller.forward();
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
}
