import 'dart:math';
import 'package:flutter/material.dart';
import '../../l2_card_model/card_model.dart';

class SwipeableCard extends StatefulWidget {
  final CardModel card;
  final VoidCallback onSwipedAway;

  const SwipeableCard({
    super.key,
    required this.card,
    required this.onSwipedAway,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0.0;
  bool _isDragging = false;
  bool _isFlipping = false;
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize with default values if empty
    if (widget.card.weight.isEmpty) {
      widget.card.weight = '10';
    }
    if (widget.card.reps.isEmpty) {
      widget.card.reps = '10';
    }
    
    _weightController = TextEditingController(text: widget.card.weight);
    _repsController = TextEditingController(text: widget.card.reps);

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        setState(() {
          _isFlipping = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isFlipping = true;
    });

    if (widget.card.isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    widget.card.isFlipped = !widget.card.isFlipped;
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _dragRotation = _dragOffset.dx / 1000;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final screenWidth = MediaQuery.of(context).size.width;

    if (_dragOffset.dx.abs() > screenWidth * 0.3 || velocity.dx.abs() > 500) {
      _animateCardAway();
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _dragRotation = 0.0;
        _isDragging = false;
      });
    }
  }

  void _animateCardAway() {
    final screenWidth = MediaQuery.of(context).size.width;
    final direction = _dragOffset.dx > 0 ? 1 : -1;

    setState(() {
      _dragOffset = Offset(screenWidth * 1.5 * direction, _dragOffset.dy);
      _dragRotation = 0.5 * direction;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onSwipedAway();
    });
  }

  Widget _buildCardContent(bool isFrontVisible) {
    // Pre-build both sides to avoid lag on first flip
    final frontCard = Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.card.exerciseName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _handleTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: widget.card.color,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Let's do it!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    final backCard = Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 10),
          Column(
            children: [
              Text(
                widget.card.exerciseName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      onChanged: (value) {
                        widget.card.weight = value;
                      },
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: '0',
                        hintStyle: const TextStyle(color: Colors.white30),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.white70,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          int current = int.tryParse(_weightController.text) ?? 0;
                          _weightController.text = (current + 2).toString();
                          widget.card.weight = _weightController.text;
                        },
                        icon: const Icon(Icons.arrow_upward),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white24,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          int current = int.tryParse(_weightController.text) ?? 0;
                          if (current > 0) {
                            _weightController.text = (current - 2).toString();
                            widget.card.weight = _weightController.text;
                          }
                        },
                        icon: const Icon(Icons.arrow_downward),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white24,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _repsController,
                      onChanged: (value) {
                        widget.card.reps = value;
                      },
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Reps',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: '0',
                        hintStyle: const TextStyle(color: Colors.white30),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.white70,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          int current = int.tryParse(_repsController.text) ?? 0;
                          _repsController.text = (current + 1).toString();
                          widget.card.reps = _repsController.text;
                        },
                        icon: const Icon(Icons.arrow_upward),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white24,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          int current = int.tryParse(_repsController.text) ?? 0;
                          if (current > 0) {
                            _repsController.text = (current - 1).toString();
                            widget.card.reps = _repsController.text;
                          }
                        },
                        icon: const Icon(Icons.arrow_downward),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white24,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: widget.card.color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Zet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return RepaintBoundary(
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: widget.card.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: isFrontVisible ? frontCard : backCard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Always keep both sides rendered for smooth animation
    return Stack(
      children: [
        // Always keep both sides pre-rendered
        Offstage(
          offstage: true,
          child: _buildCardContent(false),
        ),
        Offstage(
          offstage: true,
          child: _buildCardContent(true),
        ),
        // Visible card with animation
        GestureDetector(
          onTap: _handleTap,
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: AnimatedContainer(
            duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            transform: Matrix4.identity()
              ..translate(_dragOffset.dx, _dragOffset.dy)
              ..rotateZ(_dragRotation),
            child: _isFlipping
                ? AnimatedBuilder(
                    animation: _flipController,
                    builder: (context, child) {
                      final angle = _flipController.value * pi;
                      final isFrontVisible = angle < pi / 2;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(isFrontVisible ? 0 : pi),
                          child: _buildCardContent(isFrontVisible),
                        ),
                      );
                    },
                  )
                : _buildCardContent(!widget.card.isFlipped),
          ),
        ),
      ],
    );
  }
}
