/// In-memory theme and locale selection used across scope rebuilds.
///
/// Persists the latest user choice so [ThemeScope], [ThemeJsonScope],
/// [LocaleScope], and [LocaleJsonScope] do not fall back to stale
/// [initialTheme] / [initialLocale] when the widget tree is recreated.
abstract final class ValuesRuntime {
  /// Last selected theme id in this app session.
  static String? currentThemeId;

  /// Last selected locale id in this app session.
  static String? currentLocaleId;
}
