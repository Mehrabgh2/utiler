/// Base contract for strongly typed theme definitions.
///
/// [ThemeValues] is used by the typed theming system to ensure that
/// every theme has a unique identifier.
///
/// This allows:
/// - switching themes by ID
/// - consistent theme lookup in [ThemeScope] and [ThemeManager]
/// - compile-time structure for theme implementations
///
/// Example:
/// ```dart
/// class AppTheme extends ThemeValues {
///   @override
///   final String id;
///
///   final Color primary;
///   final Color background;
///
///   AppTheme({
///     required this.id,
///     required this.primary,
///     required this.background,
///   });
/// }
/// ```
abstract class ThemeValues {
  /// Unique identifier for the theme (e.g. "light", "dark").
  abstract String id;
}
