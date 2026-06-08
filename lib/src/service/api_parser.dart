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
  /// The type this parser handles.
  ///
  /// Must return [T] — used by [ParserRegistry] to register parsers
  /// passed via the list constructor without losing type information.
  Type get parseType => T;

  /// Constructs an instance of [T] from a JSON map.
  ///
  /// This method is responsible for transforming raw API response data
  /// into a strongly typed Dart model.
  ///
  /// Implement this using your model's factory constructor:
  ///
  /// ```dart
  /// factory MyModel.fromJson(Map<String, dynamic> json) { ... }
  /// ```
  T fromJson(Map<String, dynamic> json);

  /// Converts the model instance into a JSON map.
  ///
  /// This is used when sending data back to an API (POST, PUT, PATCH).
  Map<String, dynamic> toJson(T model);

  // copyWith is intentionally NOT declared here because its signature must
  // match each model's own fields. With `freezed` it is generated
  // automatically. For hand-written models, add it directly to the class.
}
