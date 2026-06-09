## 1.3.0

### Added

- `AppConfig`, `AppConfigStore`, `FeatureFlags`, and `FormValidator`.

### Changed

- Removed `path_provider` dependency — host apps pass storage paths for JSON DB and log export.
- `JsonDatabase.init` and `Database.init` require `jsonStoragePath` from the caller.
- `Logger.exportDirectory` must be set by the host app when `Logger.export` is enabled.
- `UtilerScope` adds optional `logExportDirectory`.

### Fixed

- Web support: conditional IO for logger file export, internet lookup, and API file upload/download.

## 1.2.0

### Fixed

- `ExpandableWidget` uses `ClipRect` + `Align` instead of deprecated `SizeTransition.axisAlignment`

## 1.2.1

### Fixed

- `ExpandableWidget` uses `axisAlignment` on `SizeTransition` again for compatibility with Flutter **&lt; 3.41** (e.g. 3.32).
- Minimum Flutter constraint restored to `>=1.17.0`.

## 1.1.0

### Added

- `ValuesAnimationType` enum with fade, slide, scale, zoom, blur, circle, and box transitions for theme/locale changes.
- Optional per-call `animation` parameter on `changeAppTheme` and `changeAppLocale`.
- `changeThemeAnimation` / `changeLocaleAnimation` on `UtilerScope` to persist default transition styles.
- Typed API service layer: `ApiService`, `ApiParser`, `ApiModel`, `ParserRegistry`, `ApiResponse`, and `ApiError` parsing.
- Comprehensive DartDoc with `@example` blocks across the public API.
- Tested with Flutter **3.44.1** (Dart **3.12**).

### Changed

- Developed with Flutter **3.44.1**; minimum SDK Dart `^3.8.1`.
- Theme/locale animation priority: per-call `animation` → `UtilerScope` default → instant when both are `null`.
- `themeAnimation` and `localeAnimation` on `UtilerScope` are nullable (no animation by default).
- Replaced clipper-based transitions with enum-driven `ValuesTransitionBuilder`.

## 1.0.2

### Fixed

- Add animation to change locale and theme

### Added

- `example/` folder demonstrating usage of all package features.

### Changed

- `ThemeScope.changeAppTheme` forwards `withAnimation` consistently.

## 1.0.1

### Changed

- Added DartDoc comments to core utility classes for better documentation and pub.dev readability.

## 1.0.0

## ✨ Features

### ⏱ Async Utilities

- Debouncer – Prevent rapid repeated calls (e.g., search input)
- Throttler – Limit execution rate over time
- Retry – Retry failed async operations with configurable logic

### ⚡ Concurrency Utilities

- BatchExecutor – Execute tasks in controlled batches
- ParallelExecutor – Run multiple async tasks in parallel

### 🧠 Core Utilities

- Either – Functional error handling (Left/Right pattern)
- Guard – Safe execution wrapper for error handling
- LazyValue – Lazy initialization helper
- LifecycleHandler – App lifecycle observer

### 💾 Database Layer

- Database – Unified adapter for JSON & secure storage with CRUD support
- JsonDatabase – Local storage using Hive
- SecureDatabase – Secure key-value storage

### 🔌 Extensions

- Context, Iterable, List, Map, Num, and String extensions

### 📊 Logging System

- Logger – Base logging functionality
- PrettyLogger – Formatted and readable logs
- LoggerConsole (UI) – In-app log viewer
- StopwatchLogger – Measure execution time

### 🌐 API Service

- ApiService – CRUD methods (GET, POST, PUT, DELETE) built on top of `http`

### 🎨 UI Utilities

- Collection of reusable and practical widgets

### 🌍 Values & Scopes

- ValuesScope – Global wrapper for locale and theme
- LocaleScope – Localization handler
- ThemeScope – Theme management

### 🧩 Utiler Scope

- UtilerScope – Single entry point to access and manage all utilities

## 🛠 Feature Generator (create_feature)

Includes a CLI tool to quickly generate a **Clean Architecture feature structure**.

### 🚀 Usage

Run the following command:

```bash
dart run create_feature.dart -n feature_name
```
