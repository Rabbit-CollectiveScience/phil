# Phil - Use Case Model

## Use Case Diagram

```
                                 Phil - Voice-First Fitness Tracker
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                     │
│                                                                                     │
│         ┌──────────────────────────────────────────────────────────────┐           │
│         │                      Core Logging                             │           │
│         │                                                                │           │
│         │  ┌─────────────────┐         ┌─────────────────┐             │           │
│         │  │  UC-01: Log     │         │  UC-02: Log     │             │           │
│    ┌────┼──│  Workout via    │◄────────│  Workout via    │◄────────────┼──┐        │
│    │    │  │  Voice          │         │  Text           │             │  │        │
│    │    │  └─────────────────┘         └─────────────────┘             │  │        │
│    │    │           │                           │                       │  │        │
│    │    │           └───────────┬───────────────┘                       │  │        │
│    │    └───────────────────────┼───────────────────────────────────────┘  │        │
│    │                            │                                           │        │
│    │                            ▼                                           │        │
│    │    ┌──────────────────────────────────────────────────────────────┐   │        │
│    │    │               Conversational AI Agent                        │   │        │
│    │    │  • Parse workout data                                        │   │        │
│    │    │  • Ask clarifying questions                                  │   │        │
│    │    │  • Handle corrections                                        │   │        │
│    │    │  • Confirm before saving                                     │   │        │
│    │    └──────────────────────────────────────────────────────────────┘   │        │
│    │                            │                                           │        │
│    │         ┌──────────────────┼──────────────────┐                        │        │
│    │         │                  │                  │                        │        │
│    │         ▼                  ▼                  ▼                        │        │
│    │  ┌────────────┐     ┌────────────┐    ┌────────────┐                 │        │
│    │  │  UC-03:    │     │  UC-04:    │    │  UC-07:    │                 │        │
│  ┌─┴──│  Reference │     │ Incremental│    │  Correct   │                 │        │
│  │    │  Previous  │     │  Logging   │    │  Parsing   │                 │        │
│  │    │  Workout   │     │ (Set-by-   │    │  Error     │                 │        │
│  │    │            │     │  Set)      │    │            │                 │        │
│  │    └────────────┘     └────────────┘    └────────────┘                 │        │
│  │                                                                          │        │
│  │                                                                          │        │
│  │         ┌──────────────────────────────────────────────────────────┐    │        │
│  │         │                 Data & Display                            │    │        │
│  │         │                                                            │    │        │
│  │         │  ┌─────────────────┐         ┌─────────────────┐         │    │        │
│  │         │  │  UC-05: View    │         │  UC-06: Multi-  │         │    │        │
│  └─────────┼──│  Dashboard &    │         │  Language       │◄────────┼────┘        │
│            │  │  History        │         │  Support        │         │             │
│            │  └─────────────────┘         └─────────────────┘         │             │
│            └──────────────────────────────────────────────────────────┘             │
│                            │                                                         │
│                            ▼                                                         │
│            ┌──────────────────────────────────────────────────────────┐             │
│            │              UC-08: First-Time Onboarding                │             │
│            │         • Welcome flow                                   │             │
│            │         • Mic permissions                                │             │
│            │         • Trial workout                                  │             │
│            └──────────────────────────────────────────────────────────┘             │
│                                                                                     │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘

                  ┌──────────┐
                  │   User   │  (Primary Actor)
                  │ Gym-Goer │
                  └──────────┘
```

---

## Use Case List

### Core Logging Use Cases

**UC-01: Log Workout via Voice**
- **Description:** User records workout details using voice input; AI transcribes, parses, and saves after confirmation
- **Trigger:** User taps voice recording button
- **Primary Flow:** Record → Transcribe → Parse → Confirm → Save
- **Success Criteria:** <30 seconds, >90% parsing accuracy

**UC-02: Log Workout via Text**
- **Description:** User types workout details as fallback when voice isn't practical
- **Trigger:** User taps text input field
- **Primary Flow:** Type → Send → Parse → Confirm → Save
- **Success Criteria:** Same parsing accuracy as voice

**UC-03: Reference Previous Workout**
- **Description:** User logs by referencing past workouts ("same as Monday")
- **Trigger:** User mentions past workout in voice/text
- **Primary Flow:** Reference → Retrieve history → Display → Confirm/Modify → Save
- **Success Criteria:** Accurate history matching, bulk logging support

**UC-04: Incremental Logging (Set-by-Set)**
- **Description:** User logs each set individually during workout
- **Trigger:** User logs single set
- **Primary Flow:** Log set 1 → Wait → Log set 2 ("same") → Aggregate → Complete
- **Success Criteria:** Context maintained between sets, "same" command works

**UC-07: Correct Parsing Error**
- **Description:** AI handles unclear voice or asks clarifying questions when data is missing/ambiguous
- **Trigger:** Transcription error or missing information
- **Primary Flow:** Parse error → Ask clarification → User corrects → Update → Confirm
- **Success Criteria:** Graceful error handling, conversational correction

---

### Viewing & Display Use Cases

**UC-05: View Dashboard & History**
- **Description:** User views today's summary, weekly stats, and workout history
- **Trigger:** User opens app
- **Primary Flow:** Display dashboard → Show today/week stats → List recent workouts
- **Success Criteria:** Quick load time, clear hierarchy

**UC-06: Multi-Language Support**
- **Description:** User logs workouts in any supported language (English, Spanish, Chinese, etc.)
- **Trigger:** User speaks/types in non-English language
- **Primary Flow:** Detect language → Transcribe → Parse → Respond in same language
- **Success Criteria:** 8+ languages supported, auto-detection works

---

### Onboarding Use Cases

**UC-08: First-Time User Onboarding**
- **Description:** New user completes welcome flow, grants permissions, tries sample workout
- **Trigger:** First app launch
- **Primary Flow:** Welcome → Request mic permission → Trial workout → Dashboard
- **Success Criteria:** <2 minutes to first log, zero barriers

---

## Supporting Actors

**System Components:**
- **Speech-to-Text Engine** (Whisper API / Google Speech)
- **Conversational AI Agent** (GPT-4 / Claude)
- **Workout Database** (stores exercises, sets, reps, weights)
- **Context Manager** (maintains workout history, patterns)

---

## Non-Functional Requirements

**Performance:**
- Voice transcription: <2 seconds
- AI parsing: <3 seconds
- Total logging: <30 seconds end-to-end

**Accuracy:**
- Speech-to-text: >95%
- Workout parsing: >90%

**Availability:**
- Offline mode with sync
- 99%+ backend uptime

**Usability:**
- One-handed operation
- Max 2 taps to log
- Voice primary, text fallback
