import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/providers/preferences_provider.dart';
import '../view_models/card_model.dart';
import '../../../../l2_domain/models/exercises/strength_exercise.dart';
import '../../../../l2_domain/models/exercises/isometric_exercise.dart';
import '../../../../l2_domain/models/exercises/bodyweight_exercise.dart';
import '../../../../l2_domain/models/exercises/assisted_machine_exercise.dart';
import '../../../../l2_domain/models/exercises/distance_cardio_exercise.dart';
import '../../../../l2_domain/models/exercises/duration_cardio_exercise.dart';

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
  Offset? _lastTapPosition;
  Offset? _dragStartLocalPosition;
  bool _gestureCommitted = false;
  int _currentSetNumber = 0;

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

    // Initialize controllers and focus nodes based on exercise type
    _initializeInputFields();

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

  /// Initialize input fields based on exercise type
  void _initializeInputFields() {
    final exercise = widget.card.exercise;
    final formatters = context.read<PreferencesProvider>().formatters;

    if (exercise is IsometricExercise) {
      // Isometric exercises: duration + optional weight
      _fieldControllers['duration'] = TextEditingController(text: '- sec');
      _fieldControllers['weight'] = TextEditingController(
        text: exercise.isBodyweightBased
            ? 'bodyweight'
            : '- ${formatters.getWeightUnit()}',
      );
      _fieldFocusNodes['duration'] = FocusNode();
      _fieldFocusNodes['weight'] = FocusNode();

      _fieldFocusNodes['duration']!.addListener(() {
        if (_fieldFocusNodes['duration']!.hasFocus) {
          _startFieldTimer('duration');
        } else {
          _fieldTimers['duration']?.cancel();
        }
      });

      _fieldFocusNodes['weight']!.addListener(() {
        if (_fieldFocusNodes['weight']!.hasFocus) {
          _startFieldTimer('weight');
        } else {
          _fieldTimers['weight']?.cancel();
        }
      });
    } else if (exercise is BodyweightExercise) {
      // Bodyweight exercises: reps + optional weight
      _fieldControllers['reps'] = TextEditingController(text: '- reps');
      _fieldControllers['weight'] = TextEditingController(text: 'bodyweight');
      _fieldFocusNodes['reps'] = FocusNode();
      _fieldFocusNodes['weight'] = FocusNode();

      _fieldFocusNodes['reps']!.addListener(() {
        if (_fieldFocusNodes['reps']!.hasFocus) {
          _startFieldTimer('reps');
        } else {
          _fieldTimers['reps']?.cancel();
        }
      });

      _fieldFocusNodes['weight']!.addListener(() {
        if (_fieldFocusNodes['weight']!.hasFocus) {
          _startFieldTimer('weight');
        } else {
          _fieldTimers['weight']?.cancel();
        }
      });
    } else if (exercise is AssistedMachineExercise) {
      // Assisted machine exercises: reps + assistance weight (bodyweight-based)
      _fieldControllers['reps'] = TextEditingController(text: '- reps');
      _fieldControllers['assistanceWeight'] = TextEditingController(
        text: 'bodyweight',
      );
      _fieldFocusNodes['reps'] = FocusNode();
      _fieldFocusNodes['assistanceWeight'] = FocusNode();

      _fieldFocusNodes['reps']!.addListener(() {
        if (_fieldFocusNodes['reps']!.hasFocus) {
          _startFieldTimer('reps');
        } else {
          _fieldTimers['reps']?.cancel();
        }
      });

      _fieldFocusNodes['assistanceWeight']!.addListener(() {
        if (_fieldFocusNodes['assistanceWeight']!.hasFocus) {
          _startFieldTimer('assistanceWeight');
        } else {
          _fieldTimers['assistanceWeight']?.cancel();
        }
      });
    } else if (exercise is StrengthExercise) {
      // Other strength exercises (free weight, machine): weight + reps
      _fieldControllers['weight'] = TextEditingController(
        text: '- ${formatters.getWeightUnit()}',
      );
      _fieldControllers['reps'] = TextEditingController(text: '- reps');
      _fieldFocusNodes['weight'] = FocusNode();
      _fieldFocusNodes['reps'] = FocusNode();

      _fieldFocusNodes['weight']!.addListener(() {
        if (_fieldFocusNodes['weight']!.hasFocus) {
          _startFieldTimer('weight');
        } else {
          _fieldTimers['weight']?.cancel();
        }
      });

      _fieldFocusNodes['reps']!.addListener(() {
        if (_fieldFocusNodes['reps']!.hasFocus) {
          _startFieldTimer('reps');
        } else {
          _fieldTimers['reps']?.cancel();
        }
      });
    } else if (exercise is DistanceCardioExercise) {
      // Distance cardio: distance + duration
      _fieldControllers['distance'] = TextEditingController(
        text: '- ${formatters.getDistanceUnit()}',
      );
      _fieldControllers['duration'] = TextEditingController(text: '- min');
      _fieldFocusNodes['distance'] = FocusNode();
      _fieldFocusNodes['duration'] = FocusNode();

      _fieldFocusNodes['distance']!.addListener(() {
        if (_fieldFocusNodes['distance']!.hasFocus) {
          _startFieldTimer('distance');
        } else {
          _fieldTimers['distance']?.cancel();
        }
      });

      _fieldFocusNodes['duration']!.addListener(() {
        if (_fieldFocusNodes['duration']!.hasFocus) {
          _startFieldTimer('duration');
        } else {
          _fieldTimers['duration']?.cancel();
        }
      });
    } else if (exercise is DurationCardioExercise) {
      // Duration cardio: only duration
      _fieldControllers['duration'] = TextEditingController(text: '- min');
      _fieldFocusNodes['duration'] = FocusNode();

      _fieldFocusNodes['duration']!.addListener(() {
        if (_fieldFocusNodes['duration']!.hasFocus) {
          _startFieldTimer('duration');
        } else {
          _fieldTimers['duration']?.cancel();
        }
      });
    }
  }

  /// Extract field values from controllers as Map<String, String>
  /// Returns raw string values from user input fields
  Map<String, String> getFieldValues() {
    final values = <String, String>{};

    for (var entry in _fieldControllers.entries) {
      final controller = entry.value;
      String text = controller.text.trim();

      // Handle bodyweight exercises weight field
      if (entry.key == 'weight' && text.toLowerCase().contains('bw')) {
        // Extract number from "BW+Xkg" format
        final match = RegExp(r'BW\+(\d+)').firstMatch(text);
        if (match != null) {
          values[entry.key] = match.group(1)!;
        } else if (text == 'bodyweight') {
          values[entry.key] = '0';
        }
      } else if (entry.key == 'assistanceWeight' &&
          text.toLowerCase().contains('bw')) {
        // Extract number from "BW-Xkg" format (inverted for assisted machines)
        final match = RegExp(r'BW-(\d+)').firstMatch(text);
        if (match != null) {
          values[entry.key] = match.group(1)!;
        } else if (text == 'bodyweight') {
          values[entry.key] = '0';
        }
      } else {
        // Extract text and remove common units
        final formatters = context.read<PreferencesProvider>().formatters;
        text = text
            .replaceAll(' ${formatters.getWeightUnit()}', '')
            .replaceAll(' reps', '')
            .replaceAll(' rep', '')
            .replaceAll(' ${formatters.getDistanceUnit()}', '')
            .replaceAll(' min', '')
            .replaceAll(' sec', '')
            .trim();

        // Skip placeholder values
        if (text != '-' && text.isNotEmpty && text != 'bodyweight') {
          values[entry.key] = text;
        }
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

    // Update controllers when card user data changes
    for (var entry in widget.card.userData.entries) {
      if (_fieldControllers.containsKey(entry.key)) {
        final controller = _fieldControllers[entry.key]!;
        final newValue = entry.value;
        if (newValue.isNotEmpty) {
          String displayText;

          // Handle weight field for bodyweight-based exercises
          if (entry.key == 'weight') {
            final exercise = widget.card.exercise;
            final isBodyweightBased =
                exercise is BodyweightExercise ||
                (exercise is IsometricExercise && exercise.isBodyweightBased);

            final formatters = context.read<PreferencesProvider>().formatters;
            if (isBodyweightBased) {
              int value = int.tryParse(newValue) ?? 0;
              if (value == 0) {
                displayText = 'bodyweight';
              } else {
                displayText = 'BW+$value${formatters.getWeightUnit()}';
              }
            } else {
              displayText = '$newValue ${formatters.getWeightUnit()}';
            }
          } else if (entry.key == 'assistanceWeight') {
            // Handle assistanceWeight field for assisted machine exercises
            final formatters = context.read<PreferencesProvider>().formatters;
            int value = int.tryParse(newValue) ?? 0;
            if (value == 0) {
              displayText = 'bodyweight';
            } else {
              displayText = 'BW-$value${formatters.getWeightUnit()}';
            }
          } else if (entry.key == 'reps') {
            int value = int.tryParse(newValue) ?? 0;
            displayText = '$newValue ${value == 1 ? "rep" : "reps"}';
          } else if (entry.key == 'duration') {
            final exercise = widget.card.exercise;
            String unit =
                (exercise is DurationCardioExercise ||
                    exercise is DistanceCardioExercise)
                ? 'min'
                : 'sec';
            displayText = '$newValue $unit';
          } else if (entry.key == 'distance') {
            final formatters = context.read<PreferencesProvider>().formatters;
            displayText = '$newValue ${formatters.getDistanceUnit()}';
          } else {
            displayText = newValue;
          }

          if (controller.text != displayText) {
            controller.text = displayText;
          }
        }
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

  void _showInputPanel(
    BuildContext context, {
    required String fieldName,
    required String unit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => _CustomInputPanel(
        fieldName: fieldName,
        unit: unit,
      ),
    );
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
            _lastTapPosition = details.globalPosition;
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
        _lastTapPosition = null;
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

  /// Build input fields based on exercise type
  List<Widget> _buildInputFields() {
    final exercise = widget.card.exercise;

    if (exercise is IsometricExercise) {
      return [
        if (_fieldControllers.containsKey('duration'))
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildSimpleFieldInput('duration', 'sec', 1),
          ),
        if (_fieldControllers.containsKey('weight'))
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildSimpleFieldInput(
              'weight',
              context.watch<PreferencesProvider>().formatters.getWeightUnit(),
              2,
            ),
          ),
      ];
    } else if (exercise is BodyweightExercise) {
      return [
        if (_fieldControllers.containsKey('reps'))
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildSimpleFieldInput('reps', 'reps', 1),
          ),
        if (_fieldControllers.containsKey('weight'))
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildSimpleFieldInput(
              'weight',
              context.watch<PreferencesProvider>().formatters.getWeightUnit(),
              2,
            ),
          ),
      ];
    } else if (exercise is AssistedMachineExercise) {
      return [
        if (_fieldControllers.containsKey('reps'))
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildSimpleFieldInput('reps', 'reps', 1),
          ),
        if (_fieldControllers.containsKey('assistanceWeight'))
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildSimpleFieldInput(
              'assistanceWeight',
              context.watch<PreferencesProvider>().formatters.getWeightUnit(),
              2,
            ),
          ),
      ];
    } else if (exercise is StrengthExercise) {
      return [
        if (_fieldControllers.containsKey('weight'))
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildSimpleFieldInput(
              'weight',
              context.watch<PreferencesProvider>().formatters.getWeightUnit(),
              2,
            ),
          ),
        if (_fieldControllers.containsKey('reps'))
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildSimpleFieldInput('reps', 'reps', 1),
          ),
      ];
    } else if (exercise is DistanceCardioExercise) {
      return [
        if (_fieldControllers.containsKey('distance'))
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildSimpleFieldInput(
              'distance',
              context.watch<PreferencesProvider>().formatters.getDistanceUnit(),
              1,
            ),
          ),
        if (_fieldControllers.containsKey('duration'))
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildSimpleFieldInput('duration', 'min', 1),
          ),
      ];
    } else if (exercise is DurationCardioExercise) {
      return [
        if (_fieldControllers.containsKey('duration'))
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildSimpleFieldInput('duration', 'min', 1),
          ),
      ];
    }

    return [];
  }

  /// Build a simple input field with increment/decrement buttons
  Widget _buildSimpleFieldInput(String fieldName, String unit, int step) {
    final controller = _fieldControllers[fieldName];
    final focusNode = _fieldFocusNodes[fieldName];

    if (controller == null || focusNode == null) {
      return const SizedBox.shrink();
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          readOnly: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize:
                (controller.text == 'bodyweight' ||
                    controller.text.startsWith('BW'))
                ? 26
                : 32,
            color: AppColors.offWhite,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onTap: () {
            // Prevent if card is animating
            if (!_currentState.isStable) return;
            
            HapticFeedback.lightImpact();
            _showInputPanel(context, fieldName: fieldName, unit: unit);
          },
        );
      },
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
                  // Dynamic field rendering based on exercise type
                  ..._buildInputFields(),
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
                    '$_currentSetNumber SET',
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

/// Custom input panel for entering workout values
class _CustomInputPanel extends StatelessWidget {
  final String fieldName;
  final String unit;

  const _CustomInputPanel({
    required this.fieldName,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: AppColors.boldGrey,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Custom Input Panel',
              style: TextStyle(
                color: AppColors.offWhite,
                fontSize: 24,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Field: $fieldName',
              style: TextStyle(
                color: AppColors.offWhite.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unit: $unit',
              style: TextStyle(
                color: AppColors.offWhite.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Tap anywhere to close',
              style: TextStyle(
                color: AppColors.limeGreen,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
