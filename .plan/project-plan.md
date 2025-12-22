# Ticks - Timer App Planning Document

## 🎯 Core Features

### 1. **Timer Sessions (Multi-Part Timers)**
- Each session contains multiple intervals/parts
- Each interval has:
  - Duration
  - Label/name
  - Optional confirmation type (manual/automatic)
- Sessions stored persistently

### 2. **Session Management**
- Create, edit, and delete timer sessions
- Each session has:
  - Name (e.g., "HIIT Workout", "Pomodoro")
  - Icon (SF Symbol)
  - List of intervals
  - Total duration display

### 3. **Timer Execution**
- Run through intervals sequentially
- Visual and haptic feedback for interval transitions
- Manual confirmation mode: pause between intervals, wait for user tap
- Automatic mode: continuous progression
- Play/pause/stop controls

### 4. **Live Activities**
- Show current interval progress
- Display upcoming intervals
- Show overall session progress
- Dynamic Island integration

## 📐 Architecture Plan

### Data Models

```swift
// TimerSession.swift
struct TimerSession: Identifiable, Codable {
    let id: UUID
    var name: String
    var iconName: String // SF Symbol
    var intervals: [TimerInterval]
    var createdDate: Date
    
    var totalDuration: TimeInterval {
        intervals.reduce(0) { $0 + $1.duration }
    }
}

// TimerInterval.swift
struct TimerInterval: Identifiable, Codable {
    let id: UUID
    var label: String
    var duration: TimeInterval
    var confirmationType: ConfirmationType
    
    enum ConfirmationType: String, Codable {
        case automatic
        case manual
    }
}

// TimerState.swift
enum TimerState {
    case idle
    case running
    case paused
    case waitingForConfirmation
    case completed
}
```

### ViewModels

```swift
// SessionStore.swift - Manages all timer sessions
@Observable
class SessionStore {
    var sessions: [TimerSession] = []
    
    // CRUD operations
    func addSession(_ session: TimerSession)
    func updateSession(_ session: TimerSession)
    func deleteSession(id: UUID)
    
    // Persistence with SwiftData or JSON
}

// TimerViewModel.swift - Manages active timer execution
@Observable
class TimerViewModel {
    var currentSession: TimerSession?
    var currentIntervalIndex: Int = 0
    var timeRemaining: TimeInterval = 0
    var state: TimerState = .idle
    
    func start()
    func pause()
    func resume()
    func stop()
    func nextInterval()
    func confirmAndContinue()
}
```

### View Structure

```
ContentView (Sessions List)
├── SessionCard (Reusable card component)
├── AddSessionButton
└── NavigationStack

TimerRunningView (Active timer)
├── CircularProgressView
├── CurrentIntervalInfo
├── UpcomingIntervalsList
└── ControlButtons

SessionEditorView (Create/Edit)
├── SessionNameField
├── IconPicker
├── IntervalsList
│   └── IntervalRow (editable)
└── AddIntervalButton

LiveActivityView (Lock Screen/Dynamic Island)
├── CompactView (Dynamic Island)
├── MinimalView (Lock Screen minimal)
└── ExpandedView (Lock Screen expanded)
```

## 🎨 Design System (Based on Image)

### Visual Style
- **Background**: Light gray/off-white (`Color(.systemGroupedBackground)`)
- **Cards**: White with subtle shadows and rounded corners
- **Icons**: Black rounded square backgrounds with white SF Symbols
- **Typography**: 
  - Header: Large, bold ("Sessions")
  - Section label: Small, uppercase, gray ("YOUR TIMERS")
  - Session names: Large, regular weight
  - Interval count: Medium, gray
- **Buttons**: 
  - Primary: Black with white text, fully rounded
  - Secondary: Light gray icons (edit/delete)

### Component Styling
```swift
// Card modifier
.background(Color.white)
.cornerRadius(20)
.shadow(color: .black.opacity(0.05), radius: 10, y: 2)

// Icon container
.frame(width: 64, height: 64)
.background(Color.black)
.cornerRadius(16)

// Start button
.frame(maxWidth: .infinity)
.padding()
.background(Color.black)
.foregroundColor(.white)
.cornerRadius(16)
```

## 🔧 Technical Implementation

### Persistence
Use **SwiftData** for modern, type-safe persistence:
```swift
@Model
class TimerSession {
    // SwiftData automatically handles persistence
}
```

### Live Activities
Use **ActivityKit** framework:
```swift
import ActivityKit

struct TimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var currentInterval: String
        var progress: Double
        var timeRemaining: TimeInterval
    }
    
    var sessionName: String
    var totalIntervals: Int
}
```

### Timer Implementation
Use **Timer** with Combine or async/await:
```swift
private var timer: Timer?

func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
        self.tick()
    }
}
```

### Haptics & Notifications
```swift
// Haptic feedback
let generator = UINotificationFeedbackGenerator()
generator.notificationOccurred(.success)

// Local notifications for background
import UserNotifications
```

## 📱 Screen Flow

1. **Launch** → Sessions List (ContentView)
2. **Tap "+"** → Session Editor (create new)
3. **Tap Session Card** → Edit Session
4. **Tap "Start"** → Timer Running View
5. **Timer Completes** → Celebration/Summary → Back to List

## 🎯 MVP Features Priority

### Phase 1 (MVP)
- ✅ Create/edit/delete sessions
- ✅ Add/edit/delete intervals
- ✅ Run timer with countdown
- ✅ Basic UI matching design
- ✅ Persistence with SwiftData

### Phase 2
- ✅ Live Activities
- ✅ Manual/automatic confirmation modes
- ✅ Haptic feedback
- ✅ Sound alerts

### Phase 3
- ✅ iCloud sync
- ✅ Widgets
- ✅ Complications (watchOS)
- ✅ Session templates

## 📂 File Structure

```
Ticks/
├── App/
│   ├── TicksApp.swift
│   └── ContentView.swift
├── Models/
│   ├── TimerSession.swift
│   ├── TimerInterval.swift
│   └── TimerState.swift
├── ViewModels/
│   ├── SessionStore.swift
│   └── TimerViewModel.swift
├── Views/
│   ├── Sessions/
│   │   ├── SessionListView.swift
│   │   ├── SessionCard.swift
│   │   └── SessionEditorView.swift
│   ├── Timer/
│   │   ├── TimerRunningView.swift
│   │   ├── CircularProgressView.swift
│   │   └── IntervalListView.swift
│   └── Components/
│       ├── IntervalRow.swift
│       └── IconPicker.swift
├── LiveActivities/
│   └── TimerLiveActivity.swift
└── Utilities/
    ├── HapticManager.swift
    ├── NotificationManager.swift
    └── Extensions/
        ├── TimeInterval+Format.swift
        └── View+CardStyle.swift
```

## 🚀 Implementation Steps

### Step 1: Project Setup
1. Create folder structure
2. Set up SwiftData model container
3. Configure Live Activities entitlements

### Step 2: Data Layer
1. Implement TimerSession model
2. Implement TimerInterval model
3. Create SessionStore with persistence

### Step 3: UI - Session List
1. Build SessionListView matching design
2. Create SessionCard component
3. Add create/edit/delete functionality

### Step 4: UI - Timer Running
1. Build TimerRunningView
2. Implement CircularProgressView
3. Add timer controls (play/pause/stop)

### Step 5: Timer Logic
1. Implement TimerViewModel
2. Add interval progression logic
3. Implement confirmation modes

### Step 6: Polish
1. Add haptic feedback
2. Add sound alerts
3. Implement Live Activities
4. Test and refine

---

**Created**: December 21, 2025
**Last Updated**: December 21, 2025
