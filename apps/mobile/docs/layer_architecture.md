# Phil Mobile App - Layer Architecture

## Overview

Phil follows **Clean Architecture** with three layers ensuring separation of concerns, testability, and maintainability.

```
lib/
├── l1_ui/              # Layer 1: User Interface
├── l2_domain/          # Layer 2: Business Logic
├── l3_data/            # Layer 3: Data Access
└── main.dart           # Dependency Injection Setup
```

---

## Layer 1: User Interface (l1_ui/)

**Purpose:** UI rendering, user interactions, UI state management

**Structure:**
```
l1_ui/
├── pages/              # Full-screen pages
├── widgets/            # Reusable UI components
└── view_models/        # UI-specific data structures (grouping, formatting)
```

**Key Rules:**

1. **No Business Logic** - Delegate all business rules to L2 use cases
2. **Never Import L3** - Access data only through L2 use cases via GetIt
3. **View Models for UI Logic** - Use view models for display grouping and formatting

```dart
// ✅ CORRECT: L1 calls use case via GetIt
final useCase = GetIt.instance<RecordWorkoutSetUseCase>();
await useCase.execute(exerciseId: id, values: values);

// ❌ WRONG: L1 importing repository
import '../../l3_data/repositories/hive_workout_set_repository.dart';
```

---

## Layer 2: Domain (l2_domain/)

**Purpose:** Business logic, domain models, use case workflows

**Structure:**
```
l2_domain/
├── models/                      # Domain entities (Exercise, WorkoutSet)
└── use_cases/                   # Business workflows
    └── workout_use_cases/
```

**Key Rules:**

1. **Define Repository Interfaces** - L2 defines contracts, L3 implements them
2. **Pure Dart** - No Flutter dependencies, platform-independent
3. **Use Cases = Business Operations** - One use case per workflow

```dart
// Use Case Pattern
class RecordWorkoutSetUseCase {
  final WorkoutSetRepository _repository; // Interface, not concrete class
  
  RecordWorkoutSetUseCase(this._repository);
  
  Future<WorkoutSet> execute({
    required String exerciseId,
    Map<String, dynamic>? values,
  }) async {
    // Business logic: Generate ID, timestamp
    final workoutSet = WorkoutSet(
      id: const Uuid().v4(),
      exerciseId: exerciseId,
      values: values,
      completedAt: DateTime.now(),
    );
    
    return await _repository.saveWorkoutSet(workoutSet);
  }
}
```

---

## Layer 3: Data (l3_data/)

**Purpose:** Data persistence, external data sources

**Structure:**
```
l3_data/
└── repositories/
    ├── hive_workout_set_repository.dart      # Production: Hive
    ├── stub_workout_set_repository.dart      # Testing: In-memory
    └── json_exercise_repository.dart         # Production: JSON assets
```

**Key Rules:**

1. **Implement L2 Interfaces** - Concrete implementations of repository contracts
2. **Multiple Implementations** - Different implementations for production/testing
3. **Data Transformation** - Convert external formats ↔ domain models

```dart
class HiveWorkoutSetRepository implements WorkoutSetRepository {
  final Box<WorkoutSet> _box;
  
  @override
  Future<WorkoutSet> saveWorkoutSet(WorkoutSet workoutSet) async {
    await _box.add(workoutSet);
    return workoutSet;
  }
}
```

---

## Dependency Injection (GetIt)

**Setup in main.dart:**

```dart
Future<void> _setupDependencies(Box<WorkoutSet> box) async {
  final getIt = GetIt.instance;
  
  // L3: Register concrete repositories
  getIt.registerSingleton<WorkoutSetRepository>(
    HiveWorkoutSetRepository(box),
  );
  
  // L2: Register use cases with repository dependencies
  getIt.registerFactory<RecordWorkoutSetUseCase>(
    () => RecordWorkoutSetUseCase(getIt<WorkoutSetRepository>()),
  );
}
```

**Usage in L1:**

```dart
// Retrieve use case from DI container
final useCase = GetIt.instance<RecordWorkoutSetUseCase>();
await useCase.execute(...);
```

---

## UI Logic vs Domain Logic

### UI Logic (L1)
- Animation states
- Display grouping (WorkoutGroup.groupConsecutive)
- Time formatting for display
- Navigation and gestures
- Theme and styling

### Domain Logic (L2)
- Business validation rules
- ID generation and timestamps
- Data filtering by business criteria
- Workflow orchestration
- Business calculations

```dart
// ✅ UI Logic in L1
class WorkoutGroup {
  static List<WorkoutGroup> groupConsecutive(List<WorkoutSetWithDetails> workouts) {
    // Groups consecutive same exercises for display
  }
}

// ✅ Domain Logic in L2
class GetTodayCompletedCountUseCase {
  Future<int> execute() async {
    final todayWorkouts = await _repository.getTodayWorkoutSets();
    return todayWorkouts.length; // Business rule: what counts as "today"
  }
}
```

---

## Dependency Rules

### ✅ Allowed
```
L1 → L2 (via GetIt)  ✅ UI uses use cases
L3 → L2              ✅ Implements interfaces
```

### ❌ Forbidden
```
L1 → L3  ❌ UI cannot access repositories directly
L2 → L1  ❌ Domain cannot depend on UI
L2 → L3  ❌ Domain cannot know concrete implementations
```

---

## Testing Strategy

Each layer tested independently:

```dart
// L2 Use Case Test (with stub repository)
test('should create workout with unique ID', () async {
  final stubRepo = StubWorkoutSetRepository();
  final useCase = RecordWorkoutSetUseCase(stubRepo);
  
  final result = await useCase.execute(exerciseId: 'test', values: {'weight': 50});
  
  expect(result.id, isNotEmpty);
  expect(result.values, equals({'weight': 50}));
});
```

---

## Common Pitfalls

| ❌ Wrong | ✅ Correct |
|---------|----------|
| Business logic in widgets | Move to L2 use cases |
| L1 imports repositories | Use GetIt to inject use cases |
| Use cases return widgets | Return domain models |
| Manual repo instantiation | Register in main.dart |

---

## Summary

**L1 (UI):** Renders views, retrieves use cases via GetIt  
**L2 (Domain):** Business rules, defines contracts  
**L3 (Data):** Implements persistence  
**GetIt:** Wires layers together

This ensures **testable, maintainable, and scalable** code.
