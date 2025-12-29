# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Ticks** is a SwiftUI-based iOS timer app for creating and running multi-interval timer sessions (e.g., HIIT workouts, Pomodoro sessions). It features Live Activities, widgets, haptic feedback, and background execution capabilities.

## Build & Development Commands

### Building and Running
```bash
# Build the main app
xcodebuild -scheme Ticks -project Ticks.xcodeproj build

# Run tests
xcodebuild test -scheme Ticks -project Ticks.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 15'

# Build widget extension
xcodebuild -scheme TicksWidgetsExtension -project Ticks.xcodeproj build
```

### Linting
The project uses SwiftLint. To run:
```bash
swiftlint
```

Note: SwiftLint violations are tracked in commits (see fix: swiftlint commit).

## Architecture Overview

### Data Layer - SwiftData Models
The app uses SwiftData for persistence with two main models:

- **TimerSession** (`Ticks/models/TimerSession.swift`) - Represents a timer template with name, icon, and intervals
  - Uses `@Model` for SwiftData persistence
  - Has one-to-many relationship with TimerInterval (cascade delete)
  - Provides `sortedIntervals` computed property using `orderIndex`

- **TimerInterval** (`Ticks/models/TimerInterval.swift`) - Individual interval within a session
  - Stores duration, label, and confirmation type (automatic/manual)
  - Uses `orderIndex` for ordering within a session
  - Belongs to a TimerSession via inverse relationship

**Important**: The ModelContainer is initialized in TicksApp.swift:12-21 and must include both TimerSession and TimerInterval.

### Timer Execution - TimerViewModel
`Ticks/views/timer/TimerViewModel.swift` is the core state manager for running timers:

- **States**: idle, running, paused, waitingForConfirmation, completed
- **Background handling**: Uses silent audio playback to keep timer running when app is backgrounded
- **Live Activities**: Manages ActivityKit integration for Dynamic Island and Lock Screen
- **Haptics & Notifications**: Coordinates with HapticManager and NotificationManager

Key methods:
- `start(session:)` - Begins timer execution
- `nextInterval()` - Advances to next interval (respects confirmation type)
- `handleAppWentToBackground()` / `handleAppBecameActive()` - Syncs timer state across app lifecycle

### Live Activities Integration
The app uses ActivityKit for Live Activities:

- **Shared/TimerActivityAttributes.swift** - Defines activity attributes and content state
- Activity updates every 1 second while timer is running
- Shows current interval, progress, and next interval preview
- Implements in both main app (TimerViewModel.swift) and widget extension (TicksWidgets/)

### Utilities & Managers
Singleton managers handle cross-cutting concerns:

- **HapticManager** - Provides haptic feedback for interval events
- **NotificationManager** - Schedules notifications for background intervals
- **BackgroundAudioManager** - Plays silent audio to keep timer alive in background

### View Architecture
```
SessionListView (root)
├── SessionCard (displays session with intervals)
└── SessionEditorView (create/edit sessions)
    ├── IconPicker
    └── IntervalRow (editable interval)

TimerRunningView (active timer)
├── CircularProgressView (visual countdown)
└── TimerViewModel (state management)
```

## Key Design Patterns

1. **SwiftData Relationships**: TimerSession has cascade delete on intervals, ensuring data integrity
2. **Observable Pattern**: TimerViewModel uses `@Observable` macro for reactive state updates
3. **Singleton Services**: Managers (Haptic, Notification, BackgroundAudio) use shared instances
4. **Order Preservation**: Intervals use `orderIndex` rather than array position for stable ordering
5. **Confirmation Types**: Intervals can be automatic (continuous) or manual (wait for user tap)

## Important Implementation Notes

### Working with SwiftData Models
- Both TimerSession and TimerInterval must be registered in the ModelContainer
- Use `sortedIntervals` property instead of raw `intervals` array to respect orderIndex
- When creating new intervals, assign sequential orderIndex values
- The `@Relationship` with `deleteRule: .cascade` ensures intervals are deleted with their session

### Background Timer Execution
The timer continues running in the background using:
1. Silent audio playback (BackgroundAudioManager)
2. Backup notifications scheduled for each interval
3. Time synchronization when app returns to foreground (see `updateTimerAfterBackground`)

### Live Activities
- Check `ActivityAuthorizationInfo().areActivitiesEnabled` before starting activities
- Update frequency is 1 second for smooth countdown display
- Always end activity when timer stops/completes

### Haptic Feedback
Different haptic types for different events:
- Heavy impact: interval completed
- Medium impact: interval started
- Warning notification: confirmation needed
- Success notification: session completed

## Project Structure

```
Ticks/                      # Main app target
├── models/                 # SwiftData models
├── views/                  # SwiftUI views
│   ├── timer/             # Timer execution UI
│   ├── session/           # Session management UI
│   └── components/        # Reusable components
├── Utilities/             # Singleton managers and extensions
└── TicksApp.swift         # App entry point

TicksWidgets/              # Widget extension target
├── TicksWidgets.swift     # Widget definitions
└── TimerLiveActivity.swift # Live Activity views

Shared/                    # Code shared between targets
└── TimerActivityAttributes.swift

TicksTests/                # Unit tests
TicksUITests/              # UI tests
```

## Testing
The project uses Swift Testing framework (not XCTest). Tests use the `@Test` attribute and `#expect` assertions.

To run a specific test:
```bash
xcodebuild test -scheme Ticks -only-testing:TicksTests/TicksTests/example
```

## Development Phases
The project was developed in phases (see .plan/ directory):
- Phase 1: Core session management and timer execution
- Phase 2: Live Activities, haptics, background execution
- Phase 3: Planned features (iCloud sync, complications, templates)
