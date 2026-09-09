# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

`Swiftlet` is an iOS app built with SwiftUI. The project is a freshly generated Xcode template — `ContentView.swift` and `SwiftletApp.swift` currently contain only the default SwiftUI starter code ("Hello, world!" view). There is no custom logic, networking, or data layer yet.

- Bundle identifier: `com.andrew4coding.swiftlet.Swiftlet`
- Deployment target: iOS 26.5
- Swift version: 5.0
- UI framework: SwiftUI, app entry point via the `@main` `App` protocol (`SwiftletApp.swift`)

## Architecture

- `Swiftlet/SwiftletApp.swift` — app entry point (`@main` struct conforming to `App`), defines the root `WindowGroup` scene.
- `Swiftlet/ContentView.swift` — root view shown in the window group.
- `Swiftlet/Assets.xcassets` — app icon and color assets.
- `Swiftlet.xcodeproj` — single Xcode project with one app target ("Swiftlet"); no SwiftPM packages or additional targets are configured yet.

As the app grows, prefer keeping this single-target structure unless a clear need for modularization (e.g. a separate framework target) emerges.

## Common commands

Build and test via `xcodebuild` (no Package.swift/SwiftPM CLI workflow — this is a plain Xcode project):

```bash
# Build for the iOS Simulator
xcodebuild -project "Swiftlet.xcodeproj" -scheme "Swiftlet" -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests (once a test target exists)
xcodebuild -project "Swiftlet.xcodeproj" -scheme "Swiftlet" -destination 'platform=iOS Simulator,name=iPhone 16' test

# List available schemes/destinations
xcodebuild -list -project "Swiftlet.xcodeproj"
xcrun simctl list devices available
```

There are no test targets in the project yet, so `xcodebuild test` will fail until one is added.
