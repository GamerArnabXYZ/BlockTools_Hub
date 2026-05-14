# BlockTools Hub 🧱

A lightweight Minecraft Utility App built with Flutter. Optimized for low-end devices and older browsers.

## Features (Placeholders)
- Seed Tools
- Skin Viewer/Editor
- Command Generator
- Player Lookup
- Server Status Viewer

## Tech Stack
- **Framework:** Flutter (Dart)
- **Web Renderer:** HTML (Explicitly set for iOS 12.5+ compatibility)
- **State Management:** Provider / setState

## Build Instructions

### Android APK
```bash
# APK build karne ke liye
flutter build apk --release
```

### Web (High Compatibility)
```bash
# HTML renderer use karna zaroori hai purane browsers ke liye
flutter build web --web-renderer html --release
```

## GitHub Actions
The project includes a `.github/workflows/build.yml` which automatically builds the APK and Web version on every push to `main`.

## Development Notes
- **Theme:** Minecraft-inspired dark UI.
- **Architecture:** Feature-based modular structure.
- **Hinglish Comments:** Code logic English mein hai, lekin comments Hinglish mein likhe gaye hain developer ki ease ke liye.
