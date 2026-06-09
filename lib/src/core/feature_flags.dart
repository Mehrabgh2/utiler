/// Runtime feature-flag registry for toggling app behaviour without redeploys.
///
/// Register boolean flags once at startup, then query them anywhere in the app.
///
/// @example
/// ```dart
/// final flags = FeatureFlags({
///   'new_checkout': true,
///   'beta_chat': false,
/// });
///
/// if (flags.isEnabled('new_checkout')) {
///   // show new checkout flow
/// }
/// ```
class FeatureFlags {
  /// Creates a [FeatureFlags] registry from [features].
  ///
  /// Missing keys resolve to `false` via [isEnabled].
  FeatureFlags(Map<String, bool> features)
    : _features = Map.unmodifiable(features);

  final Map<String, bool> _features;

  /// Returns whether [key] is enabled. Defaults to `false` when missing.
  bool isEnabled(String key) => _features[key] ?? false;

  /// Shorthand for [isEnabled].
  bool call(String key) => isEnabled(key);

  /// All registered flags and their values.
  Map<String, bool> get map => Map.unmodifiable(_features);
}
