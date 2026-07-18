# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

`Money Laundering` is an iOS app built with SwiftUI. The project is a freshly generated Xcode template — `ContentView.swift` and `Money_LaunderingApp.swift` currently contain only the default SwiftUI starter code ("Hello, world!" view). There is no custom logic, networking, or data layer yet.

- Bundle identifier: `com.andrew4coding.moneylaundering.Money-Laundering`
- Deployment target: iOS 26.5
- Swift version: 5.0
- UI framework: SwiftUI, app entry point via the `@main` `App` protocol (`Money_LaunderingApp.swift`)

## Architecture

- `Money Laundering/Money_LaunderingApp.swift` — app entry point (`@main` struct conforming to `App`), defines the root `WindowGroup` scene.
- `Money Laundering/ContentView.swift` — root view shown in the window group.
- `Money Laundering/Assets.xcassets` — app icon and color assets.
- `Money Laundering.xcodeproj` — single Xcode project with one app target ("Money Laundering"); no SwiftPM packages or additional targets are configured yet.

As the app grows, prefer keeping this single-target structure unless a clear need for modularization (e.g. a separate framework target) emerges.

## Common commands

Build and test via `xcodebuild` (no Package.swift/SwiftPM CLI workflow — this is a plain Xcode project):

```bash
# Build for the iOS Simulator
xcodebuild -project "Money Laundering.xcodeproj" -scheme "Money Laundering" -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests (once a test target exists)
xcodebuild -project "Money Laundering.xcodeproj" -scheme "Money Laundering" -destination 'platform=iOS Simulator,name=iPhone 16' test

# List available schemes/destinations
xcodebuild -list -project "Money Laundering.xcodeproj"
xcrun simctl list devices available
```

There are no test targets in the project yet, so `xcodebuild test` will fail until one is added.
