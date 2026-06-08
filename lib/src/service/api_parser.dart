import 'package:utiler/utiler.dart';

/// Base contract for parsing and serializing API models.
///
/// [ApiParser] defines how a raw JSON map is converted into a strongly typed
/// Dart model [T], and how that model is converted back into JSON.
///
/// This abstraction allows the API layer to remain generic while delegating
/// serialization logic to individual model parsers.
///
/// Typically used with [ParserRegistry] inside [ApiService].
///
/// Example:
/// ```dart
/// class PostParser extends ApiParser<Post> {
///   @override
///   Post fromJson(Map<String, dynamic> json) => Post.fromJson(json);
///
///   @override
///   Map<String, dynamic> toJson(Post value) => value.toJson();
/// }
/// ```
abstract class ApiParser<T> {
  /// Creates a parser implementation for models of type [T].
  const ApiParser();

  /// The type this parser handles.
  ///
  /// Used by [ParserRegistry] to register parsers passed via the list
  /// constructor without losing type information at runtime.
  Type get parseType => T;

  /// Constructs an instance of [T] from a JSON map.
  ///
  /// Called by [ApiService] after a successful HTTP response is decoded.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Post fromJson(Map<String, dynamic> json) => Post(
  ///       id: json['id'] as int,
  ///       title: json['title'] as String,
  ///     );
  /// ```
  T fromJson(Map<String, dynamic> json);

  /// Converts [model] into a JSON map.
  ///
  /// Used when sending data back to an API via POST, PUT, or PATCH.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Map<String, dynamic> toJson(Post model) => {
  ///       'id': model.id,
  ///       'title': model.title,
  ///     };
  /// ```
  Map<String, dynamic> toJson(T model);

  // copyWith is intentionally NOT declared here because its signature must
  // match each model's own fields. With `freezed` it is generated
  // automatically. For hand-written models, add it directly to the class.
}
