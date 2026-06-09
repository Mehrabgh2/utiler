/// Supported application environments.
enum AppEnvironment {
  /// Local development builds.
  development,

  /// Pre-production / QA environment.
  staging,

  /// Live production environment.
  production,
}

/// Typed application configuration loaded from a raw map.
///
/// Use [AppConfig.fromMap] to parse environment-specific settings such as API
/// URLs, timeouts, and feature toggles from JSON or `.env`-style data.
///
/// @example
/// ```dart
/// final config = AppConfig.fromMap(
///   environment: AppEnvironment.production,
///   data: {
///     'api_base_url': 'https://api.example.com',
///     'timeout_seconds': 30,
///     'enable_analytics': true,
///   },
/// );
///
/// final url = config.require<String>('api_base_url');
/// final timeout = config.get<int>('timeout_seconds', fallback: 10);
/// ```
class AppConfig {
  AppConfig._({required this.environment, required Map<String, dynamic> data})
    : _data = Map.unmodifiable(data);

  /// Creates an [AppConfig] for [environment] from [data].
  factory AppConfig.fromMap({
    required AppEnvironment environment,
    required Map<String, dynamic> data,
  }) {
    return AppConfig._(environment: environment, data: data);
  }

  /// The environment this config belongs to.
  final AppEnvironment environment;

  final Map<String, dynamic> _data;

  /// Returns `true` when [environment] is [AppEnvironment.development].
  bool get isDevelopment => environment == AppEnvironment.development;

  /// Returns `true` when [environment] is [AppEnvironment.production].
  bool get isProduction => environment == AppEnvironment.production;

  /// Returns `true` when [environment] is [AppEnvironment.staging].
  bool get isStaging => environment == AppEnvironment.staging;

  /// Returns the value for [key], or [fallback] when missing or wrong type.
  T? get<T>(String key, {T? fallback}) {
    final value = _data[key];
    if (value is T) {
      return value;
    }
    return fallback;
  }

  /// Returns the required value for [key].
  ///
  /// Throws [StateError] when the key is missing or the value is not [T].
  T require<T>(String key) {
    if (!_data.containsKey(key)) {
      throw StateError('AppConfig: required key "$key" is missing.');
    }
    final value = _data[key];
    if (value is! T) {
      throw StateError(
        'AppConfig: key "$key" expected type $T but got ${value.runtimeType}.',
      );
    }
    return value;
  }

  /// Returns `true` when [key] exists in this config.
  bool has(String key) => _data.containsKey(key);

  /// All keys defined in this config.
  Iterable<String> get keys => _data.keys;

  /// Exports config as a plain map (useful for logging or debugging).
  Map<String, dynamic> toMap() => Map.from(_data);

  @override
  String toString() =>
      'AppConfig(environment: $environment, keys: ${_data.keys.toList()})';
}

/// Holds configs for multiple environments and resolves the active one.
///
/// @example
/// ```dart
/// final store = AppConfigStore(
///   active: AppEnvironment.development,
///   configs: {
///     AppEnvironment.development: AppConfig.fromMap(
///       environment: AppEnvironment.development,
///       data: {'api_base_url': 'http://localhost:8080'},
///     ),
///     AppEnvironment.production: AppConfig.fromMap(
///       environment: AppEnvironment.production,
///       data: {'api_base_url': 'https://api.example.com'},
///     ),
///   },
/// );
///
/// final url = store.active.require<String>('api_base_url');
/// ```
class AppConfigStore {
  /// Creates a store with [configs] and the [active] environment.
  AppConfigStore({required AppEnvironment active, required this.configs})
    : _active = active;

  final AppEnvironment _active;

  /// All environment configs keyed by [AppEnvironment].
  final Map<AppEnvironment, AppConfig> configs;

  /// The currently active [AppConfig].
  AppConfig get active {
    final config = configs[_active];
    if (config == null) {
      throw StateError(
        'AppConfigStore: no config registered for environment "$_active".',
      );
    }
    return config;
  }

  /// The active [AppEnvironment].
  AppEnvironment get environment => _active;
}
