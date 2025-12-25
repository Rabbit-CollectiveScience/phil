# Card Interaction State Machine Refactor

## Status: Phase 1 Complete - Ready for Testing

## What Was Changed

### Added State Machine Infrastructure

**New Enum: `CardInteractionState`**
```dart
enum CardInteractionState {
  idle,              // Front side, no interaction
  idleFlipped,       // Back side, no interaction
  flipping,          // Flip animation in progress
  draggingCard,      // Swiping card left/right
  draggingToken,     // Dragging token from bottom 25%
  animatingToken,    // Token flying to counter (not yet implemented in card)
}
```

**Validation Extension Methods**
- `allowsTap` - Can the card accept tap gestures?
- `allowsPanStart` - Can the card accept pan/drag gestures?
- `isStable` - Is the card in a stable state (not animating)?
- `isAnimating` - Is any animation in progress?

### Key Fixes Implemented

1. **Tap Gesture Guard**
   - Only accepts taps in `idle` or `idleFlipped` states
   - Blocks taps during flip animation
   - Transitions to `flipping` state, then auto-transitions to stable state when animation completes

2. **Pan Gesture Guard**
   - Only accepts pan start in `idle` or `idleFlipped` states
   - Blocks pan during flip animation
   - Correctly distinguishes between card drag and token drag based on touch location

3. **Fixed didUpdateWidget Bug**
   - Now only syncs flip state when `_currentState.isStable`
   - Prevents forced animation jumps during flip animations
   - **This was likely the cause of the "card flips to front and becomes unresponsive" bug**

4. **State Transitions**
   - All gesture handlers transition to appropriate states
   - Animation completion listeners transition back to stable states
   - Pan end always returns to a stable state

5. **Debug Logging**
   - All state transitions logged in debug mode
   - Gesture rejections logged with reason
   - Can track state flow to debug issues

## Testing Checklist

Run through these scenarios with debug logging enabled:

### Basic Interactions
- [ ] Tap front side → flips to back (logs: idle → flipping → idleFlipped)
- [ ] Tap back side → flips to front (logs: idleFlipped → flipping → idle)
- [ ] Tap during flip animation → rejected (log shows rejection)

### Card Dragging
- [ ] Pan from top 75% when front → card rotates (logs: idle → draggingCard → idle)
- [ ] Pan from top 75% when back → card rotates (logs: idleFlipped → draggingCard → idleFlipped)
- [ ] Swipe card away → moves to back of stack (logs: draggingCard → idle/idleFlipped)
- [ ] Start pan during flip → rejected (log shows rejection)

### Token Dragging
- [ ] Pan from bottom 25% when flipped → token follows finger (logs: idleFlipped → draggingToken → idleFlipped)
- [ ] Pan from bottom 25% when not flipped → normal card drag (bottom 25% rule only applies when flipped)
- [ ] Token drag to counter → vibrates and animates (parent handles this)
- [ ] Token drag not reaching counter → returns to card (logs: draggingToken → idleFlipped)

### Edge Cases
- [ ] Rapid double-tap → second tap rejected while first flip in progress
- [ ] Tap while dragging card → should not happen (tap only works in idle states)
- [ ] Search bar interaction → doesn't interfere with card state
- [ ] Weight/reps editing → can happen in idleFlipped state
- [ ] Parent re-renders (counter changes) → card doesn't snap during animation

## Watch Debug Console For:

```
[CardState] Squat: Initial state = idle
[CardGesture] Squat: Tap detected, state: idle
[CardState] Squat: idle → flipping
[CardState] Squat: flipping → idleFlipped
[CardGesture] Squat: Tap detected, state: idleFlipped
[CardGesture] Squat: Tap rejected - wrong state  <-- This is good! Blocked during animation
```

## What's Still Using Legacy Flags

These flags still exist alongside the state machine:
- `_isDragging` - Used for rendering logic (rotate card while dragging)
- `_isFlipping` - Used for rendering logic
- `_isDraggingToken` - Used for token position updates
- `_isCompleting` - Not currently used

**Next Phase:** After validating state machine works correctly, we can remove these flags and derive rendering behavior from `_currentState`.

## Known Limitations

1. `animatingToken` state exists but parent (WorkoutHomePage) still handles token animation timing
2. Legacy flags still present - will remove after validation
3. No cooldown/debounce on taps yet (can add if needed)

## Rollback Plan

If issues are found:
```bash
git log --oneline  # Find commit before state machine
git revert <commit-hash>  # Rollback to previous version
```

Current implementation preserved in this commit for future reference.

## Next Steps

1. **Test thoroughly** - Run through entire checklist
2. **Monitor debug logs** - Look for unexpected state transitions
3. **Verify bug is fixed** - Ensure card no longer becomes unresponsive
4. **Remove legacy flags** - Once state machine is validated
5. **Add cooldown** - If double-tap issues persist
