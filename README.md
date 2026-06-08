# 🚀 Utiler

A comprehensive **Dart/Flutter utility toolkit** that simplifies everyday development tasks — from async handling and concurrency to logging, storage, networking, UI helpers, and global app configuration.

---

## ✨ Features

### ⏱ Async Utilities

- Debouncer – Prevent rapid repeated calls (e.g., search input)
- Throttler – Limit execution rate over time
- Retry – Retry failed async operations with configurable logic

### ⚡ Concurrency Utilities

- BatchExecutor – Execute tasks in controlled batches
- ParallelExecutor – Run multiple async tasks in parallel

### 🧠 Core Utilities

- InternetConnectivity – Real-time network status detection (connected, disconnected, VPN)
- Either – Functional error handling (Left/Right pattern)
- Guard – Safe execution wrapper
- LazyValue – Lazy initialization helper
- LifecycleHandler – App lifecycle observer

### 💾 Database Layer

- Database – Unified adapter for JSON & secure storage with CRUD
- JsonDatabase – Local storage using Hive
- SecureDatabase – Secure key-value storage

### 🔌 Extensions

- Context, Iterable, List, Map, Num, and String extensions

### 📊 Logging System

- Logger – Base logging functionality
- PrettyLogger – Formatted readable logs
- LoggerConsole (UI) – In-app log viewer
- StopwatchLogger – Measure execution time

### 🌐 API Service

- ApiService – CRUD methods (GET, POST, PUT, DELETE) built on http

### 🎨 UI Utilities

- Collection of reusable widgets and helpers

### 🌍 UtilerScope (Core System)

UtilerScope is the main entry point of the package.

It wraps your entire Flutter application and provides a unified system for:

- 🌗 Theme management (light/dark or dynamic themes)
- 🌐 Locale management (internationalization)
- 📡 Lifecycle tracking
- 📊 Logging system (console + optional export)
- ⚙️ Global configuration access via context

Instead of manually managing theme, locale, and app-wide state, UtilerScope centralizes everything into a single scope.

---

## 🧩 Example Usage

```dart
import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

void main() {
  runApp(
    UtilerScope(
      lifecycleListener: (state) {
        debugPrint('App lifecycle changed: $state');
      },

      enabledLog: true,
      exportLog: true,
      showLogWidget: true,

      jsonThemesAddress: const [
        'assets/theme/light.json',
        'assets/theme/dark.json',
      ],

      jsonLocalesAddress: const [
        'assets/locale/en.json',
        'assets/locale/fa.json',
      ],

      child: const MyApp(),
    ),
  );
}
```

Once wrapped, you can access everything anywhere in your app:

```dart
context.appJsonTheme
context.appJsonLocale
context.changeAppTheme('dark')
context.changeAppLocale('en')
```

Or using the static methods on UtilerScope without a BuildContext:

```dart
UtilerScope.changeAppTheme('dark')
UtilerScope.changeAppLocale('en')
```

This design removes the need for separate state management solutions for theme, locale, or global app configuration, keeping everything centralized and easy to maintain inside a single unified scope.

---

## 📦 Examples

All features in **Utiler** include dedicated usage examples inside the `example/` folder.

Each utility has practical, ready-to-run snippets so you can quickly understand and integrate it into your project.

👉 Simply check the `example/` directory in the package source to explore them.

---

## 🛠 Feature Generator (create_feature)

CLI tool to generate Clean Architecture features.

```bash
dart run utiler:create_feature -n feature_name -b -r
```

**Arguments:**

- `-n, --name` → Feature name (required)
- `-b, --use-bloc` → Add Bloc state management
- `-r, --use-riverpod` → Add Riverpod dependency injection

Generates a ready-to-use feature structure inside `lib/features/`.

---

## 💡 Why Utiler?

- All-in-one utility toolkit
- Reduces boilerplate code
- Improves code readability
- Clean architecture friendly
- Production-ready design for Flutter apps

---

## 📫 Contact Me

If you need anything or have an offer, you can reach me at:

- LinkedIn: https://linkedin.com/in/mehrab-ghasab-a3253814a
- Telegram: https://t.me/mehrabgh1
