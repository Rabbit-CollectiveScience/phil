# Data Model Design Overview

## Philosophy: Flexible Field-Based Architecture

The app uses a **dynamic field-based system** rather than rigid, type-specific models. This design enables a single unified `Exercise` model to handle **strength**, **cardio**, and **flexibility** exercises through configurable fields, eliminating code duplication and enabling easy extensibility.

---

## Core Models

### Exercise Model
**Location:** `lib/l2_domain/models/exercise.dart`

The central entity representing any exercise type.

```dart
class Exercise {
  final String id;                    // Unique identifier (e.g., "arms_1", "cardio_5")
  final String name;                  // Display name (e.g., "Barbell Curl")
  final String description;           // Detailed instructions
  final ExerciseTypeEnum type;        // strength | cardio | flexibility
  final List<ExerciseField> fields;   // Dynamic trackable fields
}
```

**Key Design Decision:** Instead of creating `StrengthExercise`, `CardioExercise`, `FlexibilityExercise` subclasses, the `fields` property defines what each exercise tracks. This means:
- **Strength**: `[{weight, reps}]`
- **Cardio**: `[{durationInSeconds, speed}]` or `[{durationInSeconds, resistance}]`
- **Flexibility**: `[{holdTimeInSeconds, side}]`

**Benefits:**
- Single code path for all exercise types
- Easy to add new exercise types (e.g., "balance", "plyometric")
- UI can dynamically render input fields based on `fields` metadata

---

### ExerciseField Model
**Location:** `lib/l2_domain/models/exercise_field.dart`

Metadata describing a trackable field for an exercise.

```dart
class ExerciseField {
  final String name;               // Internal key (e.g., "weight", "durationInSeconds")
  final String label;              // UI display text (e.g., "Weight", "Duration")
  final String unit;               // Unit of measurement (e.g., "kg", "seconds", "reps")
  final FieldTypeEnum type;        // number | duration | text | boolean
  final dynamic defaultValue;      // Optional starting value
}
```

**Example from JSON:**
```json
{
  "name": "weight",
  "label": "Weight",
  "unit": "kg",
  "type": "number"
}
```

**Purpose:**
- **UI Rendering:** The `type` field tells the UI what input widget to show (number input, timer, text field)
- **Validation:** The `unit` and `type` guide data validation
- **User Experience:** The `label` provides user-friendly text instead of internal field names
- **Defaults:** The `defaultValue` can pre-fill input fields for new sets

---

### WorkoutSet Model
**Location:** `lib/l2_domain/models/workout_set.dart`

Records completed workout data for a specific exercise.

```dart
@HiveType(typeId: 0)
class WorkoutSet extends HiveObject {
  final String id;                      // Unique set ID
  final String exerciseId;              // Reference to Exercise.id
  final DateTime completedAt;           // Timestamp of completion
  final Map<String, dynamic>? values;   // Field values (keys match ExerciseField.name)
}
```

**Key Design Decision:** The `values` map uses dynamic keys that correspond to `ExerciseField.name`. This means:
- **Strength set:** `{'weight': 100, 'reps': 10, 'unit': 'kg'}`
- **Cardio set:** `{'durationInSeconds': 1800, 'speed': 12.5, 'unit': 'km/h'}`
- **Flexibility set:** `{'holdTimeInSeconds': 30, 'side': 'left'}`

**Storage:** Uses Hive (local NoSQL database) for efficient persistence with `@HiveType` annotations.

**Relationship:** Always used with `Exercise` context. The `Exercise.fields` list defines what keys are expected in `WorkoutSet.values`.

---

## Enums

### ExerciseTypeEnum
**Location:** `lib/l2_domain/models/exercise_type_enum.dart`

```dart
enum ExerciseTypeEnum { strength, cardio, flexibility }
```

High-level categorization for filtering and organizing exercises.

---

### FieldTypeEnum
**Location:** `lib/l2_domain/models/field_type_enum.dart`

```dart
enum FieldTypeEnum { number, duration, text, boolean }
```

Defines input widget type and validation rules. Used by `ExerciseField.type`.

---

### WeightUnitEnum
**Location:** `lib/l2_domain/models/weight_unit_enum.dart`

```dart
enum WeightUnitEnum { kg, lb }
```

User preference for weight display (kilograms or pounds). Applied to `ExerciseField.unit` when rendering weight inputs.

---

## Data Flow: Exercise Definition → Workout Recording

