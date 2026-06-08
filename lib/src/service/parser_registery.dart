import 'package:utiler/src/service/api_parser.dart';

/// A registry that stores and resolves [ApiParser] instances by model type.
///
/// Parsers are registered once and reused by [ApiService] to convert JSON
/// response bodies into strongly typed Dart models without passing a parser
/// on every request.
///
/// Example:
/// ```dart
/// final registry = ParserRegistry([
///   PostParser(),
///   UserParser(),
/// ]);
///
/// registry.register<Comment>(CommentParser());
/// final parser = registry.get<Post>();
/// ```
class ParserRegistry {
  /// Creates a [ParserRegistry] with an optional initial list of [parsers].
  ///
  /// Each parser is registered using its [ApiParser.parseType] so generic
  /// type information is preserved despite Dart's type erasure.
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

  final Map<Type, ApiParser<dynamic>> _parsers = {};

  /// Registers [parser] for type [T].
  ///
  /// Later registrations for the same [T] replace the previous parser.
  ///
  /// Example:
  /// ```dart
  /// registry.register<Post>(PostParser());
  /// ```
  void register<T>(ApiParser<T> parser) {
    _parsers[T] = parser;
  }

  void _registerByRuntimeType(ApiParser<dynamic> parser) {
    _parsers[parser.parseType] = parser;
  }

  /// Returns the parser registered for type [T], or `null` if none exists.
  ///
  /// When no parser is found, [ApiService] returns the raw response body
  /// cast to [T] instead of throwing.
  ///
  /// Example:
  /// ```dart
  /// final parser = registry.get<Post>();
  /// if (parser != null) {
  ///   final post = parser.fromJson(json);
  /// }
  /// ```
  ApiParser<T>? get<T>() {
    final parser = _parsers[T];
    return parser as ApiParser<T>?;
  }
}
