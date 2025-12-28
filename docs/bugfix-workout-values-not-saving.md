# Bug Fix: Workout Values Not Saving/Displaying

## Issue
Workout values were showing as "- kg · - reps" in the completed list instead of the actual entered values.

## Root Cause
1. **SwipeableCard** had input field values stored in `TextEditingController` instances
2. **workout_home_page** was passing `values: null` when calling `RecordWorkoutSetUseCase.execute()`
3. **completed_list_page** was hardcoded to display only weight/reps, not dynamic fields
4. **get_recommended_exercises_use_case** only loaded chest exercises for testing

## Solution

### 1. Added getFieldValues() to SwipeableCard
**File**: `lib/l1_ui/widgets/swipeable_card.dart`

- Made state class public: `SwipeableCardState` (was `_SwipeableCardState`)
- Added `getFieldValues()` method:
  - Loops through `widget.card.exercise.fields`
  - Extracts text from `_fieldControllers`
  - Removes units (e.g., "50 kg" → "50")
  - Converts to proper types based on `field.type`:
    - `number` → `int` or `double`
    - `duration` → `int` (seconds)
    - `text` → `String`
    - `boolean` → `bool`
  - Returns `Map<String, dynamic>`
- Added missing import for `FieldTypeEnum`

**Key Code**:
```dart
Map<String, dynamic> getFieldValues() {
  Map<String, dynamic> values = {};
  for (var field in widget.card.exercise.fields) {
    final controller = _fieldControllers[field.name];
    if (controller == null) continue;
    
    String text = controller.text.replaceAll(field.unit, '').trim();
    if (text == '-' || text.isEmpty) continue;
    
    switch (field.type) {
      case FieldTypeEnum.number:
        final doubleValue = double.tryParse(text);
        if (doubleValue != null) {
          values[field.name] = doubleValue == doubleValue.toInt() 
              ? doubleValue.toInt() 
              : doubleValue;
        }
      case FieldTypeEnum.duration:
        final intValue = int.tryParse(text);
        if (intValue != null) values[field.name] = intValue;
      case FieldTypeEnum.text:
        values[field.name] = text;
      case FieldTypeEnum.boolean:
        values[field.name] = text.toLowerCase() == 'true' || text == '1';
    }
  }
  return values;
}
```

### 2. Updated workout_home_page to Extract Values
**File**: `lib/l1_ui/pages/workout_home_page.dart`

- Changed from `ValueKey` to `GlobalKey<SwipeableCardState>` for top card
- Added `_topCardKey` field
- Initialized key when loading exercises
- Modified `_completeTopCard()` to extract values using `_topCardKey?.currentState?.getFieldValues()`
- Pass extracted values to `recordUseCase.execute()`

**Key Changes**:
```dart
GlobalKey<SwipeableCardState>? _topCardKey;

// When loading exercises:
_topCardKey = GlobalKey<SwipeableCardState>();

// When completing a set:
final fieldValues = _topCardKey?.currentState?.getFieldValues();
final workoutSet = await recordUseCase.execute(
  exerciseId: exercise.id,
  values: fieldValues,
);
```

### 3. Cleaned Up RecordWorkoutSetUseCase
**File**: `lib/l2_domain/use_cases/workout_use_cases/record_workout_set_use_case.dart`

- Removed unused `exerciseType` parameter (was redundant since Exercise already has type)
- Removed `ExerciseTypeEnum` import
- Simplified signature: `execute({required String exerciseId, Map<String, dynamic>? values})`

### 4. Made completed_list_page Format Dynamically
**File**: `lib/l1_ui/pages/completed_list_page.dart`

- Added `Exercise` import
- Changed `_formatSetValues()` to accept `Exercise` parameter
- Made method dynamic: loops through `exercise.fields` and formats each value with unit
- Updated call site to pass `set.exercise`

**Key Code**:
```dart
String _formatSetValues(Map<String, dynamic>? values, Exercise? exercise) {
  if (values == null || values.isEmpty || exercise == null) {
    return 'No data recorded';
  }
  
  return exercise.fields.map((field) {
    final value = values[field.name]?.toString() ?? '-';
    return '$value ${field.unit}'.trim();
  }).join(' · ');
}

// Usage:
_formatSetValues(set.values, set.exercise)
```

### 5. Updated Test Cases
**Files**: All test files in `test/integration/l2_domain/use_cases/`

- Removed `ExerciseTypeEnum` import from all test files
- Removed `exerciseType` parameter from all `recordUseCase.execute()` calls
- Updated `get_recommended_exercises_use_case_test.dart` to expect all exercises (not just chest)
- Changed expectations to verify `cardio_17` (3-field exercise) loads first
- All 26 tests passing ✅

## Testing

### Unit/Integration Tests
```bash
flutter test --no-pub
# Result: 00:01 +26: All tests passed!
```

### Manual Testing Needed
1. Launch app on device
2. Navigate to workout home page
3. Flip a card (e.g., Box Step-Ups with 3 fields: duration, reps, height)
4. Enter values in all fields
5. Complete the set
6. Navigate to completed list
7. Verify values display correctly: "30 sec · 10 reps · 12 inches"
8. Test with 1-field and 2-field exercises as well

## Data Flow Summary

```
User Input → SwipeableCard._fieldControllers
           ↓
workout_home_page uses GlobalKey to access state
           ↓
SwipeableCard.getFieldValues() extracts and parses values
           ↓
RecordWorkoutSetUseCase saves to Hive database
           ↓
GetTodayCompletedListUseCase loads WorkoutSetWithDetails
           ↓
CompletedListPage._formatSetValues() formats dynamically
           ↓
Display: "50 kg · 10 reps" or "30 sec · 10 reps · 12 inches"
```

## Benefits
1. ✅ Supports flexible field system (1-3 fields per exercise)
2. ✅ Properly typed values stored (int/double, not strings)
3. ✅ Dynamic display based on exercise definition
4. ✅ Cleaner use case API (removed redundant parameter)
5. ✅ All tests passing
6. ✅ Error handling and user feedback added

## Files Modified
1. `lib/l1_ui/widgets/swipeable_card.dart` - Added getFieldValues(), made state public
2. `lib/l1_ui/pages/workout_home_page.dart` - Extract values using GlobalKey
3. `lib/l2_domain/use_cases/workout_use_cases/record_workout_set_use_case.dart` - Removed exerciseType
4. `lib/l1_ui/pages/completed_list_page.dart` - Dynamic formatting
5. `test/integration/l2_domain/use_cases/record_workout_set_use_case_test.dart` - Updated tests
6. `test/integration/l2_domain/use_cases/get_today_completed_count_use_case_test.dart` - Updated tests
7. `test/integration/l2_domain/use_cases/get_today_completed_list_use_case_test.dart` - Updated tests
8. `test/integration/l2_domain/use_cases/get_recommended_exercises_use_case_test.dart` - Updated tests
