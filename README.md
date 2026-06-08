# 🚀 Utiler

A comprehensive **Dart/Flutter utility toolkit** — async handling, concurrency, logging, storage, networking, UI helpers, and global app configuration in one package.

```dart
import 'package:utiler/utiler.dart';
```

---

## ✨ Features

### ⏱ Async Utilities

**Debouncer** — delay rapid calls (search input, typing):

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

### ⚡ Concurrency Utilities

**BatchExecutor** — run tasks one after another:

```dart
const executor = BactchExecutor();
final results = await executor.execute([
  () async => await loadUsers(),
  () async => await loadPosts(),
]);
```

**ParallelExecutor** — run tasks at the same time:

```dart
final executor = ParallelExecutor();
final results = await executor.execute<String>([
  () async => fetchProfile(),
  () async => fetchFeed(),
  () async => fetchNotifications(),
]);
```

---

### 🧠 Core Utilities

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

---

### 💾 Database Layer

> Import: `package:utiler/src/database/database.dart`

**Database** — unified JSON + secure storage:

```dart
import 'package:utiler/src/database/database.dart';
import 'package:utiler/src/database/json_database_data.dart';
import 'package:utiler/src/database/secure_database_data.dart';

final db = Database();
await db.init(true);

await db.putJson(
  JsonDatabaseData(key: 'settings', data: {'theme': 'dark'}),
);
final settings = await db.getJson('settings');

await db.putSecure(
  SecureDatabaseData(key: 'token', value: 'secret_token'),
);
final token = await db.getSecure('token');
```

---

### 🔌 Extensions

**String**

```dart
'hello world'.toTitleCase;       // Hello World
'hello world'.toSnakeCase;       // hello_world
'123'.toIntOrNull;               // 123
'123'.toPersianDigits();         // ۱۲۳
'FF5733'.toColor;                // Color
```

**Num**

```dart
123.toPersianNumber;             // ۱۲۳
5.isBetween(1, 10);               // true
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

### 📊 Logging System

**Logger**

```dart
Logger.enabled = true;
Logger.showWidget = true;
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

### 🌐 API Service

Typed HTTP client with parser registry and `Either`-style responses.

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

### 🎨 UI Utilities

**Gaps & spacing**

```dart
Column(children: [Text('Hello'), 16.v, Text('World')]);
Row(children: [Icon(Icons.star), 8.h, Text('Rated')]);
```

**ColorfulSafearea** — colored safe area with padding control:

```dart
ColorfulSafearea(
  color: Colors.white,
  maintainBottomViewPadding: true,
  child: Scaffold(body: HomePage()),
)
```

**KeyboardDismiss** — tap outside to close keyboard:

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

### 🌍 UtilerScope

Single entry point for theme, locale, logging, and lifecycle.

**Setup**

```dart
import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

void main() {
  runApp(
    UtilerScope(
      enabledLog: true,
      exportLog: true,
      showLogWidget: true,
      themeAnimation: ValuesAnimationType.circle,
      localeAnimation: ValuesAnimationType.blurReveal,
      jsonThemesAddress: const [
        'assets/theme/light.json',
        'assets/theme/dark.json',
      ],
      jsonLocalesAddress: const [
        'assets/locale/en.json',
        'assets/locale/fa.json',
      ],
      lifecycleListener: (state) {
        debugPrint('App lifecycle: $state');
      },
      child: const MyApp(),
    ),
  );
}
```

**Change theme & locale**

```dart
context.changeAppTheme('dark');
context.changeAppLocale('en');

// Per-call animation (overrides UtilerScope default)
context.changeAppTheme('dark', ValuesAnimationType.circle);
context.changeAppLocale('fa', ValuesAnimationType.blurReveal);

// Without BuildContext
UtilerScope.changeAppTheme('dark', ValuesAnimationType.circle);
UtilerScope.changeAppLocale('en');
```

**Animation priority:** per-call `animation` → `UtilerScope` default → instant when both are `null`.

```dart
await UtilerScope.changeThemeAnimation(ValuesAnimationType.circle);
await UtilerScope.changeThemeAnimation(null); // instant
```

**Access values**

```dart
context.appJsonTheme;
context.appJsonLocale;
'home.background'.cr;  // color from JSON theme
'home.appbar'.tr;      // localized string
```

---

## 📦 Full Examples

Runnable demos for every module live in the `example/` folder:

- `example/async/` — Debouncer, Throttler, Retry
- `example/concurrency/` — Batch & parallel executors
- `example/core/` — Either, Guard, LazyValue, connectivity
- `example/database/` — JSON & secure storage
- `example/extension/` — String, num, list, map helpers
- `example/logger/` — Logger, PrettyLogger, StopwatchLogger
- `example/service/` — ApiService
- `example/ui/` — widgets and layout helpers
- `example/main.dart` — UtilerScope demo

---

## 🛠 Feature Generator (create_feature)

CLI tool to generate Clean Architecture features.

```bash
dart run utiler:create_feature -n feature_name -b -r
```

| Flag                 | Description                       |
| -------------------- | --------------------------------- |
| `-n, --name`         | Feature name (required)           |
| `-b, --use-bloc`     | Add Bloc state management         |
| `-r, --use-riverpod` | Add Riverpod dependency injection |

Generates a ready-to-use structure inside `lib/features/`.

---

## 💡 Why Utiler?

- All-in-one utility toolkit
- Reduces boilerplate code
- Improves code readability
- Clean architecture friendly
- Production-ready design for Flutter apps

---

## 📫 Contact

- LinkedIn: https://linkedin.com/in/mehrab-ghasab-a3253814a
- Telegram: https://t.me/mehrabgh1
