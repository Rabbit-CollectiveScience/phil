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
    
    class AssistedMachineExercise {
    }
    
    class IsometricExercise {
        +bool isBodyweightBased
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
    StrengthExercise <|-- AssistedMachineExercise
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
    
    class AssistedMachineWorkoutSet {
        +Weight assistanceWeight
        +int reps
        +getEffectiveWeight(userBodyweight) userBodyweight.kg - assistanceWeight.kg
        +getVolume() null
    }
    
    class IsometricWorkoutSet {
        +Duration? duration
        +Weight? weight
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
    WorkoutSet <|-- AssistedMachineWorkoutSet
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
    AssistedMachineExercise "1" --> "*" AssistedMachineWorkoutSet : records
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
    AssistedMachineWorkoutSet "1" --> "0..*" WeightPR : achieves (lowest assistance)
    AssistedMachineWorkoutSet "1" --> "0..*" RepsPR : achieves
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
        +getInMiles()
  AssistedMachineExercise → AssistedMachineWorkoutSet (tracks assistance weight + reps, inverted progress)
-   }
```

## Key Relationships

**Exercise → WorkoutSet (strict typing):**

*Strength Training:*
- BodyweightExercise → BodyweightWorkoutSet (tracks reps + optional additionalWeight)
- MachineExercise → WeightedWorkoutSet (tracks weight + reps)
- AssistedMachineExercise → AssistedMachineWorkoutSet (tracks assistance weight + reps, inverted progres best), RepsPR
- MachineExercise → WeightedWorkoutSet (tracks weight + reps)
- IsometricExercise → IsometricWorkoutSet (tracks optional duration + optional weight)

*Cardio:*
- DistanceCardioExercise → DistanceCardioWorkoutSet (tracks duration + distance, calculates pace)
- DurationCardioExercise → DurationCardioWorkoutSet (tracks duration only)

**WorkoutSet → PersonalRecord (by metrics):**

*Strength Training:*
- BodyweightWorkoutSet → RepsPR, WeightPR (if additionalWeight used)
- WeightedWorkoutSet → WeightPR, RepsPR, VolumePR
- IsometricWorkoutSet → DurationPR

*Cardio:*
- DistanceCardioWorkoutSet → DurationPR (for specific distance), DistancePR (longest distance), PacePR (best average pace)
- DurationCardioWorkoutSet → DurationPR (longest duration)

## Design Principles - Strength Training

### Core Architecture
- **Type Safety**: Each concept has a concrete type (no flexible Map<String, dynamic>)
- **Strict Mappings**: Each Exercise type maps to exactly one WorkoutSet type
- **Separation of Concerns**: 
  - Exercise = Definition/Template (what the exercise is)
  - Traditional resistance machines where more weight = harder
  PersonalRecord = Achievement (your best performance)

### Exercise Classification
- **BodyweightExercise**: Pure bodyweight movements (push-ups, pull-ups, dips)
  - Can optionally add weight (weighted pull-ups, weighted dips)
  - Separated from weighted exercises for semantic clarity and filtering
  
- **FreeWeightExercise**: Barbells, dumbbells, kettlebells
  - Free-path movements requiring stabilization
  
- **MachineExercise**: Fixed-path equipment (smith machine, leg press, cables, resistance bands)
  - Guided movements, includes resistance bands

- **AssistedMachineWorkoutSet**: No volume calculation
  - `assistanceWeight` represents counterbalance force reducing effective load
  - **Inverted comparison logic**: Lower assistance weight = better performance
  - `getEffectiveWeight(userBodyweight)` calculates actual resistance (optional, requires user weight)
  - PRs compare assistance weight in reverse (minimum assistance = maximum PR)
  - Example progression: 60kg assist → 50kg assist → 40kg assist (each is a PR)
  
  - Traditional resistance machines where more weight = harder
  
- **AssistedMachineExercise**: Counterbalance machines that reduce effective bodyweight (assisted pull-ups, assisted dips)
  - Weight represents assistance provided by the machine
  - **Inverted progress metric**: Lower assistance weight = better (getting stronger)
  - Effective resistance = bodyweight - assistance weight
  - Example: 80kg person using 30kg assistance = effectively lifting 50kg
  - Progress: 40kg assist → 30kg assist → 20kg assist → unassisted
      - Weight represents total load being held
  - Duration tracking for hold time (optional - user may not track time)
  - Optional weight for weighted holds (weight belt, vest, plates, dumbbells)
  - Examples: bodyweight dead hang (duration only), weighted plank (duration + weight), casual logging (neither tracked)

### Volume Calculation
- **WeightedWorkoutSet**: `volume = weight.kg × reps`
  - Assisted Machine: WeightPR (lowest assistance), RepsPR
    - **WeightPR logic is inverted**: Tracks the minimum assistance weight used (best = least help)
    - Display: "PR: 20kg assistance" means you needed only 20kg help (better than 30kg assistance)
    - Can track RepsPR at specific assistance levels independently
  - Standard volume metric for strength training
  
- **BodyweightWorkoutSet**: No volume calculation
  - IsometricWorkoutSet**: No volume (duration-based metric)
  - Both duration and weight are optional (flexible logging)
  - Allows tracking: time only, weight only, both, or neither
  - No traditional volume calculation (time under tension is different metric)

### Personal Records
- **Reference-only approach**: PR classes only store `workoutSetId`, not cached values
  - Always retrieve actual values from the referenced WorkoutSet
  - Ensures data consistency without update logic
  - Slightly slower queries, but simpler architecture
  
- **PR types per exercise category**:
  - Bodyweight: RepsPR, WeightPR (when additionalWeight used)
  - Free Weight & Machine: WeightPR, RepsPR, VolumePR
  - Isometric: DurationPR (only when duration tracked; weight is informative but doesn't create separate PR)

## Design Principles - Cardio

### Core Architecture
- **Same foundational principles as strength training**: Type safety, strict mappings, separation of concerns
- **Classification by metrics tracked**: DistanceCardio vs DurationCardio based on whether distance is meaningful

### Exercise Classification
- **DistanceCardioExercise**: Activities where distance tracking is meaningful (running, cycling, rowing, swimming)
  - Records both duration and distance
  - Assisted Machine: WeightPR (lowest assistance), RepsPR
    - **WeightPR logic is inverted**: Tracks the minimum assistance weight used (best = least help)
    - Display: "PR: 20kg assistance" means you needed only 20kg help (better than 30kg assistance)
    - Can track RepsPR at specific assistance levels independently
  - Pace calculated at runtime from these values
  - Suitable for machines/activities with distance measurement
  
- **DurationCardioExercise**: Activities where only duration matters (elliptical, stair climber, battle ropes)
  - Duration-only tracking for equipment without meaningful distance metrics
  - Simpler data structure for non-distance-based conditioning

### Activity Intensity Variations
- **Separate exercises for intensity levels**: Walking vs Running are distinct exercises
  - Each has its own PR tracking (fastest 5K run, longest walk)
  - User creates exercise names that reflect their use case
  - Classification is by data structure needed, not by heart rate/intensity

### Personal Records
- **DistanceCardio PRs**:
  - DurationPR: Fastest time for specific distance (e.g., fastest 5K)
  - DistancePR: Longest distance achieved (useful for endurance tracking)
  - PacePR: Best average pace across any session
  
- **DurationCardio PRs**:
  - DurationPR: Longest session duration

### Explicit Design Decisions (What we DON'T have)
- ❌ No heart rate tracking - out of scope for weightlifter-focused app
- ❌ No interval detail tracking - HIIT/interval training recorded as one combined session
  - 10x(400m sprint + 200m jog) = one 6km, 30min session
  - Prioritizes simplicity over granular interval analysis
- ❌ No split times - no lap tracking or kilometer splits
- ❌ No elevation/incline tracking - flat assumption
- ❌ No activity-specific enums - use exercise name to distinguish running from cycling

### Pace Calculation
- **Distance.meters / Duration.seconds** = meters per second (stored format)
- Display conversions: min/km, min/mile, km/h, mph calculated at runtime
- Pace is derived metric, not stored directly

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