### 1. **Exercise Definition (JSON → Exercise)**
Exercises are defined in JSON files in `assets/data/exercises/`:
- `strength_arms_exercises.json`
- `strength_back_exercises.json`
- `cardio_exercises.json`
- `flexibility_exercises.json`
- etc.

**Example: Barbell Curl (Strength)**
```json
{
  "id": "arms_1",
  "name": "Barbell Curl",
  "description": "Stand with feet shoulder-width apart...",
  "type": "strength",
  "fields": [
    {"name": "weight", "label": "Weight", "unit": "kg", "type": "number"},
    {"name": "reps", "label": "Reps", "unit": "reps", "type": "number"}
  ]
}
```

**Example: Treadmill (Cardio)**
```json
{
  "id": "cardio_1",
  "name": "Treadmill",
  "description": "Step onto the treadmill...",
  "type": "cardio",
  "fields": [
    {"name": "durationInSeconds", "label": "Duration", "unit": "seconds", "type": "duration"},
    {"name": "speed", "label": "Speed", "unit": "km/h", "type": "number"}
  ]
}
```

**Example: Neck Side Stretch (Flexibility)**
```json
{
  "id": "flex_1",
  "name": "Neck Side Stretch",
  "description": "Stand or sit upright...",
  "type": "flexibility",
  "fields": [
    {"name": "holdTimeInSeconds", "label": "Hold Time", "unit": "seconds", "type": "duration", "defaultValue": 20},
    {"name": "side", "label": "Side", "unit": "", "type": "text"}
  ]
}
```

---

### 2. **UI Dynamic Rendering**
When the user selects an exercise:
1. The UI reads `Exercise.fields`
2. For each `ExerciseField`:
   - Renders input widget based on `field.type` (number input, duration picker, text field)
   - Shows `field.label` as the input label
   - Appends `field.unit` to the input (e.g., "kg", "seconds")
   - Pre-fills `field.defaultValue` if provided

**Result:** The same UI code handles all exercise types. No hardcoded input forms.

---

### 3. **Workout Recording (User Input → WorkoutSet)**
When the user completes a set:
1. User enters values in dynamically rendered inputs
2. App creates `WorkoutSet` with:
   - `exerciseId`: Links to the `Exercise.id`
   - `completedAt`: Current timestamp
   - `values`: Map where keys are `ExerciseField.name` and values are user inputs

**Example WorkoutSet for Barbell Curl:**
```dart
WorkoutSet(
  id: "set_123",
  exerciseId: "arms_1",
  completedAt: DateTime(2025, 1, 15, 10, 30),
  values: {
    'weight': 60.0,
    'reps': 12,
    'unit': 'kg'
  }
)
```

**Example WorkoutSet for Treadmill:**
```dart
WorkoutSet(
  id: "set_456",
  exerciseId: "cardio_1",
  completedAt: DateTime(2025, 1, 15, 11, 00),
  values: {
    'durationInSeconds': 1200,
    'speed': 10.5
  }
)
```

---

### 4. **Data Retrieval and Display**
When displaying workout history:
1. Fetch `WorkoutSet` from Hive database
2. Look up corresponding `Exercise` by `exerciseId`
3. For each key in `WorkoutSet.values`:
   - Find matching `ExerciseField` in `Exercise.fields`
   - Use `field.label` and `field.unit` to format display

**Example Display:**
```
Barbell Curl - Jan 15, 10:30 AM
Weight: 60 kg
Reps: 12
```

---

## Architecture Layers

The app follows **Clean Architecture** principles:

### L1: UI Layer (`lib/l1_ui/`)
- **Responsibilities:** User interface, input widgets, navigation
- **Dependencies:** Uses L2 (domain) models directly
- **Examples:** `workout_home_page.dart`, `exercise_filter_type_page.dart`

### L2: Domain Layer (`lib/l2_domain/`)
- **Responsibilities:** Business logic, use cases, core models
- **Dependencies:** None (pure Dart, no framework dependencies)
- **Examples:**
  - **Models:** `Exercise`, `ExerciseField`, `WorkoutSet`
  - **Use Cases:** `GetLastFilterSelectionUseCase`, `ShouldShowFilterPageUseCase`

### L3: Data Layer (`lib/l3_data/`)
- **Responsibilities:** Data access, repositories, external storage
- **Dependencies:** Uses L2 models, interacts with SharedPreferences/Hive
- **Examples:**
  - **Repositories:** `PreferencesRepository`, `LocalPreferencesRepository`
  - **Adapters:** JSON parsing, database adapters

---

## Why This Design?

