import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../l2_domain/card_model.dart';

class SwipeableCard extends StatefulWidget {
  final CardModel card;
  final VoidCallback onSwipedAway;
  final void Function(Offset buttonPosition) onCompleted;
  final ValueChanged<CardModel> onCardUpdate;
  final void Function(Offset position, bool isDragging)? onTokenDrag;

  const SwipeableCard({
    super.key,
    required this.card,
    required this.onSwipedAway,
    required this.onCompleted,
    required this.onCardUpdate,
    this.onTokenDrag,
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
  bool _isCompleting = false;
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late FocusNode _weightFocusNode;
  late FocusNode _repsFocusNode;
  late final Widget _frontCard;
  late final Widget _backCard;
  Timer? _weightTimer;
  Timer? _repsTimer;
  final GlobalKey _zetButtonKey = GlobalKey();
  bool _isDraggingToken = false;
  Offset? _dragStartGlobal;

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

    // Add listeners to start auto-hide timer when focused
    _weightFocusNode.addListener(() {
      if (_weightFocusNode.hasFocus) {
        _startWeightTimer();
      } else {
        _weightTimer?.cancel();
      }
    });
    _repsFocusNode.addListener(() {
      if (_repsFocusNode.hasFocus) {
        _startRepsTimer();
      } else {
        _repsTimer?.cancel();
      }
    });

    // Cache both front and back cards - ListenableBuilder handles focus reactivity
    _frontCard = _buildFrontCard();
    _backCard = _buildBackCard();

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
    _weightTimer?.cancel();
    _repsTimer?.cancel();
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

  void _startWeightTimer() {
    _weightTimer?.cancel();
    _weightTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _weightFocusNode.hasFocus) {
        _weightFocusNode.unfocus();
      }
    });
  }

  void _startRepsTimer() {
    _repsTimer?.cancel();
    _repsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _repsFocusNode.hasFocus) {
        _repsFocusNode.unfocus();
      }
    });
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
    // Check if drag started in bottom 25% of card when flipped
    if (widget.card.isFlipped) {
      final RenderBox? cardBox = context.findRenderObject() as RenderBox?;
      if (cardBox != null) {
        final Offset localPosition = cardBox.globalToLocal(details.globalPosition);
        final double cardHeight = cardBox.size.height;
        final double bottomThreshold = cardHeight * 0.75; // Bottom 25% starts at 75%
        
        if (localPosition.dy >= bottomThreshold) {
          // Started drag in bottom 25% - token drag mode
          setState(() {
            _isDraggingToken = true;
            _dragStartGlobal = details.globalPosition;
          });
          widget.onTokenDrag?.call(details.globalPosition, true);
          return;
        }
      }
    }

    // Normal card drag
    setState(() {
      _isDragging = true;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isDraggingToken) {
      // Update token position
      widget.onTokenDrag?.call(details.globalPosition, true);
    } else {
      // Normal card drag
      setState(() {
        _dragOffset += details.delta;
        _dragRotation = _dragOffset.dx / 1000;
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isDraggingToken) {
      // End token drag
      setState(() {
        _isDraggingToken = false;
        _dragStartGlobal = null;
      });
      widget.onTokenDrag?.call(details.globalPosition, false);
      return;
    }

    // Normal card drag end
    final velocity = details.velocity.pixelsPerSecond;
    final screenWidth = MediaQuery.of(context).size.width;

    // Check for horizontal swipe (swipe away)
    if (_dragOffset.dx.abs() > screenWidth * 0.3 || velocity.dx.abs() > 500) {
      _animateCardAwayWithMomentum(velocity);
    }
    // Bounce back
    else {
      setState(() {
        _dragOffset = Offset.zero;
        _dragRotation = 0.0;
        _isDragging = false;
      });
    }
  }

  void _animateCardAwayWithMomentum(Offset velocity) {
    final screenWidth = MediaQuery.of(context).size.width;
    final direction = _dragOffset.dx > 0 ? 1 : -1;

    // Calculate momentum-based exit with velocity continuation
    final momentumY = _dragOffset.dy + (velocity.dy * 0.3);
    final exitDistance = screenWidth * 1.5 * direction;

    setState(() {
      _dragOffset = Offset(exitDistance, momentumY);
      _dragRotation = (exitDistance / 1000).clamp(-0.5, 0.5);
      _isDragging = false;
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
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: isFrontVisible ? _frontCard : _backCard,
      ),
    );
  }

  Widget _buildFrontCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.card.exerciseName.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: _handleTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB9E479), // Lime green accent
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: const Text(
              "START",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 5),
          Column(
            children: [
              Text(
                widget.card.exerciseName.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _weightController,
                focusNode: _weightFocusNode,
                readOnly: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  prefixIcon: ListenableBuilder(
                    listenable: _weightFocusNode,
                    builder: (context, child) => Opacity(
                      opacity: _weightFocusNode.hasFocus ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !_weightFocusNode.hasFocus,
                        child: child!,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _startWeightTimer(); // Reset timer on interaction
                        String text = _weightController.text.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        int current = int.tryParse(text) ?? 0;
                        if (current > 2) {
                          int newValue = current - 2;
                          _weightController.text = '$newValue kg';
                          widget.onCardUpdate(
                            widget.card.copyWith(weight: newValue.toString()),
                          );
                        }
                      },
                      icon: const Icon(Icons.chevron_left),
                      color: const Color(0xFFB9E479), // Lime green accent
                      iconSize: 28,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ),
                  suffixIcon: ListenableBuilder(
                    listenable: _weightFocusNode,
                    builder: (context, child) => Opacity(
                      opacity: _weightFocusNode.hasFocus ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !_weightFocusNode.hasFocus,
                        child: child!,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _startWeightTimer(); // Reset timer on interaction
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
                      color: const Color(0xFFB9E479), // Lime green accent
                      iconSize: 28,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(4),
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
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  prefixIcon: ListenableBuilder(
                    listenable: _repsFocusNode,
                    builder: (context, child) => Opacity(
                      opacity: _repsFocusNode.hasFocus ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !_repsFocusNode.hasFocus,
                        child: child!,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _startRepsTimer(); // Reset timer on interaction
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
                      color: const Color(0xFFB9E479), // Lime green accent
                      iconSize: 28,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ),
                  suffixIcon: ListenableBuilder(
                    listenable: _repsFocusNode,
                    builder: (context, child) => Opacity(
                      opacity: _repsFocusNode.hasFocus ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !_repsFocusNode.hasFocus,
                        child: child!,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _startRepsTimer(); // Reset timer on interaction
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
                      color: const Color(0xFFB9E479), // Lime green accent
                      iconSize: 28,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            key: _zetButtonKey,
            width: double.infinity,
            child: Builder(
              builder: (buttonContext) {
                return ElevatedButton(
                  onPressed: () {
                    // Get button position in global coordinates using button's own context
                    final RenderBox? box =
                        buttonContext.findRenderObject() as RenderBox?;
                    if (box != null) {
                      final Offset position = box.localToGlobal(Offset.zero);
                      final Offset buttonCenter = Offset(
                        position.dx + box.size.width / 2,
                        position.dy + box.size.height / 2,
                      );
                      widget.onCompleted(buttonCenter);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFB9E479,
                    ), // Lime green accent
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: const Text(
                    'ZET',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                );
              },
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
          ..rotateZ(_dragRotation)
          ..scale(_isCompleting ? 0.6 : 1.0),
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
