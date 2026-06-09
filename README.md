# Utiler

A comprehensive **Dart/Flutter utility toolkit** — async handling, concurrency, logging, storage, networking, UI helpers, and global app configuration in one package.

[![pub package](https://img.shields.io/pub/v/utiler.svg)](https://pub.dev/packages/utiler)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

```dart
import 'package:utiler/utiler.dart';
```

---

## Table of Contents

| Module                                             | What it does                                                         |
| -------------------------------------------------- | -------------------------------------------------------------------- |
| [UtilerScope](#-utilerscope--single-entry-point)   | Single entry point for theme, locale, logging, config & lifecycle    |
| [Async Utilities](#-async-utilities)               | Debouncer, Throttler, and Retry for rate-limiting and resilience     |
| [Concurrency Utilities](#-concurrency-utilities)   | Sequential and parallel task execution                               |
| [Core Utilities](#-core-utilities)                 | Either, Guard, LazyValue, connectivity, app config & feature flags   |
| [Form Validation](#-form-validation)               | Chainable, reusable validators for `TextFormField`                   |
| [Database Layer](#-database-layer)                 | Unified JSON and secure key-value storage                            |
| [API Service](#-api-service)                       | Typed HTTP client with parser registry and `Either` responses        |
| [Logging System](#-logging-system)                 | Structured logging with in-app console and file export               |
| [UI Utilities](#-ui-utilities)                     | Spacing helpers, safe area, keyboard dismiss, and responsive scaling |
| [Extensions](#-extensions)                         | String, num, list, map, and context extension methods                |
| [Feature Generator (CLI)](#-feature-generator-cli) | CLI tool to scaffold Clean Architecture features                     |

---

## 🌍 UtilerScope — Single Entry Point

`UtilerScope` is the top-level widget that wires together theme, locale, logging, feature flags, app config, and lifecycle in a single place. Wrap your `runApp` with it and everything is ready throughout your widget tree.

### Setup

```dart
import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

void main() {
  runApp(
    UtilerScope(
      // Logging
      enabledLog: true,
      exportLog: false,
      showLogWidget: false,

      // Theming
      jsonThemesAddress: const [
        'assets/theme/light.json',
        'assets/theme/dark.json',
      ],
      themeAnimation: ValuesAnimationType.circle,
      themeAnimationDuration: Duration(milliseconds: 400),

      // Localization
      jsonLocalesAddress: const [
        'assets/locale/en.json',
        'assets/locale/fa.json',
      ],
      localeAnimation: ValuesAnimationType.blurReveal,
      localeAnimationDuration: Duration(milliseconds: 400),

      // Feature flags
      featureFlags: const {
        'new_checkout': true,
        'beta_chat': false,
      },

      // Connectivity
      onConnectivityChange: (status) {
        if (status == InternetStatus.disconnected) {
          debugPrint('No internet access');
        }
      },

      // App config
      appConfig: AppConfigStore(
        active: AppEnvironment.production,
        configs: {
          AppEnvironment.development: AppConfig.fromMap(
            environment: AppEnvironment.development,
            data: {'api_base_url': 'http://localhost:8080'},
          ),
          AppEnvironment.production: AppConfig.fromMap(
            environment: AppEnvironment.production,
            data: {'api_base_url': 'https://api.example.com'},
          ),
        },
      ),

      // Lifecycle
      lifecycleListener: (state) {
        debugPrint('App lifecycle: $state');
      },

      child: const MyApp(),
    ),
  );
}
```

### Change Theme & Locale

```dart
// With BuildContext
context.changeAppTheme('dark');
context.changeAppLocale('en');

// Per-call animation override
context.changeAppTheme('dark', ValuesAnimationType.circle);
context.changeAppLocale('fa', ValuesAnimationType.blurReveal);

// Without BuildContext
Utiler.changeAppTheme('dark', ValuesAnimationType.circle);
Utiler.changeAppLocale('en');
```

**Animation priority:** per-call `animation` → `Utiler` default → instant when both are `null`.

```dart
await Utiler.changeThemeAnimation(ValuesAnimationType.circle);
await Utiler.changeThemeAnimation(null); // instant
```

### Access Values

```dart
context.appJsonTheme;
context.appJsonLocale;
'home.background'.cr;  // color from JSON theme
'home.appbar'.tr;      // localized string
```

### Access App Config

```dart
final url = Utiler.config.active.require<String>('api_base_url');
final timeout = Utiler.config.active.get<int>('timeout_seconds', fallback: 10);
```

### Access Feature Flags

```dart
if (Utiler.flags.isEnabled('new_checkout')) {
  // show new flow
}
```

---

## ⏱ Async Utilities

**Debouncer** — delay rapid calls (e.g. search input, typing):

```dart
final debouncer = Debouncer(400);

void onSearchChanged(String query) {
  debouncer(() => fetchResults(query));
}
```

**Throttler** — limit how often an action runs:

```dart
final throttler = Throttler(1000);

void onButtonTap() {
  throttler(() => submitForm());
}
```

**Retry** — retry flaky async work:

```dart
final retry = Retry();
final result = await retry.call<String>(
  () => unstableNetworkCall(),
  maxAttempts: 5,
  delayMilliseconds: 400,
);
```

---

## ⚡ Concurrency Utilities

**BatchExecutor** — run tasks sequentially:

```dart
const executor = BatchExecutor();
final results = await executor.execute([
  () async => await loadUsers(),
  () async => await loadPosts(),
]);
```

**ParallelExecutor** — run tasks concurrently:

```dart
final executor = ParallelExecutor();
final results = await executor.execute<String>([
  () async => fetchProfile(),
  () async => fetchFeed(),
  () async => fetchNotifications(),
]);
```

---

## 🧠 Core Utilities

**InternetConnectivity** — check and listen to network status:

```dart
final status = await InternetConnectivity.currentStatus;

InternetConnectivity.onStatusChange.listen((status) {
  debugPrint('Network: $status');
});
```

**Either** — functional error handling:

```dart
Either<String, int> result = Right(42);

result.fold(
  (error) => debugPrint('Error: $error'),
  (value) => debugPrint('Success: $value'),
);
```

**Guard** — safe sync execution (returns `null` on error):

```dart
final value = Guard<int>()(() => int.parse(userInput));
```

**LazyValue** — compute once, cache the result:

```dart
final lazy = LazyValue<int>(() async => heavyComputation());
final first = await lazy.value;  // computed
final second = await lazy.value; // cached
```

**LifecycleHandler** — observe app lifecycle:

```dart
LifecycleHandler(
  lifecycleListener: (state) => debugPrint('Lifecycle: $state'),
  child: const MyApp(),
)
```

**AppConfig** — typed environment configuration:

```dart
final config = AppConfig.fromMap(
  environment: AppEnvironment.production,
  data: {
    'api_base_url': 'https://api.example.com',
    'timeout_seconds': 30,
  },
);

final url = config.require<String>('api_base_url');
final timeout = config.get<int>('timeout_seconds', fallback: 10);
```

**AppConfigStore** — switch between dev/staging/prod configs:

```dart
final store = AppConfigStore(
  active: AppEnvironment.development,
  configs: {
    AppEnvironment.development: devConfig,
    AppEnvironment.production: prodConfig,
  },
);

final apiUrl = store.active.require<String>('api_base_url');
```

**FeatureFlags** — runtime feature toggles:

```dart
final flags = FeatureFlags({
  'new_checkout': true,
  'beta_chat': false,
});

if (flags.isEnabled('new_checkout')) {
  // show new flow
}
```

---

## ✅ Form Validation

**FormValidator** — chainable rules for `TextFormField`:

```dart
final error = FormValidator()
  .required()
  .email()
  .minLength(8)
  .validate('user@example.com');

TextFormField(
  validator: FormValidator()
    .required()
    .iranianPhone()
    .validate(),
)
```

---

## 💾 Database Layer

> Import: `package:utiler/src/database/database.dart`

**Database** — unified JSON + secure storage:

```dart
import 'package:utiler/src/database/database.dart';
import 'package:utiler/src/database/json_database_data.dart';
import 'package:utiler/src/database/secure_database_data.dart';

final db = Database();
await db.init(
  logging: true,
  jsonStoragePath: '/path/from/your/app',
);

// JSON storage
await db.putJson(
  JsonDatabaseData(key: 'settings', data: {'theme': 'dark'}),
);
final settings = await db.getJson('settings');

// Secure storage
await db.putSecure(
  SecureDatabaseData(key: 'token', value: 'secret_token'),
);
final token = await db.getSecure('token');
```

---

## 🌐 API Service

Typed HTTP client with a parser registry and `Either`-style responses.

```dart
import 'package:http/http.dart' as http;
import 'package:utiler/utiler.dart';

final api = ApiService<AppError>(
  client: http.Client(),
  parsers: [PostParser(), UserParser()],
  errorParser: AppErrorParser(),
  baseUrl: 'https://api.example.com',
  logging: true,
);

final response = await api.get<Post>('/posts/1');

response.result.fold(
  (error) => debugPrint(error.message),
  (post) => debugPrint(post.title),
);
```

**ApiModel + ApiParser**

```dart
class Post extends ApiModel<Post, PostParser> {
  const Post({required this.id, required this.title});
  final int id;
  final String title;

  @override
  List<Object?> get props => [id, title];
}

class PostParser extends ApiParser<Post> {
  @override
  Post fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int,
        title: json['title'] as String,
      );

  @override
  Map<String, dynamic> toJson(Post model) => {
        'id': model.id,
        'title': model.title,
      };
}
```

---

## 📊 Logging System

**Logger**

```dart
Logger.enabled = true;
Logger.showWidget = true;
Logger.exportDirectory = '/path/from/your/app';
Logger.export = true;
await Logger.i('App started', tag: 'BOOT');
```

**PrettyLogger**

```dart
await PrettyLogger.s('Saved successfully', tag: 'API');
await PrettyLogger.e('Request failed', tag: 'API');
```

**StopwatchLogger** — measure async duration:

```dart
StopwatchLogger(
  'fetch_users',
  api.get<User>('/users'),
);
```

**LoggerConsole** — in-app log viewer:

```dart
LoggerConsole(
  child: MaterialApp(home: HomePage()),
)
```

---

## 🎨 UI Utilities

**Gaps & spacing**

```dart
Column(children: [Text('Hello'), 16.v, Text('World')]);
Row(children:   [Icon(Icons.star), 8.h, Text('Rated')]);
```

**ColorfulSafeArea** — colored safe area with padding control:

```dart
ColorfulSafeArea(
  color: Colors.white,
  maintainBottomViewPadding: true,
  child: Scaffold(body: HomePage()),
)
```

**KeyboardDismiss** — tap outside to close the keyboard:

```dart
KeyboardDismiss(child: LoginForm())
```

**InkwellButton** — custom ink-well button:

```dart
InkwellButton(
  borderRadius: 12,
  onPressed: () => debugPrint('tapped'),
  child: const Text('Tap me'),
)
```

**ExpandableWidget** — animated expand/collapse:

```dart
ExpandableWidget(
  expand: isExpanded,
  child: const Text('Hidden content'),
)
```

**Responsive** — scale sizes to screen:

```dart
final width = Responsive.of(context).scale(100);
```

---

## 🔌 Extensions

**String**

```dart
'hello world'.toTitleCase;    // Hello World
'hello world'.toSnakeCase;    // hello_world
'123'.toIntOrNull;            // 123
'123'.toPersianDigits();      // ۱۲۳
'FF5733'.toColor;             // Color
```

**Num**

```dart
123.toPersianNumber;          // ۱۲۳
5.isBetween(1, 10);           // true
180.toRadians;
```

**List / Iterable / Map**

```dart
[1, 1, 2, 3].unique;
[1, 2, 3].firstOrNull;
{'a': 1}.merge({'b': 2});
```

**Context**

```dart
context.isPortrait;
context.size.width;
context.size.height;
```

---

## 🛠 Feature Generator (CLI)

Generate Clean Architecture features from the command line:

```bash
dart run utiler:create_feature -n feature_name -b -r
```

| Flag                 | Description                       |
| -------------------- | --------------------------------- |
| `-n, --name`         | Feature name _(required)_         |
| `-b, --use-bloc`     | Add Bloc state management         |
| `-r, --use-riverpod` | Add Riverpod dependency injection |

Generates a ready-to-use structure inside `lib/features/`.

---

## 📦 Examples

Runnable demos for every module live in the `example/` folder:

| Folder                 | Covers                                                          |
| ---------------------- | --------------------------------------------------------------- |
| `example/async/`       | Debouncer, Throttler, Retry                                     |
| `example/concurrency/` | Batch & parallel executors                                      |
| `example/core/`        | Either, Guard, LazyValue, connectivity, AppConfig, FeatureFlags |
| `example/validation/`  | FormValidator                                                   |
| `example/database/`    | JSON & secure storage                                           |
| `example/extension/`   | String, num, list, map helpers                                  |
| `example/logger/`      | Logger, PrettyLogger, StopwatchLogger                           |
| `example/service/`     | ApiService                                                      |
| `example/ui/`          | Widgets and layout helpers                                      |
| `example/main.dart`    | UtilerScope demo                                                |

---

## 💡 Why Utiler?

- All-in-one utility toolkit — one dependency, everything included
- Reduces boilerplate and improves code readability
- Clean Architecture friendly
- Production-ready design for Flutter apps

---

## 📫 Contact

- LinkedIn: [mehrab-ghasab](https://linkedin.com/in/mehrab-ghasab-a3253814a)
- Telegram: [@mehrabgh1](https://t.me/mehrabgh1)