### 1. **Extensibility**
Adding a new exercise type (e.g., "yoga", "balance") requires:
- Adding enum value to `ExerciseTypeEnum`
- Creating JSON file with exercises and their fields
- **No code changes to models or UI**

### 2. **Maintainability**
- Single `Exercise` model = one place to update
- Shared UI components for all exercise types
- No parallel code paths for strength/cardio/flexibility

### 3. **Data Consistency**
- `WorkoutSet.values` keys always match `ExerciseField.name`
- Type safety through `FieldTypeEnum` validation
- Timestamps ensure chronological ordering

### 4. **Testability**
- Models are pure Dart (no Flutter dependencies in L2)
- Use cases can be tested in isolation with mocks
- Field-based design enables property-based testing

---

## Example: Full Cycle

**1. JSON Definition (Dumbbell Curl):**
```json
{
  "id": "arms_3",
  "name": "Dumbbell Curl",
  "type": "strength",
  "fields": [
    {"name": "weight", "label": "Weight", "unit": "kg", "type": "number"},
    {"name": "reps", "label": "Reps", "unit": "reps", "type": "number"}
  ]
}
```

**2. Parsed Exercise Model:**
```dart
Exercise(
  id: "arms_3",
  name: "Dumbbell Curl",
  description: "Stand with feet shoulder-width apart...",
  type: ExerciseTypeEnum.strength,
  fields: [
    ExerciseField(name: "weight", label: "Weight", unit: "kg", type: FieldTypeEnum.number),
    ExerciseField(name: "reps", label: "Reps", unit: "reps", type: FieldTypeEnum.number)
  ]
)
```

**3. UI Renders:**
- Number input labeled "Weight" with "kg" unit
- Number input labeled "Reps" with "reps" unit

**4. User Completes Set:**
- Weight: 25 kg
- Reps: 15

**5. WorkoutSet Created:**
```dart
WorkoutSet(
  id: "set_789",
  exerciseId: "arms_3",
  completedAt: DateTime.now(),
  values: {
    'weight': 25.0,
    'reps': 15,
    'unit': 'kg'
  }
)
```

**6. Saved to Hive:**
- Local database persists WorkoutSet
- Can be queried by `exerciseId`, `completedAt`, or aggregated for analytics

**7. Display in History:**
```
Dumbbell Curl
Today, 2:45 PM
Weight: 25 kg | Reps: 15
```

---

## Future Enhancements

### 1. **Computed Fields**
Add fields that derive from others (e.g., `totalVolume = weight * reps * sets`)

### 2. **Field Validation Rules**
Extend `ExerciseField` with `minValue`, `maxValue`, `required` properties

### 3. **Custom Exercise Creation**
Allow users to define custom exercises with their own fields

### 4. **Analytics**
Aggregate `WorkoutSet.values` for progress tracking (e.g., "max weight over time")

### 5. **Exercise Relationships**
Add `supersetsId` or `circuit` fields to group related exercises

---

## Summary

The **flexible field-based architecture** is the core innovation of this data model design:

- ✅ **Single source of truth:** One `Exercise` model for all types
- ✅ **Dynamic rendering:** UI adapts to `fields` metadata
- ✅ **Type-safe flexibility:** `FieldTypeEnum` guides validation while allowing variety
- ✅ **Clean separation:** L2 domain models have zero framework dependencies
- ✅ **Scalable:** New exercise types require JSON changes only, no code refactoring

This design prioritizes **extensibility**, **maintainability**, and **simplicity** over rigid type hierarchies.
2. Lookup Exercise by exerciseId
   ↓
3. Read Exercise.fields to interpret values
   ↓
4. Format display: values[field.name] + field.unit
   ↓
5. Example: "100.0 kg · 10 reps"
```

## Key Constraints

1. **WorkoutSet.values keys must match Exercise.fields[].name**  
   Invalid: `{"wt": 100}` when field name is `"weight"`

2. **Exercise must exist to interpret WorkoutSet**  
   WorkoutSet alone is meaningless without Exercise context

3. **Field order in Exercise.fields determines UI display order**  
   First field appears first in input form and summary text

4. **Values can be null but fields cannot**  
   Exercise.fields is required, WorkoutSet.values is optional

## Storage

- **Exercises**: Loaded from JSON files in `assets/data/exercises/*.json`
- **WorkoutSets**: Persisted locally using Hive NoSQL database
- **Hive Adapter**: Generated code in `workout_set.g.dart` handles serialization

Exercises are read-only reference data. WorkoutSets are user-generated transaction data.
