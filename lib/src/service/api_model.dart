import 'package:utiler/utiler.dart';

/// Base class for API data models with value semantics.
///
/// Extend this instead of implementing [ApiParser] directly on every model.
/// Subclasses must declare a single [props] getter listing every field value
/// in constructor declaration order; [==], [hashCode], and [toString] are
/// derived from [props] automatically.
///
/// Pair each model with an [ApiParser] subclass and register it in
/// [ParserRegistry] so [ApiService] can deserialize responses.
///
/// Example:
/// ```dart
/// class User extends ApiModel<User, UserParser> {
///   const User({required this.id, required this.name, this.age});
///
///   final String id;
///   final String name;
///   final int? age;
///
///   @override
///   List<Object?> get props => [id, name, age];
/// }
///
/// class UserParser extends ApiParser<User> {
///   @override
///   User fromJson(Map<String, dynamic> json) => User(
///         id: json['id'] as String,
///         name: json['name'] as String,
///         age: json['age'] as int?,
///       );
///
///   @override
///   Map<String, dynamic> toJson(User model) => {
///         'id': model.id,
///         'name': model.name,
///         'age': model.age,
///       };
/// }
/// ```
abstract class ApiModel<T extends ApiModel<T, P>, P extends ApiParser<T>> {
  /// Creates an [ApiModel] instance.
  const ApiModel();

  /// Whether this model is equal to [other].
  ///
  /// Two models are equal when they share the same runtime type and every
  /// value in [props] matches pairwise.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final o = other as ApiModel;
    final a = props;
    final b = o.props;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// A hash code derived from every value in [props].
  @override
  int get hashCode => Object.hashAll(props);

  /// A debug representation in the form `TypeName(field1, field2, ...)`.
  @override
  String toString() {
    final typeName = runtimeType.toString();
    return '$typeName(${props.join(', ')})';
  }

  /// Every field value that identifies this object, in declaration order.
  ///
  /// Used by [==], [hashCode], and [toString].
  ///
  /// Example:
  /// ```dart
  /// @override
  /// List<Object?> get props => [id, name, age];
  /// ```
  List<Object?> get props;
}
