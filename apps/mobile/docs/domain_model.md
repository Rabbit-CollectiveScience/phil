# Domain Model Design

## Class Hierarchy and Relationships

```mermaid
classDiagram
    %% Exercise Definitions (Templates)
    class Exercise {
        <<abstract>>
        +String id
        +String name
        +List~MuscleGroup~ targetMuscles
    }
    
    class BodyweightExercise {
        +bool canAddWeight
    }
    
    class FreeWeightExercise {
    }
    
    class MachineExercise {
    }
    
    class IsometricExercise {
    }
    
    Exercise <|-- BodyweightExercise
    Exercise <|-- FreeWeightExercise
    Exercise <|-- MachineExercise
    Exercise <|-- IsometricExercise

    %% Workout Set Recordings (Instances)
    class WorkoutSet {
        <<abstract>>
        +String id
        +String exerciseId
        +DateTime timestamp
    }
    
    class BodyweightWorkoutSet {
        +int reps
        +Weight? additionalWeight
    }
    
    class WeightedWorkoutSet {
        +Weight weight
        +int reps
    }
    
    class IsometricWorkoutSet {
        +Duration duration
    }
    
    WorkoutSet <|-- BodyweightWorkoutSet
    WorkoutSet <|-- WeightedWorkoutSet
    WorkoutSet <|-- IsometricWorkoutSet

    %% Personal Records (Achievements)
    class PersonalRecord {
        <<abstract>>
        +String id
        +String exerciseId
        +String workoutSetId
        +DateTime achievedAt
    }
    
    class WeightPR {
    }
    
    class RepsPR {
    }
    
    class VolumePR {
    }
    
    class DurationPR {
    }
    
    PersonalRecord <|-- WeightPR
    PersonalRecord <|-- RepsPR
    PersonalRecord <|-- VolumePR
    PersonalRecord <|-- DurationPR

    %% Relationships - Explicit mappings
    BodyweightExercise "1" --> "*" BodyweightWorkoutSet : records
    FreeWeightExercise "1" --> "*" WeightedWorkoutSet : records
    MachineExercise "1" --> "*" WeightedWorkoutSet : records
    IsometricExercise "1" --> "*" IsometricWorkoutSet : records
    
    BodyweightWorkoutSet "1" --> "0..*" RepsPR : achieves
    BodyweightWorkoutSet "1" --> "0..*" WeightPR : achieves (if additionalWeight)
    WeightedWorkoutSet "1" --> "0..*" WeightPR : achieves
    WeightedWorkoutSet "1" --> "0..*" RepsPR : achieves
    WeightedWorkoutSet "1" --> "0..*" VolumePR : achieves
    IsometricWorkoutSet "1" --> "0..*" DurationPR : achieves

    %% Supporting Types
    class MuscleGroup {
        <<enumeration>>
        CHEST
        BACK
        LEGS
        SHOULDERS
        ARMS
        CORE
    }
    
    class Weight {
        +double kg
        +getInLbs()
        +setInLbs(double)
    }
```

## Key Relationships

**Exercise → WorkoutSet (strict typing):**
- BodyweightExercise → BodyweightWorkoutSet (tracks reps + optional additionalWeight)
- FreeWeightExercise → WeightedWorkoutSet (tracks weight + reps)
- MachineExercise → WeightedWorkoutSet (tracks weight + reps)
- IsometricExercise → IsometricWorkoutSet (tracks duration)

**WorkoutSet → PersonalRecord (by metrics):**
- BodyweightWorkoutSet → RepsPR, WeightPR (if additionalWeight used)
- WeightedWorkoutSet → WeightPR, RepsPR, VolumePR
- IsometricWorkoutSet → DurationPR

## Design Principles

- **Type Safety**: Each concept has a concrete type (no flexible Map<String, dynamic>)
- **Consistency**: All three main hierarchies follow the same inheritance pattern
- **Separation of Concerns**: 
  - Exercise = Definition/Template (what the exercise is)
  - WorkoutSet = Instance/Recording (what you actually did)
  - PersonalRecord = Achievement (your best performance)
