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
- InternetConnectivity – A reactive utility that detects real-time network status including connected, disconnected, and VPN states with stream-based listeners and current status check.
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

---

## 💡 Why Utiler?

- All-in-one utility toolkit
- Reduces boilerplate code
- Improves code readability and maintainability
- Clean and scalable structure
- Designed for real-world Flutter applications

---