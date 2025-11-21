# Phil - Voice-First Fitness Tracker

## Vision
Fitness tracking without the friction. Log workouts through natural conversation - just talk, we'll handle the rest.

---

## User Experience Flow

```
┌─────────────────┐
│  User at Gym    │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  [Voice Button] "3 sets bench at 185"   │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  AI: "Got it - Bench Press 3×? @ 185"   │
│  "How many reps?"                        │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  User: "10"                              │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  AI: "Logged! 3×10 @ 185lbs 💪"         │
│  "5lbs more than last week"              │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│         Dashboard Updated                │
│  • Today: 1 exercise, 30 reps            │
│  • Week: 4 workouts, 12 exercises        │
└──────────────────────────────────────────┘
```

---

## MVP Features

### 1. Voice/Text Input
**Primary Interface**
- Large voice recording button (center of home screen)
- Press & hold or tap to start/stop
- Real-time visual feedback (waveform animation)
- Fallback: Manual text input option
- **Multi-language support** (English, Spanish, Chinese, etc. - all major languages)

**Example Screen:**
```
┌─────────────────────────┐
│   Today: 2 exercises     │
├─────────────────────────┤
│                          │
│         ⭕ ← 🎤          │
│    [Hold to Record]      │
│                          │
│   or type below ↓        │
│  [____________]          │
│                          │
└─────────────────────────┘
```

---

### 2. Conversational AI Agent
**Multi-turn dialogue for workout logging**

- Parses voice/text into structured workout data
- Asks clarifying questions when needed
- Confirms understanding before saving
- Handles corrections naturally

**Conversation Examples:**
```
User: "Benched 185 for 3 sets"
AI:   "Got it - 3 sets of bench press at 185lbs. How many reps?"

User: "Actually it was 8 reps, not 10"  
AI:   "Updated to 3×8 @ 185lbs ✓"

User: "Same for incline"
AI:   "Incline bench - 3×8 @ 185lbs. Correct?"

User: "Yep"
AI:   "Done! 2 exercises logged 🎯"
```

**Extracts:**
- Exercise name
- Sets
- Reps  
- Weight
- Notes (optional)

---

### 3. Context Awareness
**Remembers your workout history**

- "Same as last Monday" → auto-fills entire workout
- "10 pounds more" → references last session
- "Usual chest day" → suggests routine
- Smart autocomplete for exercise names

**Example:**
```
User: "Same as Monday"
AI:   "Got it - your Monday workout:
       • Bench press 3×10 @ 185
       • Incline press 3×10 @ 135
       • Dips 3×12 bodyweight
       Sound good?"
```

---

### 4. Dashboard
**Single unified view**

```
┌──────────────────────────────────┐
│  📅 Today - Nov 18               │
│  2 exercises · 60 total reps      │
│  ────────────────────────────────│
│  💪 This Week                     │
│  4 workouts · 🔥 4 day streak    │
│  12 exercises · 1,240 total lbs   │
│  ────────────────────────────────│
│  📊 Recent Workouts               │
│  ────────────────────────────────│
│  Nov 18 - Chest                   │
│    Bench Press 3×10 @ 185         │
│    Incline Press 3×8 @ 135        │
│  ────────────────────────────────│
│  Nov 17 - Back                    │
│    Deadlift 5×5 @ 225             │
│    Rows 3×12 @ 135                │
│  ────────────────────────────────│
│  Nov 16 - Legs                    │
│    Squat 4×8 @ 185                │
│    ...                            │
└──────────────────────────────────┘
```

**Shows:**
- Today's summary
- Weekly stats (workouts, streak, volume)
- Chronological workout history
- Search/filter by date or exercise

---

### 5. Device-Based Authentication
**Frictionless first use**

- Auto-login with device ID (guest mode)
- Zero barriers to start logging
- Optional account creation for:
  - Multi-device sync
  - Data backup
  - Cross-platform access

**Flow:**
```
First Launch → Immediate access (device ID)
              ↓
         Start logging
              ↓
    (Optional) Create account later
```

---

## Technical Stack

**Frontend (Flutter)**
- Voice recording & playback
- Speech-to-text integration
- Real-time UI updates
- Offline-first architecture

**Backend (Next.js API)**
- LLM integration (GPT-4/Claude) for parsing
- Workout data storage & retrieval
- Context management
- Device authentication

**AI/ML**
- Speech-to-text: Whisper API / Google Speech
- NLP parsing: OpenAI GPT-4 or Anthropic Claude
- Context retention across conversations

---

## Explicitly OUT of MVP

- ❌ Progress charts/graphs (dashboard shows text stats only)
- ❌ Cardio/yoga/other workout types (strength training only)
- ❌ Nutrition tracking
- ❌ Photo/video uploads
- ❌ Social features/sharing
- ❌ Workout routine templates
- ❌ Rest timers
- ❌ Exercise form videos
- ❌ PR tracking/celebrations
- ❌ Data export

---

## Success Metrics

**MVP validates if:**
1. Users can log a workout in <30 seconds via voice
2. AI parsing accuracy >90% on first try
3. Users prefer this over traditional form-based apps
4. 3+ consecutive workouts logged per user (retention)

---

## Open Questions

1. **AI Personality:** Functional & minimal vs. motivational & chatty?
2. **Confirmation Required:** Always confirm before saving, or trust AI with background corrections?
3. **Voice Privacy:** Process locally or server-side?
4. **Offline Mode:** Essential for MVP or can wait?
