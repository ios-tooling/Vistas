# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Vistas is a Swift Package Manager (SPM) library that provides SwiftUI view wrappers for common iOS system UI components. The library acts as a bridge between SwiftUI and UIKit/MessageUI controllers, making it easier to present native iOS features like camera, mail composition, SMS, and web views in SwiftUI applications.

## Build Commands

This is an SPM library with no executable targets. Build and test using:

```bash
# Build the package
swift build

# Open in Xcode
open .swiftpm/xcode/package.xcworkspace
```

## Architecture

### Platform Support
- iOS 16+
- macOS 14+
- watchOS 10+
- Most components are iOS-only, wrapped in `#if os(iOS)` compiler directives

### Dependencies
- **Suite** (`https://github.com/ios-tooling/Suite`): Utility framework providing `Gestalt` for device detection
- **CrossPlatformKit** (`https://github.com/ios-tooling/CrossPlatformKit`): Provides `UXImage` and `UXViewRepresentable` type aliases for cross-platform compatibility

### Source Structure
All source code lives in `Sources/Vista/`:
- Root level: Main screen components
- `Mail Screen/`: Email composition UI with wrapper coordinator

### Core Components

#### Screen Wrappers (UIViewControllerRepresentable)
These wrap UIKit view controllers for SwiftUI:

1. **CameraScreen.swift**: Camera capture using `UIImagePickerController`
   - Provides both `CameraScreen` (convenience) and `CameraView` (representable)
   - Captures images via callback: `onImageCaptured: (UXImage) -> Void`
   - Auto-dismisses on capture or cancel

2. **TakePictureScreen.swift**: Camera or photo library picker
   - Uses `Gestalt.isOnSimulator` to automatically switch to photo library on simulator
   - Binds captured image: `@Binding var image: UIImage?`
   - Uses `@Environment(\.dismiss)` for SwiftUI-style dismissal

3. **SMSScreen.swift**: SMS composition using `MFMessageComposeViewController`
   - Takes recipients array and message body
   - Filters empty recipients automatically
   - Uses coordinator pattern for delegate handling

#### SwiftUI Representables (UXViewRepresentable)

4. **WebScreen.swift**: WKWebView wrapper with three initialization modes
   - Load by URL: `init(url: URL)`
   - Load by request: `init(request: URLRequest)`
   - Load HTML string: `init(html: String)`
   - Features URL-based caching of web views in `Coordinator.cachedWebViews`
   - Optional loading state binding and completion callback
   - Handles file URLs with proper read permissions

#### Mail Composition

5. **MailScreen.swift**: Email composition with attachment support
   - Checks if mail is available via `MFMailComposeViewController.canSendMail()`
   - Shows fallback UI when mail isn't configured
   - Supports attachments via `MailAttachment` struct (data, MIME type, filename)
   - Optional completion: `didFinish: ((Bool) -> Void)?`

6. **WrappedMailController.swift**: Internal coordinator for mail composition

#### UI Components

7. **FloatingSearchButton.swift**: Animated floating search interface
   - iOS 17+ (uses `@available` checks)
   - iOS 26+ uses new `safeAreaBar` and glass effects
   - iOS 17-25 uses overlay-based layout
   - Provides `addFloatingSearchButton()` view modifier
   - Animated expand/collapse with namespace-based transitions
   - Manages search text binding and focus state

## Patterns

### Coordinator Pattern
All UIKit wrappers use the coordinator pattern:
- Coordinator conforms to necessary UIKit delegate protocols
- Coordinator holds references to SwiftUI bindings and callbacks
- Parent view creates coordinator via `makeCoordinator()`
- Coordinator bridges UIKit delegate callbacks to SwiftUI state

### Cross-Platform Abstractions
- Use `UXImage` instead of `UIImage` or `NSImage`
- Use `UXViewRepresentable` instead of `UIViewRepresentable` or `NSViewRepresentable`
- Wrap platform-specific code in `#if os(iOS)` conditionals

### State Management
- Prefer `@Binding` for two-way data flow (image, presentation state)
- Use `@Environment(\.dismiss)` for SwiftUI-native dismissal
- Use `@FocusState` for focus management (FloatingSearchButton)
- Callbacks for one-way notifications (completion handlers)

### iOS Version Handling
- Use `@available` attributes for version-specific features
- Provide fallbacks for older iOS versions (see FloatingSearchButton)
- Target iOS 16+ as minimum, but gracefully handle newer API usage

## Development Notes

- All files follow strict iOS-only compilation with `#if os(iOS)` guards (except WebScreen and FloatingSearchButton which are more cross-platform)
- This is a pure library package with no tests or example apps in the repository
- Components are designed to be drop-in replacements for common iOS presentation patterns
- Error handling is minimal; components assume valid inputs and delegate error handling to consumers
