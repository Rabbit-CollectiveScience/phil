import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../shared/theme/app_colors.dart';
import '../view_models/card_model.dart';
import '../../../../l2_domain/legacy_models/field_type_enum.dart';

/// Card interaction states for gesture handling
enum CardInteractionState {
  idle, // Front side, no interaction
  idleFlipped, // Back side, no interaction
  flipping, // Flip animation in progress
  draggingCard, // Swiping card left/right
  draggingToken, // Dragging token from bottom 25%
  animatingToken, // Token flying to counter
}

/// Extension methods for state validation
extension CardInteractionStateValidation on CardInteractionState {
  bool get allowsTap => this == CardInteractionState.idle;
  bool get allowsPanStart =>
      this == CardInteractionState.idle ||
      this == CardInteractionState.idleFlipped;
  bool get isStable =>
      this == CardInteractionState.idle ||
      this == CardInteractionState.idleFlipped;
  bool get isAnimating =>
      this == CardInteractionState.flipping ||
      this == CardInteractionState.animatingToken;
}

class SwipeableCard extends StatefulWidget {
  final CardModel card;
  final VoidCallback onSwipedAway;
  final VoidCallback? onStartSwipeAway;
  final void Function(Offset buttonPosition, VoidCallback onAnimationComplete)
  onCompleted;
  final ValueChanged<CardModel> onCardUpdate;
  final void Function(Offset position, bool isDragging)? onTokenDrag;
  final VoidCallback? onInteractionStart;
  final int zetCount;

  const SwipeableCard({
    super.key,
    required this.card,
    required this.onSwipedAway,
    this.onStartSwipeAway,
    required this.onCompleted,
    required this.onCardUpdate,
    this.onTokenDrag,
    this.onInteractionStart,
    required this.zetCount,
  });

  @override
  State<SwipeableCard> createState() => SwipeableCardState();
}

class SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  // State Machine
  CardInteractionState _currentState = CardInteractionState.idle;

  late AnimationController _flipController;
  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0.0;
  bool _isDragging = false;
  bool _isFlipping = false;
  bool _isCompleting = false;
  bool _isDismissing = false;
  final Map<String, TextEditingController> _fieldControllers = {};
  final Map<String, FocusNode> _fieldFocusNodes = {};
  late final Widget _frontCard;
  final Map<String, Timer?> _fieldTimers = {};
  final GlobalKey _zetButtonKey = GlobalKey();
  bool _isDraggingToken = false;
  Offset? _dragStartGlobal;
  Offset? _lastTapPosition;
  Offset? _dragStartLocalPosition;
  bool _gestureCommitted = false;
  int _currentSetNumber = 1;

  // State transition with logging
  void _transitionState(CardInteractionState newState) {
    if (kDebugMode) {
      debugPrint(
        '[CardState] ${widget.card.exerciseName}: $_currentState → $newState',
      );
    }
    setState(() => _currentState = newState);
  }

  @override
  void initState() {
    super.initState();

    // Initialize state based on card's flip status
    _currentState = widget.card.isFlipped
        ? CardInteractionState.idleFlipped
        : CardInteractionState.idle;

    if (kDebugMode) {
      debugPrint(
        '[CardState] ${widget.card.exerciseName}: Initial state = $_currentState',
      );
    }

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Set initial flip controller value based on card state
    if (widget.card.isFlipped) {
      _flipController.value = 1.0;
    }

    if (kDebugMode) {
      debugPrint(
        '[CardState] ${widget.card.exerciseName}: FlipController initialized to ${_flipController.value}',
      );
    }

    // Initialize controllers and focus nodes for each field
    for (var field in widget.card.exercise.fields) {
      final value =
          widget.card.fieldValues[field.name] ??
          field.defaultValue?.toString() ??
          '';
      final displayValue = value.isEmpty || value == 'null'
          ? '- ${field.unit}'
          : '$value ${field.unit}';
      _fieldControllers[field.name] = TextEditingController(text: displayValue);
      _fieldFocusNodes[field.name] = FocusNode();

      // Add listener to start auto-hide timer when focused
      _fieldFocusNodes[field.name]!.addListener(() {
        if (_fieldFocusNodes[field.name]!.hasFocus) {
          _startFieldTimer(field.name);
        } else {
          _fieldTimers[field.name]?.cancel();
        }
      });
    }

    // Cache front card only - back card needs to rebuild for set number updates
    _frontCard = _buildFrontCard();

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Transition to stable state FIRST, before notifying parent
        // This ensures didUpdateWidget sees stable state when it runs
        _transitionState(CardInteractionState.idleFlipped);
        setState(() {
          _isFlipping = false;
        });
        // Now notify parent - this may trigger didUpdateWidget
        widget.onCardUpdate(widget.card.copyWith(isFlipped: true));
      } else if (status == AnimationStatus.dismissed) {
        // Transition to stable state FIRST, before notifying parent
        _transitionState(CardInteractionState.idle);
        setState(() {
          _isFlipping = false;
        });
        // Now notify parent - this may trigger didUpdateWidget
        widget.onCardUpdate(widget.card.copyWith(isFlipped: false));
      }
    });
  }

  /// Extract field values from controllers as Map<String, dynamic>
  /// Parses text, removes units, converts to proper types based on field.type
  Map<String, dynamic> getFieldValues() {
    final values = <String, dynamic>{};

    for (var field in widget.card.exercise.fields) {
      final controller = _fieldControllers[field.name];
      if (controller == null) continue;

      // Extract raw text and remove units
      String text = controller.text.replaceAll(field.unit, '').trim();

      // Handle placeholder "- unit" → skip this field
      if (text == '-' || text.isEmpty) {
        continue;
      }

      // Convert to proper type based on field type
      switch (field.type) {
        case FieldTypeEnum.number:
          // Try double first, fallback to int
          final doubleValue = double.tryParse(text);
          if (doubleValue != null) {
            // Store as int if no decimal part, otherwise double
            values[field.name] = doubleValue == doubleValue.toInt()
                ? doubleValue.toInt()
                : doubleValue;
          }
        case FieldTypeEnum.duration:
          // Duration stored as integer seconds
          final intValue = int.tryParse(text);
          if (intValue != null) {
            values[field.name] = intValue;
          }
        case FieldTypeEnum.text:
          // Store as string
          values[field.name] = text;
        case FieldTypeEnum.boolean:
          // Parse boolean
          values[field.name] = text.toLowerCase() == 'true' || text == '1';
      }
    }

    return values;
  }

  @override
  void dispose() {
    for (var timer in _fieldTimers.values) {
      timer?.cancel();
    }
    _flipController.dispose();
    for (var controller in _fieldControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _fieldFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(SwipeableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controllers when card field values change
    for (var field in widget.card.exercise.fields) {
      final oldValue = oldWidget.card.fieldValues[field.name];
      final newValue = widget.card.fieldValues[field.name];
      if (oldValue != newValue && _fieldControllers.containsKey(field.name)) {
        final displayValue =
            newValue == null || newValue.isEmpty || newValue == 'null'
            ? '- ${field.unit}'
            : '$newValue ${field.unit}';
        _fieldControllers[field.name]!.text = displayValue;
      }
    }

    // If card changed (different exercise), reset to stable state
    // This fixes the bug where cards get stuck in flipping state when swiped away mid-animation
    if (oldWidget.card.exerciseName != widget.card.exerciseName) {
      if (kDebugMode) {
        debugPrint(
          '[CardState] ${widget.card.exerciseName}: Card changed, forcing reset from $_currentState',
        );
      }

      // Cancel any ongoing animation
      if (_flipController.isAnimating) {
        _flipController.stop();
      }

      // Reset to stable state based on current flip value
      final shouldBeFlipped = _flipController.value > 0.5;
      _currentState = shouldBeFlipped
          ? CardInteractionState.idleFlipped
          : CardInteractionState.idle;
      _isFlipping = false;
      _isDragging = false;
      _isDraggingToken = false;

      if (kDebugMode) {
        debugPrint(
          '[CardState] ${widget.card.exerciseName}: Reset to $_currentState',
        );
      }
      return;
    }

    // Only sync flip state if we're in a stable state (not animating)
    // This prevents the bug where card snaps during animation
    if (_currentState.isStable &&
        oldWidget.card.isFlipped != widget.card.isFlipped) {
      if (kDebugMode) {
        debugPrint(
          '[CardState] ${widget.card.exerciseName}: didUpdateWidget syncing flip state: ${widget.card.isFlipped} (flipController.value=${_flipController.value})',
        );
      }

      if (widget.card.isFlipped && _flipController.value == 0.0) {
        _flipController.value = 1.0;
        _currentState = CardInteractionState.idleFlipped;
      } else if (!widget.card.isFlipped && _flipController.value == 1.0) {
        _flipController.value = 0.0;
        _currentState = CardInteractionState.idle;
      }
    } else if (!_currentState.isStable) {
      if (kDebugMode) {
        debugPrint(
          '[CardState] ${widget.card.exerciseName}: didUpdateWidget skipped - state is $_currentState (isAnimating=${_flipController.isAnimating})',
        );
      }
    }
  }

  void _startFieldTimer(String fieldName) {
    _fieldTimers[fieldName]?.cancel();
    _fieldTimers[fieldName] = Timer(const Duration(seconds: 2), () {
      if (mounted && (_fieldFocusNodes[fieldName]?.hasFocus ?? false)) {
        _fieldFocusNodes[fieldName]?.unfocus();
      }
    });
  }

  void _handleTap() {
    if (kDebugMode) {
      debugPrint(
        '[CardGesture] ${widget.card.exerciseName}: Tap detected, state: $_currentState, controller.value=${_flipController.value}, card.isFlipped=${widget.card.isFlipped}',
      );
    }

    // Notify parent that user is interacting (dismiss keyboard, etc.)
    widget.onInteractionStart?.call();

    // State machine guard: only allow tap in idle (front) or idleFlipped (back)
    if (!_currentState.allowsTap &&
        _currentState != CardInteractionState.idleFlipped) {
      if (kDebugMode) {
        debugPrint(
          '[CardGesture] ${widget.card.exerciseName}: Tap rejected - wrong state',
        );
      }
      return;
    }

    // If card is flipped, only allow tap in top 25% to flip back
    if (widget.card.isFlipped && _lastTapPosition != null) {
      final RenderBox? cardBox = context.findRenderObject() as RenderBox?;
      if (cardBox != null) {
        final double cardHeight = cardBox.size.height;
        final double topThreshold = cardHeight * 0.25; // Top 25%

        if (_lastTapPosition!.dy > topThreshold) {
          // Tap was below top 25% - ignore it
          if (kDebugMode) {
            debugPrint(
              '[CardGesture] ${widget.card.exerciseName}: Tap on flipped card outside top zone (y=${_lastTapPosition!.dy}, threshold=$topThreshold) - ignoring',
            );
          }
          return;
        }

        if (kDebugMode) {
          debugPrint(
            '[CardGesture] ${widget.card.exerciseName}: Tap on flipped card in top zone - flipping back to front',
          );
        }
      }
    }

    // Transition to flipping state
    _transitionState(CardInteractionState.flipping);

    setState(() {
      _isFlipping = true;
    });

    // Ensure animation is stopped before starting new one
    if (_flipController.isAnimating) {
      if (kDebugMode) {
        debugPrint(
          '[CardState] ${widget.card.exerciseName}: Stopping ongoing animation before starting flip',
        );
      }
      _flipController.stop();
    }

    if (widget.card.isFlipped) {
      if (kDebugMode) {
        debugPrint(
          '[CardState] ${widget.card.exerciseName}: Starting reverse animation',
        );
      }
      _flipController.reverse();
    } else {
      if (kDebugMode) {
        debugPrint(
          '[CardState] ${widget.card.exerciseName}: Starting forward animation',
        );
      }
      _flipController.forward();
    }
    // Don't update card state here - wait for animation to complete
  }

  void _handlePanStart(DragStartDetails details) {
    if (kDebugMode) {
      debugPrint(
        '[CardGesture] ${widget.card.exerciseName}: Pan start detected, state: $_currentState',
      );
    }

    // Notify parent that user is interacting (dismiss keyboard, etc.)
    widget.onInteractionStart?.call();

    // State machine guard: only allow pan in idle states
    if (!_currentState.allowsPanStart) {
      if (kDebugMode) {
        debugPrint(
          '[CardGesture] ${widget.card.exerciseName}: Pan start rejected - wrong state',
        );
      }
      return;
    }

    // Check if drag started in bottom 25% of card when flipped
    if (widget.card.isFlipped) {
      final RenderBox? cardBox = context.findRenderObject() as RenderBox?;
      if (cardBox != null) {
        final Offset localPosition = cardBox.globalToLocal(
          details.globalPosition,
        );
        final double cardHeight = cardBox.size.height;
        final double bottomThreshold =
            cardHeight * 0.75; // Bottom 25% starts at 75%

        if (localPosition.dy >= bottomThreshold) {
          // Started in bottom 25% - store position but don't commit yet
          setState(() {
            _dragStartLocalPosition = localPosition;
            _dragStartGlobal = details.globalPosition;
            _gestureCommitted = false;
          });
          return; // Wait for pan update to determine direction
        }
      }
    }

    // Normal card drag (not in bottom area)
    _transitionState(CardInteractionState.draggingCard);

    setState(() {
      _isDragging = true;
      _gestureCommitted = true;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    // Check if we're in bottom area but haven't committed to a gesture yet
    if (!_gestureCommitted && _dragStartLocalPosition != null) {
      final deltaY = details.delta.dy;

      // Determine gesture type based on initial direction
      if (deltaY > 0) {
        // Dragging DOWN → Token mode
        _transitionState(CardInteractionState.draggingToken);
        setState(() {
          _isDraggingToken = true;
          _gestureCommitted = true;
        });
        widget.onTokenDrag?.call(details.globalPosition, true);
      } else {
        // Dragging UP/SIDEWAYS → Card drag mode
        _transitionState(CardInteractionState.draggingCard);
        setState(() {
          _isDragging = true;
          _gestureCommitted = true;
          _dragStartLocalPosition = null;
          _gestureCommitted = false;
          _dragStartLocalPosition = null;
        });
      }
      return;
    }

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
      // End token drag - return to idleFlipped
      setState(() {
        _isDraggingToken = false;
        _dragStartGlobal = null;
      });
      widget.onTokenDrag?.call(details.globalPosition, false);

      // Return to stable state (parent will handle token animation if needed)
      _transitionState(CardInteractionState.idleFlipped);
      return;
    }

    // Normal card drag end
    final velocity = details.velocity.pixelsPerSecond;
    final screenWidth = MediaQuery.of(context).size.width;

    // Check for horizontal swipe (swipe away)
    if (_dragOffset.dx.abs() > screenWidth * 0.3 || velocity.dx.abs() > 500) {
      _animateCardAwayWithMomentum(velocity);
    }
    // Bounce back to stable state
    else {
      setState(() {
        _dragOffset = Offset.zero;
        _dragStartLocalPosition = null;
        _gestureCommitted = false;
        _dragRotation = 0.0;
        _isDragging = false;
      });

      // Return to appropriate stable state
      _transitionState(
        widget.card.isFlipped
            ? CardInteractionState.idleFlipped
            : CardInteractionState.idle,
      );
    }
  }

  void _animateCardAwayWithMomentum(Offset velocity) {
    final screenWidth = MediaQuery.of(context).size.width;
    final direction = _dragOffset.dx > 0 ? 1 : -1;

    // Calculate momentum-based exit with velocity continuation
    final momentumY = _dragOffset.dy + (velocity.dy * 0.3);
    final exitDistance = screenWidth * 1.5 * direction;

    // Notify parent immediately that card is starting to fly away
    widget.onStartSwipeAway?.call();

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
        height: 440,
        clipBehavior: Clip.none,
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
        child: isFrontVisible ? _frontCard : _buildBackCard(),
      ),
    );
  }

  Widget _buildFrontCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(
            widget.card.exerciseName.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 5,
            minFontSize: 12,
            maxFontSize: 36,
            stepGranularity: 0.5,
            wrapWords: true,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppColors.limeGreen,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldInput(dynamic field) {
    final controller = _fieldControllers[field.name];
    final focusNode = _fieldFocusNodes[field.name];

    if (controller == null || focusNode == null) {
      return const SizedBox.shrink();
    }

    // Determine increment/decrement step based on field name
    final int step = field.name == 'weight' ? 2 : 1;
    final int minValue = field.name == 'weight' ? step : 1;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      readOnly: true,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 32,
        color: AppColors.offWhite,
        fontWeight: FontWeight.w300,
        letterSpacing: 1.5,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        prefixIcon: ListenableBuilder(
          listenable: Listenable.merge([focusNode, controller]),
          builder: (context, child) {
            final isEmpty = controller.text == '- ${field.unit}';
            return Opacity(
              opacity: (isEmpty || focusNode.hasFocus) ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !(isEmpty || focusNode.hasFocus),
                child: child!,
              ),
            );
          },
          child: IconButton(
            onPressed: () {
              focusNode.requestFocus();
              _startFieldTimer(field.name);
              String text = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
              int current = int.tryParse(text) ?? 0;
              if (current >= minValue) {
                int newValue = current - step;
                controller.text = '$newValue ${field.unit}';

                // Update field value in card model
                final updatedValues = Map<String, String>.from(
                  widget.card.fieldValues,
                );
                updatedValues[field.name] = newValue.toString();
                widget.onCardUpdate(
                  widget.card.copyWith(fieldValues: updatedValues),
                );
              }
            },
            icon: const Icon(Icons.chevron_left),
            color: AppColors.limeGreen,
            iconSize: 28,
            style: IconButton.styleFrom(padding: const EdgeInsets.all(4)),
          ),
        ),
        suffixIcon: ListenableBuilder(
          listenable: Listenable.merge([focusNode, controller]),
          builder: (context, child) {
            final isEmpty = controller.text == '- ${field.unit}';
            return Opacity(
              opacity: (isEmpty || focusNode.hasFocus) ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !(isEmpty || focusNode.hasFocus),
                child: child!,
              ),
            );
          },
          child: IconButton(
            onPressed: () {
              focusNode.requestFocus();
              _startFieldTimer(field.name);
              String text = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
              int current = int.tryParse(text) ?? 0;
              int newValue = current + step;
              controller.text = '$newValue ${field.unit}';

              // Update field value in card model
              final updatedValues = Map<String, String>.from(
                widget.card.fieldValues,
              );
              updatedValues[field.name] = newValue.toString();
              widget.onCardUpdate(
                widget.card.copyWith(fieldValues: updatedValues),
              );
            },
            icon: const Icon(Icons.chevron_right),
            color: AppColors.limeGreen,
            iconSize: 28,
            style: IconButton.styleFrom(padding: const EdgeInsets.all(4)),
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        top: 12.0,
        bottom: 28.0,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 5),
              Column(
                children: [
                  AutoSizeText(
                    widget.card.exerciseName.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    minFontSize: 12,
                    maxFontSize: 24,
                    wrapWords: true,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.offWhite,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Dynamic field rendering
                  ...widget.card.exercise.fields.map((field) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _buildFieldInput(field),
                    );
                  }).toList(),
                ],
              ),
              SizedBox(
                key: _zetButtonKey,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Only allow button press when in stable idleFlipped state
                    if (_currentState != CardInteractionState.idleFlipped) {
                      if (kDebugMode) {
                        debugPrint(
                          '[CardState] ${widget.card.exerciseName}: ZET button tap rejected - state is $_currentState',
                        );
                      }
                      return;
                    }

                    // Get button position in global coordinates
                    final RenderBox? box =
                        _zetButtonKey.currentContext?.findRenderObject()
                            as RenderBox?;
                    if (box != null) {
                      final Offset position = box.localToGlobal(Offset.zero);
                      final Offset buttonCenter = Offset(
                        position.dx + box.size.width / 2,
                        position.dy + box.size.height / 2,
                      );

                      // Transition to animatingToken state to block interactions
                      _transitionState(CardInteractionState.animatingToken);

                      // Increment set number immediately
                      setState(() {
                        _currentSetNumber++;
                      });

                      widget.onCompleted(buttonCenter, () {
                        // Return to stable state after animation completes
                        if (mounted) {
                          if (kDebugMode) {
                            debugPrint(
                              '[CardState] ${widget.card.exerciseName}: Token animation complete, returning to idleFlipped',
                            );
                          }
                          _transitionState(CardInteractionState.idleFlipped);
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.limeGreen,
                    foregroundColor: AppColors.pureBlack,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: Text(
                    'SET $_currentSetNumber',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // X button at top right
          if (!_isDismissing)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (kDebugMode) {
                    debugPrint(
                      '[CardGesture] ${widget.card.exerciseName}: X button tapped, animating card away',
                    );
                  }
                  // Hide button immediately and animate card flying off to the right
                  setState(() {
                    _isDismissing = true;
                    _isDragging =
                        false; // Keep false so AnimatedContainer animates
                    _dragOffset = const Offset(500, -100);
                    _dragRotation = 0.3;
                  });
                  // Wait for animation to complete before removing card
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      widget.onSwipedAway();
                    }
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.transparent,
                  alignment: Alignment.topRight,
                  child: const Icon(
                    Icons.close,
                    color: AppColors.offWhite,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTapDown: (details) => _lastTapPosition = details.localPosition,
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
        ),
      ],
    );
  }
}
