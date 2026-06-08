import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

void main() {
  runApp(
    UtilerScope(
      /// ------------------------------------------------------------
      /// App lifecycle listener (optional)
      /// ------------------------------------------------------------
      lifecycleListener: (state) {
        debugPrint('App lifecycle changed: $state');
      },

      /// ------------------------------------------------------------
      /// Logging configuration
      /// ------------------------------------------------------------
      enabledLog: true,
      exportLog: false,
      showLogWidget: true,

      /// ------------------------------------------------------------
      /// Typed theme & locale definitions
      /// (Used with context.appTheme / context.appLocale)
      /// ------------------------------------------------------------
      themes: [
        DummyTheme(id: 'light', color: const Color(0xFF1565C0)),
        DummyTheme(id: 'dark', color: const Color(0xFF263238)),
      ],
      locales: [
        DummyLocale(id: 'en', title: 'English'),
        DummyLocale(id: 'fa', title: 'فارسی'),
      ],

      /// ------------------------------------------------------------
      /// JSON-based theme configuration
      /// (Alternative to typed themes)
      ///
      /// NOTE:
      /// Do NOT mix typed + JSON for same type in real usage.
      /// ------------------------------------------------------------
      jsonThemes: [
        {
          'light': {
            'home': {'background': const Color(0xFF1565C0)},
            'profile': {'background': const Color(0xFF1565C0)},
          },
        },
        {
          'dark': {
            'home': {'background': const Color(0xFF263238)},
            'profile': {'background': const Color(0xFF263238)},
          },
        },
      ],

      jsonThemesAddress: const [
        'assets/theme/light.json',
        'assets/theme/dark.json',
      ],

      /// ------------------------------------------------------------
      /// JSON-based localization
      /// ------------------------------------------------------------
      jsonLocales: [
        {
          'en': {
            'home': {'appbar': 'Home Screen'},
            'profile': {'appbar': 'Profile Screen'},
          },
        },
        {
          'fa': {
            'home': {'appbar': 'صفحه اصلی'},
            'profile': {'appbar': 'صفحه پروفایل'},
          },
        },
      ],

      jsonLocalesAddress: const [
        'assets/locale/fa.json',
        'assets/locale/en.json',
      ],

      /// ------------------------------------------------------------
      /// Transition animations for theme & locale switching
      /// ------------------------------------------------------------
      themeAnimation: ValuesAnimationType.fade,
      localeAnimation: ValuesAnimationType.blurReveal,
      themeAnimationDuration: const Duration(milliseconds: 400),
      localeAnimationDuration: const Duration(milliseconds: 400),

      /// Root app widget
      child: const _MyApp(),
    ),
  );
}

class _MyApp extends StatelessWidget {
  const _MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UtilerScope demo',
      debugShowCheckedModeBanner: false,
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  @override
  Widget build(BuildContext context) {
    /// ------------------------------------------------------------
    /// Typed access (recommended when using DummyTheme/DummyLocale)
    /// ------------------------------------------------------------
    final theme = context.appTheme as DummyTheme;
    final locale = context.appLocale as DummyLocale;

    /// ------------------------------------------------------------
    /// JSON-based access (optional mode)
    /// ------------------------------------------------------------
    final jsonTheme = context.appJsonTheme;
    final jsonLocale = context.appJsonLocale;

    return Scaffold(
      drawerScrimColor:
          (jsonTheme?['home'] as Map?)?['background'] ?? theme.color,

      backgroundColor: 'home.background'.cr,

      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(locale.title),
            Text((jsonLocale?['home'] as Map?)?['appbar'] ?? ''),
            Text('home.appbar'.tr),
          ],
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      UtilerScope.changeAppTheme('light');
                      context.changeAppTheme('light');
                    },
                    child: const Text('Theme: light'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      UtilerScope.changeAppTheme('dark');
                      context.changeAppTheme('dark');
                    },
                    child: const Text('Theme: dark'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      UtilerScope.changeAppLocale('en');
                      context.changeAppLocale('en');
                    },
                    child: const Text('Locale: en'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      UtilerScope.changeAppLocale('fa');
                      context.changeAppLocale('fa');
                    },
                    child: const Text('Locale: fa'),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              DropdownButtonFormField<ValuesAnimationType?>(
                key: ValueKey(UtilerScope.themeAnimationType),
                initialValue: UtilerScope.themeAnimationType,
                decoration: const InputDecoration(
                  labelText: 'Default theme animation',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('instant (none)'),
                  ),
                  ...ValuesAnimationType.values.map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.name)),
                  ),
                ],
                onChanged: (value) async {
                  await UtilerScope.changeThemeAnimation(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ValuesAnimationType?>(
                key: ValueKey(UtilerScope.localeAnimationType),
                initialValue: UtilerScope.localeAnimationType,
                decoration: const InputDecoration(
                  labelText: 'Default locale animation',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('instant (none)'),
                  ),
                  ...ValuesAnimationType.values.map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.name)),
                  ),
                ],
                onChanged: (value) async {
                  await UtilerScope.changeLocaleAnimation(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'This demo shows theme & locale switching using UtilerScope.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Dummy implementations for demonstration purposes
/// ------------------------------------------------------------

class DummyTheme extends ThemeValues {
  @override
  String id;

  final Color color;

  DummyTheme({required this.id, required this.color});
}

class DummyLocale extends LocaleValues {
  @override
  String id;

  final String title;

  DummyLocale({required this.id, required this.title});
}
