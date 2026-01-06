# Domain Model Design

## Class Hierarchy and Relationships

```mermaid
classDiagram
    %% Exercise Definitions (Templates)
    class Exercise {
        <<abstract>>
        +String id
        +String name
        +String description
        +bool isCustom
    }
    
    class StrengthExercise {
        <<abstract>>
        +List~MuscleGroup~ targetMuscles
    }
    
    class CardioExercise {
        <<abstract>>
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
    
    class DistanceCardioExercise {
    }
    
    class DurationCardioExercise {
    }
    
    Exercise <|-- StrengthExercise
    Exercise <|-- CardioExercise
    
    StrengthExercise <|-- BodyweightExercise
    StrengthExercise <|-- FreeWeightExercise
    StrengthExercise <|-- MachineExercise
    StrengthExercise <|-- IsometricExercise
    
    CardioExercise <|-- DistanceCardioExercise
    CardioExercise <|-- DurationCardioExercise

    %% Workout Set Recordings (Instances)
    class WorkoutSet {
        <<abstract>>
        +String id
        +String exerciseId
        +DateTime timestamp
        +getVolume()* double?
    }
    
    class BodyweightWorkoutSet {
        +int reps
        +Weight? additionalWeight
        +getVolume() null
    }
    
    class WeightedWorkoutSet {
        +Weight weight
        +int reps
        +getVolume() weight.kg * reps
    }
    
    class IsometricWorkoutSet {
        +Duration duration
        +getVolume() null
    }
    
    class DistanceCardioWorkoutSet {
        +Duration duration
        +Distance distance
        +getPace() distance / duration
        +getVolume() null
    }
    
    class DurationCardioWorkoutSet {
        +Duration duration
        +getVolume() null
    }
    
    WorkoutSet <|-- BodyweightWorkoutSet
    WorkoutSet <|-- WeightedWorkoutSet
    WorkoutSet <|-- IsometricWorkoutSet
    WorkoutSet <|-- DistanceCardioWorkoutSet
    WorkoutSet <|-- DurationCardioWorkoutSet

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
    
    class DistancePR {
    }
    
    class PacePR {
    }
    
    PersonalRecord <|-- WeightPR
    PersonalRecord <|-- RepsPR
    PersonalRecord <|-- VolumePR
    PersonalRecord <|-- DurationPR
    PersonalRecord <|-- DistancePR
    PersonalRecord <|-- PacePR

    %% Relationships - Explicit mappings
    BodyweightExercise "1" --> "*" BodyweightWorkoutSet : records
    FreeWeightExercise "1" --> "*" WeightedWorkoutSet : records
    MachineExercise "1" --> "*" WeightedWorkoutSet : records
    IsometricExercise "1" --> "*" IsometricWorkoutSet : records
    DistanceCardioExercise "1" --> "*" DistanceCardioWorkoutSet : records
    DurationCardioExercise "1" --> "*" DurationCardioWorkoutSet : records
    
    BodyweightWorkoutSet "1" --> "0..*" RepsPR : achieves
    BodyweightWorkoutSet "1" --> "0..*" WeightPR : achieves (if additionalWeight)
    WeightedWorkoutSet "1" --> "0..*" WeightPR : achieves
    WeightedWorkoutSet "1" --> "0..*" RepsPR : achieves
    WeightedWorkoutSet "1" --> "0..*" VolumePR : achieves
    IsometricWorkoutSet "1" --> "0..*" DurationPR : achieves
    DistanceCardioWorkoutSet "1" --> "0..*" DurationPR : achieves
    DistanceCardioWorkoutSet "1" --> "0..*" DistancePR : achieves
    DistanceCardioWorkoutSet "1" --> "0..*" PacePR : achieves
    DurationCardioWorkoutSet "1" --> "0..*" DurationPR : achieves

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
    
    class Distance {
        +double meters
        +getInKm()
        +getInMiles()
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

## Design Principles - Strength Training

### Core Architecture
- **Type Safety**: Each concept has a concrete type (no flexible Map<String, dynamic>)
- **Strict Mappings**: Each Exercise type maps to exactly one WorkoutSet type
- **Separation of Concerns**: 
  - Exercise = Definition/Template (what the exercise is)
  - WorkoutSet = Instance/Recording (what you actually did)
  - PersonalRecord = Achievement (your best performance)

### Exercise Classification
- **BodyweightExercise**: Pure bodyweight movements (push-ups, pull-ups, dips)
  - Can optionally add weight (weighted pull-ups, weighted dips)
  - Separated from weighted exercises for semantic clarity and filtering
  
- **FreeWeightExercise**: Barbells, dumbbells, kettlebells
  - Free-path movements requiring stabilization
  
- **MachineExercise**: Fixed-path equipment (smith machine, leg press, cables, resistance bands)
  - Guided movements, includes resistance bands
  
- **IsometricExercise**: Static holds tracking duration only (planks, wall sits, dead hangs)
  - No weight tracking (loaded carries excluded - different movement pattern)

### Volume Calculation
- **WeightedWorkoutSet**: `volume = weight.kg × reps`
  - Standard volume metric for strength training
  
- **BodyweightWorkoutSet**: No volume calculation
  - Decision: Don't calculate bodyweight-only volume (would require user bodyweight history)
  - Only track RepsPR for bodyweight-only
  - Track WeightPR when additionalWeight is used
  
- **IsometricWorkoutSet**: No volume (duration-based metric)

### Personal Records
- **Reference-only approach**: PR classes only store `workoutSetId`, not cached values
  - Always retrieve actual values from the referenced WorkoutSet
  - Ensures data consistency without update logic
  - Slightly slower queries, but simpler architecture
  
- **PR types per exercise category**:
  - Bodyweight: RepsPR, WeightPR (when additionalWeight used)
  - Free Weight & Machine: WeightPR, RepsPR, VolumePR
  - Isometric: DurationPR

### Explicit Design Decisions (What we DON'T have)
- ❌ No `workoutId` grouping - derive sessions from timestamp at runtime
- ❌ No `notes` field on WorkoutSet - keep data structure minimal
- ❌ No equipment attributes on Exercise - semantic type is enough for filtering
- ❌ No bodyweight volume tracking - requires user weight history (complexity not justified)
- ❌ No loaded carries yet - different enough to warrant separate class if needed later

### Searchability & Customization
- **Exercise.description**: Enables search beyond just name matching
- **Exercise.isCustom**: Distinguishes user-created from pre-loaded exercises
- **Exercise.targetMuscles**: Array to support compound movements (squat targets legs, core, glutes)
