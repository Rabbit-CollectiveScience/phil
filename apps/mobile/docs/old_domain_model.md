# Phil App - Data Model Design

## Overview

This document describes the data models used in the Phil fitness tracking application. The app uses a flexible, field-based architecture that allows exercises to track any combination of metrics (weight, reps, duration, distance, etc.) without requiring code changes.

## Core Models

### 1. Exercise

**Purpose**: Defines an exercise with metadata and trackable fields.

**Location**: `lib/l2_domain/models/exercise.dart`

**Fields**:
- `id` (String): Unique identifier
- `name` (String): Exercise name (e.g., "Barbell Squat")
- `description` (String): Instructions and notes
- `categories` (List\<String\>): Tags for filtering (activity type + body parts)
  - Activity types: "strength", "cardio"
  - Body parts: "chest", "back", "legs", "shoulders", "arms", "core"
- `fields` (List\<ExerciseField\>): Defines what metrics this exercise tracks

**Examples**:
```dart
// Strength exercise
Exercise(
  id: 'squat_001',
  name: 'Barbell Squat',
  description: 'Compound leg exercise...',
  categories: ['strength', 'legs', 'core'],
  fields: [
    ExerciseField(name: 'weight', type: FieldTypeEnum.number),
    ExerciseField(name: 'reps', type: FieldTypeEnum.number),
  ],
)

// Cardio exercise
Exercise(
  id: 'run_001',
  name: 'Treadmill Run',
  description: 'Indoor running...',
  categories: ['cardio'],
  fields: [
    ExerciseField(name: 'duration', type: FieldTypeEnum.number),
    ExerciseField(name: 'distance', type: FieldTypeEnum.number),
  ],
)
```

---

### 2. WorkoutSet

**Purpose**: Records a completed set of an exercise with actual workout data.

**Location**: `lib/l2_domain/models/workout_set.dart`

**Fields**:
- `id` (String): Unique identifier
- `exerciseId` (String): Reference to the Exercise
- `completedAt` (DateTime): When the set was completed
- `values` (Map\<String, dynamic\>?): Actual workout data
  - Keys correspond to Exercise.fields[].name
  - Values are the recorded metrics
  - Can be null or empty if not yet recorded

**Examples**:
```dart
// Squat set
WorkoutSet(
  id: 'set_001',
  exerciseId: 'squat_001',
  completedAt: DateTime(2026, 1, 2, 14, 30),
  values: {
    'weight': 100.0,
    'reps': 10.0,
  },
)

// Running set
WorkoutSet(
  id: 'set_002',
  exerciseId: 'run_001',
  completedAt: DateTime(2026, 1, 2, 15, 00),
  values: {
    'duration': 1800.0,  // 30 minutes in seconds
    'distance': 5.0,      // 5 km
  },
)
```

---

### 3. PersonalRecord

**Purpose**: Tracks personal records for any trackable metric of an exercise.

**Location**: `lib/l2_domain/models/personal_record.dart`

**Fields**:
- `id` (String): Unique identifier
- `exerciseId` (String): Reference to the Exercise
- `type` (String): Type of PR (e.g., "maxWeight", "maxReps", "maxDistance")
  - Generated dynamically from field names: "max{FieldName}"
  - Examples: "maxWeight", "maxReps", "maxVolume", "maxDuration", "maxDistance"
- `value` (double): The PR value
- `achievedAt` (DateTime): When the PR was achieved

**Key Features**:
- **Dynamic PR Types**: The system automatically generates PR types based on exercise fields
  - If an exercise has a "weight" field → tracks "maxWeight" PR
  - If an exercise has a "reps" field → tracks "maxReps" PR
  - If an exercise has a "distance" field → tracks "maxDistance" PR
- **Derived PRs**: Some PRs are calculated from multiple fields
  - "maxVolume" = weight × reps
- **Multiple PRs per Set**: A single workout set can achieve multiple PRs simultaneously

**Examples**:
```dart
// Weight PR
PersonalRecord(
  id: 'pr_001',
  exerciseId: 'squat_001',
  type: 'maxWeight',
  value: 150.0,
  achievedAt: DateTime(2026, 1, 2, 14, 30),
)

// Reps PR
PersonalRecord(
  id: 'pr_002',
  exerciseId: 'squat_001',
  type: 'maxReps',
  value: 20.0,
  achievedAt: DateTime(2026, 1, 2, 14, 30),
)

// Volume PR (calculated: weight × reps)
PersonalRecord(
  id: 'pr_003',
  exerciseId: 'squat_001',
  type: 'maxVolume',
  value: 1500.0,  // 100kg × 15 reps
  achievedAt: DateTime(2026, 1, 1, 10, 00),
)
```

