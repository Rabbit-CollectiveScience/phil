import 'dart:math';
import 'package:flutter/material.dart';
import '../../l2_card_model/card_model.dart';

class SwipeableCard extends StatefulWidget {
  final CardModel card;
  final VoidCallback onSwipedAway;
  final ValueChanged<CardModel> onCardUpdate;

  const SwipeableCard({
    super.key,
    required this.card,
    required this.onSwipedAway,
    required this.onCardUpdate,
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
  late FocusNode _weightFocusNode;
  late FocusNode _repsFocusNode;
  late final Widget _frontCard;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _weightController = TextEditingController(text: '${widget.card.weight} kg');
    _repsController = TextEditingController(text: '${widget.card.reps} reps');
    _weightFocusNode = FocusNode();
    _repsFocusNode = FocusNode();

    // Add listeners to rebuild when focus changes (to show/hide buttons)
    _weightFocusNode.addListener(() {
      setState(() {}); // Rebuild to show/hide buttons
    });
    _repsFocusNode.addListener(() {
      setState(() {}); // Rebuild to show/hide buttons
    });

    // Only cache front card - back has dynamic focus UI
    _frontCard = _buildFrontCard();

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Animation finished - update card state and clear flipping flag
        widget.onCardUpdate(widget.card.copyWith(isFlipped: true));
        setState(() {
          _isFlipping = false;
        });
      } else if (status == AnimationStatus.dismissed) {
        // Animation reversed - update card state and clear flipping flag
        widget.onCardUpdate(widget.card.copyWith(isFlipped: false));
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
    _weightFocusNode.dispose();
    _repsFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SwipeableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controllers when card data changes
    if (oldWidget.card.weight != widget.card.weight) {
      _weightController.text = '${widget.card.weight} kg';
    }
    if (oldWidget.card.reps != widget.card.reps) {
      _repsController.text = '${widget.card.reps} reps';
    }

    // Sync animation state with card flip state
    if (oldWidget.card.isFlipped != widget.card.isFlipped) {
      if (widget.card.isFlipped && _flipController.value == 0.0) {
        _flipController.value = 1.0;
      } else if (!widget.card.isFlipped && _flipController.value == 1.0) {
        _flipController.value = 0.0;
      }
    }
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
    // Don't update card state here - wait for animation to complete
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
        child: isFrontVisible ? _frontCard : _buildBackCard(),
      ),
    );
  }

  Widget _buildFrontCard() {
    return Padding(
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Let's do it!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Padding(
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
              TextField(
                controller: _weightController,
                focusNode: _weightFocusNode,
                readOnly: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: 'Weight',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: '0 kg',
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
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  prefixIcon: Opacity(
                    opacity: _weightFocusNode.hasFocus ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !_weightFocusNode.hasFocus,
                      child: IconButton(
                        onPressed: () {
                          String text = _weightController.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          int current = int.tryParse(text) ?? 0;
                          if (current > 2) {
                            int newValue = current - 2;
                            _weightController.text = '$newValue kg';
                            widget.onCardUpdate(
                              widget.card.copyWith(
                                weight: newValue.toString(),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.chevron_left),
                        color: Colors.white,
                        iconSize: 28,
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    ),
                  ),
                  suffixIcon: Opacity(
                    opacity: _weightFocusNode.hasFocus ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !_weightFocusNode.hasFocus,
                      child: IconButton(
                        onPressed: () {
                          String text = _weightController.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          int current = int.tryParse(text) ?? 0;
                          int newValue = current + 2;
                          _weightController.text = '$newValue kg';
                          widget.onCardUpdate(
                            widget.card.copyWith(weight: newValue.toString()),
                          );
                        },
                        icon: const Icon(Icons.chevron_right),
                        color: Colors.white,
                        iconSize: 28,
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _repsController,
                focusNode: _repsFocusNode,
                readOnly: true,
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
                  hintText: '0 reps',
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
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  prefixIcon: Opacity(
                    opacity: _repsFocusNode.hasFocus ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !_repsFocusNode.hasFocus,
                      child: IconButton(
                        onPressed: () {
                          String text = _repsController.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          int current = int.tryParse(text) ?? 0;
                          if (current > 1) {
                            int newValue = current - 1;
                            _repsController.text = '$newValue reps';
                            widget.onCardUpdate(
                              widget.card.copyWith(reps: newValue.toString()),
                            );
                          }
                        },
                        icon: const Icon(Icons.chevron_left),
                        color: Colors.white,
                        iconSize: 28,
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    ),
                  ),
                  suffixIcon: Opacity(
                    opacity: _repsFocusNode.hasFocus ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !_repsFocusNode.hasFocus,
                      child: IconButton(
                        onPressed: () {
                          String text = _repsController.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          int current = int.tryParse(text) ?? 0;
                          int newValue = current + 1;
                          _repsController.text = '$newValue reps';
                          widget.onCardUpdate(
                            widget.card.copyWith(reps: newValue.toString()),
                          );
                        },
                        icon: const Icon(Icons.chevron_right),
                        color: Colors.white,
                        iconSize: 28,
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    ),
                  ),
                ),
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedContainer(
        duration: _isDragging
            ? Duration.zero
            : const Duration(milliseconds: 300),
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
    );
  }
}
