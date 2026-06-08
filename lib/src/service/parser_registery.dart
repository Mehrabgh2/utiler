import 'package:utiler/src/service/api_parser.dart';

/// A registry that stores and resolves [ApiParser] instances
/// for different model types.
///
/// This is used by [ApiService] to automatically convert JSON
/// responses into strongly-typed Dart models.
///
/// Instead of manually passing parsers on every request,
/// parsers are registered once and reused globally.
class ParserRegistry {
  /// Creates a [ParserRegistry] with an optional initial list of parsers.
  ///
  /// Example:
  /// ```dart
  /// final registry = ParserRegistry([
  ///   PostParser(),
  ///   UserParser(),
  /// ]);
  /// ```
  ParserRegistry([List<ApiParser<dynamic>> parsers = const []]) {
    for (final parser in parsers) {
      _registerByRuntimeType(parser);
    }
  }

  /// Internal storage of type → parser mappings.
  final Map<Type, ApiParser<dynamic>> _parsers = {};

  /// Registers a parser for a specific type [T].
  ///
  /// Example:
  /// ```dart
  /// registry.register<Post>(PostParser());
  /// ```
  void register<T>(ApiParser<T> parser) {
    _parsers[T] = parser;
  }

  /// Registers a parser by extracting its generic type [T] at runtime
  /// via the parser's own [ApiParser.type] getter.
  ///
  /// Used internally by the list constructor to avoid type erasure.
  void _registerByRuntimeType(ApiParser<dynamic> parser) {
    _parsers[parser.parseType] = parser;
  }

  /// Retrieves the parser for type [T].
  ///
  /// Throws an [Exception] if no parser is registered for [T].
  ///
  /// Example:
  /// ```dart
  /// final parser = registry.get<Post>();
  /// ```
  ApiParser<T>? get<T>() {
    final parser = _parsers[T];
    return parser as ApiParser<T>?;
  }
}