---

## Key Design Principles

### 1. Flexibility Through Fields
Exercises are not limited to predefined metrics. Any exercise can track any combination of fields, making the system extensible without code changes.

### 2. Dynamic PR Detection
The PR system automatically detects and records personal records for ANY numeric field defined in an exercise. When you add a new exercise type with new fields (e.g., "pace" for running), the system will automatically track PRs for those fields.

### 3. Data Relationships
```
Exercise (1) ←→ (many) WorkoutSet
Exercise (1) ←→ (many) PersonalRecord

WorkoutSet.values keys match Exercise.fields[].name
PersonalRecord.type is derived from Exercise.fields[].name
```

### 4. Type Safety with Flexibility
- Models use strongly-typed Dart classes
- `values` Map provides flexibility for dynamic fields
- Field types are validated against ExerciseField definitions

---

## PR System Architecture

### How PRs are Detected and Recorded

1. **User Completes a Set**
   - RecordWorkoutSetUseCase receives exercise data and values
   - Saves the WorkoutSet to the repository

2. **Automatic PR Check**
   - CheckForNewPRUseCase runs automatically
   - Loops through ALL numeric fields in the exercise
   - For each field, checks if the new value > current PR value
   - Also checks derived PRs (like volume = weight × reps)

3. **PR Types Generated Dynamically**
   ```dart
   // For a field named "weight"
   prType = "max" + capitalize("weight") = "maxWeight"
   
   // For a field named "duration"
   prType = "max" + capitalize("duration") = "maxDuration"
   ```

4. **Multiple PRs in One Set**
   - A single set can achieve multiple PRs
   - Example: New weight PR + new reps PR + new volume PR all in one set

5. **PR Recalculation**
   - When a set is deleted, RecalculatePRsForExerciseUseCase runs
   - Recalculates all PRs for that exercise from remaining sets
   - Ensures PR data stays accurate

---

## Historical Context

### Evolution from Enum to String

**Phase 1-3 Refactoring (Completed Jan 2, 2026)**:
- Originally used `PRType` enum with fixed values (maxWeight, maxReps, maxVolume)
- Refactored to use `String` type for extensibility
- Implemented dynamic field-based PR detection
- System now supports unlimited PR types based on exercise fields

**Result**: 
- Can add new exercise types without code changes
- PR system automatically adapts to new fields
- All 157 tests passing after refactoring

---

## Future Extensibility

### Adding New Exercise Types

**Example: Adding Swimming**
```dart
Exercise(
  id: 'swim_001',
  name: 'Freestyle Swimming',
  categories: ['cardio', 'full-body'],
  fields: [
    ExerciseField(name: 'distance', type: FieldTypeEnum.number),
    ExerciseField(name: 'duration', type: FieldTypeEnum.number),
    ExerciseField(name: 'pace', type: FieldTypeEnum.number),
  ],
)
```

**Automatic PR Tracking**:
- System will automatically track: maxDistance, maxDuration, maxPace
- No code changes needed in PR detection logic
- UI will display all PR types dynamically

---

## Data Storage

### Hive Boxes Used
- `exercises`: Stores Exercise objects
- `workoutSets`: Stores WorkoutSet objects  
- `personalRecords`: Stores PersonalRecord objects

### Repositories
- `ExerciseRepository`: CRUD operations for exercises
- `WorkoutSetRepository`: CRUD operations for workout sets
- `PersonalRecordRepository`: CRUD and query operations for PRs
  - `getCurrentPR(exerciseId, type)`: Get current PR for specific type
  - `getPRsByExercise(exerciseId)`: Get all PRs for an exercise
  - `save(pr)`: Save or update a PR

---

## Testing

All models and use cases are fully tested:
- Unit tests: 17 tests for PersonalRecord model
- Integration tests: 157 tests covering all use cases
- TDD approach ensures reliability

**Key Test Coverage**:
- PR detection for multiple field types
- PR recalculation on set deletion
- Dynamic field-based PR generation
- Multiple PRs per set scenario