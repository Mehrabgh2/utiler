import 'package:utiler/utiler.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ApiModel
//
// Extend this instead of implementing ApiParser directly.
// You only need to provide 1 thing in your subclass:
//
//    List<Object?> get props  → all fields, in declaration order
//
// Everything else (==, hashCode, toString) is handled here.
//
// ─── Minimal example ─────────────────────────────────────────────────────────
//
//   class User extends ApiModel<User> {
//     const User({required this.id, required this.name, this.age});
//     final String id;
//     final String name;
//     final int?   age;
//
//     // Declare fields in the SAME order as the constructor.
//     @override
//     List<Object?> get props => [id, name, age];
//
// ─────────────────────────────────────────────────────────────────────────────

abstract class ApiModel<T extends ApiModel<T, P>, P extends ApiParser<T>> {
  const ApiModel();

  // ── Object overrides ───────────────────────────────────────────────────────

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

  @override
  int get hashCode => Object.hashAll(props);

  @override
  String toString() {
    final typeName = runtimeType.toString();
    return '$typeName(${props.join(', ')})';
  }

  // ── Contract ───────────────────────────────────────────────────────────────

  /// Return every field value that identifies this object, in declaration order.
  ///
  /// Used by [==], [hashCode], and [toString].
  List<Object?> get props;
}
