/// A chainable async form validator that supports both synchronous and
/// asynchronous rules such as server-side uniqueness checks.
///
/// Rules are evaluated in order; the first error stops evaluation.
/// For purely synchronous validation chains, prefer [FormValidator] — reserve
/// [AsyncFormValidator] for cases that genuinely require `async` operations.
///
/// Example:
/// ```dart
/// final validator = AsyncFormValidator()
///   .required()
///   .minLength(3)
///   .rule((v) async {
///     final taken = await api.isUsernameTaken(v!);
///     return taken ? 'Username is already taken.' : null;
///   });
///
/// final error = await validator.validate(controller.text);
/// if (error != null) setState(() => _error = error);
/// ```
class AsyncFormValidator {
  /// Creates an empty async validator chain.
  AsyncFormValidator();

  final List<_AsyncRule> _rules = [];
  bool _isOptional = false;

  /// Marks all subsequent rules as skippable when the value is blank.
  ///
  /// When the value is `null` or contains only whitespace, [validate]
  /// immediately returns `null` without running any rules.
  AsyncFormValidator optional() {
    _isOptional = true;
    return this;
  }

  /// Value must not be null or blank.
  AsyncFormValidator required({String message = 'This field is required.'}) {
    _rules.add(
      _AsyncRule((v) async => (v == null || v.trim().isEmpty) ? message : null),
    );
    return this;
  }

  /// Value length must be at least [length].
  AsyncFormValidator minLength(int length, {String? message}) {
    _rules.add(
      _AsyncRule(
        (v) async => (v != null && v.length < length)
            ? (message ?? 'Minimum $length characters required.')
            : null,
      ),
    );
    return this;
  }

  /// Value length must not exceed [length].
  AsyncFormValidator maxLength(int length, {String? message}) {
    _rules.add(
      _AsyncRule(
        (v) async => (v != null && v.length > length)
            ? (message ?? 'Maximum $length characters allowed.')
            : null,
      ),
    );
    return this;
  }

  /// Value must be a valid email address.
  AsyncFormValidator email({String message = 'Enter a valid email address.'}) {
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    _rules.add(
      _AsyncRule(
        (v) async => (v != null && !re.hasMatch(v.trim())) ? message : null,
      ),
    );
    return this;
  }

  /// Adds a fully custom async rule.
  ///
  /// [check] receives the current value and must return an error string,
  /// or `null` if the value passes.
  ///
  /// Example:
  /// ```dart
  /// validator.rule((v) async {
  ///   final taken = await api.isEmailTaken(v!);
  ///   return taken ? 'Email already registered.' : null;
  /// });
  /// ```
  AsyncFormValidator rule(Future<String?> Function(String? value) check) {
    _rules.add(_AsyncRule(check));
    return this;
  }

  /// Runs all rules against [value] in order.
  ///
  /// Returns the first error message encountered, or `null` if all pass.
  /// Returns `null` immediately for blank input when [optional] was called.
  Future<String?> validate(String? value) async {
    if (_isOptional && (value == null || value.trim().isEmpty)) return null;
    for (final rule in _rules) {
      final error = await rule.check(value);
      if (error != null) return error;
    }
    return null;
  }
}

class _AsyncRule {
  const _AsyncRule(this.check);

  final Future<String?> Function(String? value) check;
}
