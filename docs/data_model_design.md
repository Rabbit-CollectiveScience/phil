# Data Model Design

## Overview

The workout tracking system uses a **flexible field-based architecture** to support diverse exercise types (strength, cardio, flexibility) without creating specialized models for each. Exercises define what fields they track, and workout sets store the recorded values.

## Core Models

### Exercise

Defines an exercise with metadata and trackable fields.

```dart
class Exercise {
  final String id;
  final String name;
  final String description;
  final ExerciseTypeEnum type;        // strength | cardio | flexibility
  final List<ExerciseField> fields;   // What this exercise tracks
}
```

**Key Design**: `fields` list makes exercises completely flexible. Each exercise defines its own tracking requirements.

### ExerciseField

Metadata describing what data an exercise collects.

```dart
class ExerciseField {
  final String name;              // Internal key (e.g., "weight", "durationInSeconds")
  final String label;             // UI display text (e.g., "Weight", "Duration")
  final String unit;              // Display unit (e.g., "kg", "seconds", "reps")
  final FieldTypeEnum type;       // number | duration | text | boolean
  final dynamic defaultValue;     // Optional starting value
}
```

**Purpose**: Provides UI hints for rendering input fields and interpreting values.

### WorkoutSet

Records completed workout data for a specific exercise.

```dart
@HiveType(typeId: 0)
class WorkoutSet extends HiveObject {
  final String id;
  final String exerciseId;                  // Links to Exercise
  final DateTime completedAt;
  final Map<String, dynamic>? values;       // Keys match Exercise.fields[].name
}
```

**Key Design**: 
- `values` is nullable to allow incomplete recordings
- Keys in `values` map correspond to `Exercise.fields[].name`
- Always interpreted in context of its Exercise definition

## Relationship Structure

```
Exercise
├── fields: List<ExerciseField>
│   ├── ExerciseField (name: "weight", type: number, unit: "kg")
│   └── ExerciseField (name: "reps", type: number, unit: "reps")
│
WorkoutSet
├── exerciseId: "legs_1"          → References Exercise
└── values: {
      "weight": 100.0,            → Maps to Exercise.fields[0].name
      "reps": 10                  → Maps to Exercise.fields[1].name
    }
```

**Critical**: WorkoutSet values are meaningless without Exercise context. The Exercise's fields define what each key represents.

## Field Variations by Type

### Strength Exercises (2 fields)
```json
{
  "id": "legs_1",
  "name": "Barbell Back Squat",
  "type": "strength",
  "fields": [
    {"name": "weight", "label": "Weight", "unit": "kg", "type": "number"},
    {"name": "reps", "label": "Reps", "unit": "reps", "type": "number"}
  ]
}
```

**Recorded Set**:
```dart
WorkoutSet(
  exerciseId: "legs_1",
  values: {"weight": 100.0, "reps": 10}
)
```

### Cardio Exercises (2 fields, varying)
```json
{
  "id": "cardio_1",
  "name": "Treadmill",
  "type": "cardio",
  "fields": [
    {"name": "durationInSeconds", "label": "Duration", "unit": "seconds", "type": "duration"},
    {"name": "speed", "label": "Speed", "unit": "km/h", "type": "number"}
  ]
}
```

**Recorded Set**:
```dart
WorkoutSet(
  exerciseId: "cardio_1",
  values: {"durationInSeconds": 1800, "speed": 10.5}
)
```

**Alternative Cardio** (different fields):
```json
{
  "id": "cardio_5",
  "name": "Rowing Machine",
  "fields": [
    {"name": "durationInSeconds", "label": "Duration", "unit": "seconds", "type": "duration"},
    {"name": "distance", "label": "Distance", "unit": "meters", "type": "number"}
  ]
}
```

### Flexibility Exercises (1-3 fields)

**Simple** (1 field):
```json
{
  "id": "flex_6",
  "name": "Shoulder Circles",
  "type": "flexibility",
  "fields": [
    {"name": "reps", "label": "Reps", "unit": "reps", "type": "number"}
  ]
}
```

**With Side Tracking** (2 fields):
```json
{
  "id": "flex_1",
  "name": "Neck Side Stretch",
  "type": "flexibility",
  "fields": [
    {"name": "holdTimeInSeconds", "label": "Hold Time", "unit": "seconds", "type": "duration"},
    {"name": "side", "label": "Side", "unit": "", "type": "text"}
  ]
}
```

**With Reps** (2 fields):
```json
{
  "id": "flex_3",
  "name": "Neck Forward/Backward Tilt",
  "type": "flexibility",
  "fields": [
    {"name": "holdTimeInSeconds", "label": "Hold Time", "unit": "seconds", "type": "duration"},
    {"name": "reps", "label": "Reps", "unit": "reps", "type": "number"}
  ]
}
```

## Enums

### ExerciseTypeEnum
```dart
enum ExerciseTypeEnum { strength, cardio, flexibility }
```

Categorizes exercises for filtering and organization.

### FieldTypeEnum
```dart
enum FieldTypeEnum { number, duration, text, boolean }
```

Determines UI input type and validation rules:
- **number**: Numeric input (weight, reps, speed)
- **duration**: Time input (seconds, formatted as minutes:seconds in UI)
- **text**: Free-form text (e.g., "left" or "right" for side tracking)
- **boolean**: Yes/no checkbox

## Design Benefits

### 1. Flexibility
New exercises don't require code changes. Just add JSON definition with different fields.

### 2. Type Safety
Exercise model ensures fields are always defined. WorkoutSet values are validated against exercise fields.

### 3. Dynamic UI
UI automatically generates input fields based on Exercise.fields:
```dart
// UI reads Exercise.fields to build inputs
for (var field in exercise.fields) {
  buildInputWidget(field.label, field.unit, field.type);
}
```

### 4. Backward Compatibility
Nullable `WorkoutSet.values` allows:
- Incomplete workouts (user skips inputs)
- Future field additions without breaking existing data
- Optional tracking features

## Data Flow

### Recording Workflow
```
1. User selects Exercise
   ↓
2. UI reads Exercise.fields
   ↓
3. UI generates input fields dynamically
   ↓
4. User enters values
   ↓
5. UI creates Map<String, dynamic> with field names as keys
   ↓
6. WorkoutSet saved with exerciseId and values map
```

### Display Workflow
```
1. Load WorkoutSet from storage
   ↓
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
