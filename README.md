# Ticks ⏱️

A iOS timer app for creating custom timer sessions.

<table>                                                                                                                
  <tr>                                                                                                                 
    <td><img src="YOUR-IMAGE-URL-HERE" alt="Session List" width="250"/></td>                                           
    <td><img src="YOUR-IMAGE-URL-HERE" alt="Timer Running" width="250"/></td>                                          
    <td><img src="YOUR-IMAGE-URL-HERE" alt="Live Activity" width="250"/></td>                                          
  </tr>                                                                                                                
  <tr>                                                                                                                 
    <td align="center"><em>Session List</em></td>                                                                      
    <td align="center"><em>Active Timer</em></td>                                                                      
    <td align="center"><em>Live Activity</em></td>                                                                     
  </tr>                                                                                                                
</table>

## Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## How to Use

1. **Create a Timer Session**
   - Tap the "+" button to create a new session
   - Give it a name and choose an icon
   - Add intervals with durations and labels
   - Choose automatic or manual confirmation for each interval

2. **Run a Timer**
   - Tap on a session card to start the timer
   - Use play/pause controls to manage execution
   - Tap "Continue" when manual confirmation is required
   - View progress for current interval and overall session

3. **Live Activities**
   - Live Activities automatically start when you run a timer
   - View progress from the Lock Screen
   - Monitor countdown from the Dynamic Island
   - Swipe to dismiss when timer completes

## Running the App

### From Xcode
```bash
# Build and run on simulator
xcodebuild -scheme Ticks -project Ticks.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

### Running Tests
```bash
# Run all tests
xcodebuild test -scheme Ticks -project Ticks.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Project Structure

```
Ticks/
├── Ticks/                      # Main app target
│   ├── models/                 # SwiftData models
│   ├── views/                  # SwiftUI views
│   ├── Utilities/             # Helpers and managers
│   └── TicksApp.swift         # App entry point
├── TicksWidgets/              # Widget extension
├── Shared/                    # Shared code
├── TicksTests/                # Unit tests
└── TicksUITests/              # UI tests
```

## Author
Jing Lei (@jlei)
