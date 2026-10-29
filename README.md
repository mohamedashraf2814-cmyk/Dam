# DAMSTOCK · Code Guide

Flutter (Dart) app that explains the DAMSTOCK HOMES source code file by file.

Developed by **Soft Stream**.

## Features

- All 39 project files with their purpose, grouped by layer
- Every class and function explained and linked to its line number
- Full source viewer with Dart syntax highlighting and line jump
- `main.dart` explained line by line
- Glossary of the Flutter / Dart patterns used in the project
- Built-in code assistant (works offline): ask about any file, class, function or topic and jump straight to the line
- Light and dark mode, Arabic RTL
- Runs on Android and as an installable web app (PWA)

## Run

```bash
flutter create . --org com.softstream --project-name damstock_code_guide --platforms=android,web
flutter pub get
flutter run
```

On Windows you can double-click:

- `build_android.bat` builds the APK, copies it to the Desktop and installs it on a connected phone
- `build_web.bat` builds the web version into `build/web`

## Structure

```
lib/
  main.dart                app, theme mode, loader
  theme.dart               brand colors, light and dark palettes
  data/guide.dart          guide content and lazy source loading
  data/highlight.dart      Dart syntax highlighter
  data/bot.dart            offline code assistant
  screens/home_screen.dart home: project map, flow, glossary, files
  screens/file_screen.dart explanation and code viewer
  screens/chat_sheet.dart  assistant chat
  widgets/common.dart      shared widgets
assets/
  data/guide.json          explanations, glossary, symbols
  code/                    project source files
web/                       PWA shell, manifest and icons
```
