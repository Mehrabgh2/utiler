/// Base contract for strongly typed localization models.
///
/// All locale implementations must extend [LocaleValues] and provide
/// a unique [id] used for switching between locales.
///
/// Example:
/// ```dart
/// class AppLocale extends LocaleValues {
///   @override
///   final String id;
///
///   final String title;
///
///   AppLocale({required this.id, required this.title});
/// }
/// ```
abstract class LocaleValues {
  /// Constructor for subclasses.
  LocaleValues();

  /// Unique identifier for the locale (e.g. `"en"`, `"fa"`).
  abstract String id;
}
