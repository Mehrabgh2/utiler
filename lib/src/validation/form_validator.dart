/// A chainable, Flutter-compatible form validator.
///
/// Each method appends a rule; [validate] runs all rules in order and returns
/// the first error message, or `null` on success. [build] converts the chain
/// into a `String? Function(String?)` suitable for `TextFormField.validator`.
///
/// @example
/// ```dart
/// final error = FormValidator()
///   .required()
///   .email(message: 'Enter a valid email')
///   .validate(value);
///
/// TextFormField(
///   validator: FormValidator()
///     .required()
///     .minLength(8)
///     .build(),
/// )
/// ```
class FormValidator {
  /// Creates an empty validator chain. Add rules with [required], [email], etc.
  FormValidator();

  final List<_ValidationRule> _rules = [];
  bool _isOptional = false;

  /// Marks all subsequent rules as skippable when the value is blank.
  ///
  /// When the value is `null` or contains only whitespace, [validate]
  /// immediately returns `null` without evaluating any rule. Useful for
  /// optional fields that still have format constraints when filled.
  ///
  /// ```dart
  /// // Passes when empty; validates format when filled:
  /// FormValidator().optional().email().build()
  /// ```
  FormValidator optional() {
    _isOptional = true;
    return this;
  }

  /// Value must not be null or empty.
  FormValidator required({String message = 'This field is required.'}) {
    _rules.add(
      _ValidationRule((v) => (v == null || v.trim().isEmpty) ? message : null),
    );
    return this;
  }

  /// Value length must be at least [length].
  FormValidator minLength(int length, {String? message}) {
    _rules.add(
      _ValidationRule(
        (v) => (v != null && v.length < length)
            ? (message ?? 'Minimum $length characters required.')
            : null,
      ),
    );
    return this;
  }

  /// Value length must not exceed [length].
  FormValidator maxLength(int length, {String? message}) {
    _rules.add(
      _ValidationRule(
        (v) => (v != null && v.length > length)
            ? (message ?? 'Maximum $length characters allowed.')
            : null,
      ),
    );
    return this;
  }

  /// Value must match the given [pattern].
  FormValidator matches(RegExp pattern, {String message = 'Invalid format.'}) {
    _rules.add(
      _ValidationRule(
        (v) => (v != null && !pattern.hasMatch(v)) ? message : null,
      ),
    );
    return this;
  }

  /// Value must be a valid email address.
  FormValidator email({String message = 'Enter a valid email address.'}) {
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    _rules.add(
      _ValidationRule(
        (v) => (v != null && !re.hasMatch(v.trim())) ? message : null,
      ),
    );
    return this;
  }

  /// Value must be a valid international phone number (E.164-ish).
  ///
  /// Accepts `+1234567890` format with 7–15 digits.
  FormValidator phone({
    String message = 'Enter a valid international phone number.',
  }) {
    final re = RegExp(r'^\+?[1-9]\d{6,14}$');
    _rules.add(
      _ValidationRule(
        (v) =>
            (v != null && !re.hasMatch(v.replaceAll(' ', ''))) ? message : null,
      ),
    );
    return this;
  }

  /// Value must be a valid Iranian mobile number (`09xxxxxxxxx`).
  FormValidator iranianPhone({
    String message = 'Enter a valid Iranian phone number (09xxxxxxxxx).',
  }) {
    final re = RegExp(r'^09[0-9]{9}$');
    _rules.add(
      _ValidationRule(
        (v) => (v != null && !re.hasMatch(v.trim())) ? message : null,
      ),
    );
    return this;
  }

  /// Value must be a valid HTTP or HTTPS URL.
  FormValidator url({String message = 'Enter a valid URL.'}) {
    _rules.add(
      _ValidationRule((v) {
        if (v == null) {
          return null;
        }
        final uri = Uri.tryParse(v.trim());
        final valid =
            uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
        return valid ? null : message;
      }),
    );
    return this;
  }

  /// Value must be a valid IPv4 or IPv6 address.
  FormValidator ipAddress({String message = 'Enter a valid IP address.'}) {
    final ipv4 = RegExp(
      r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
    );
    final ipv6 = RegExp(r'^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$');
    _rules.add(
      _ValidationRule(
        (v) => (v != null && !ipv4.hasMatch(v) && !ipv6.hasMatch(v))
            ? message
            : null,
      ),
    );
    return this;
  }

  /// Value must be a valid Iranian national ID (10-digit, checksum verified).
  FormValidator iranianNationalId({
    String message = 'Enter a valid Iranian national ID.',
  }) {
    _rules.add(
      _ValidationRule((v) {
        if (v == null || v.isEmpty) {
          return null;
        }
        if (!RegExp(r'^\d{10}$').hasMatch(v)) {
          return message;
        }
        if (RegExp(r'^(.)\1{9}$').hasMatch(v)) {
          return message;
        }
        final digits = v.split('').map(int.parse).toList();
        final check = digits[9];
        final sum = List.generate(
          9,
          (i) => digits[i] * (10 - i),
        ).reduce((a, b) => a + b);
        final remainder = sum % 11;
        final valid =
            (remainder < 2 && check == remainder) ||
            (remainder >= 2 && check == 11 - remainder);
        return valid ? null : message;
      }),
    );
    return this;
  }

  /// Value must be a valid IBAN (basic format check, length 15–34 chars).
  FormValidator iban({String message = 'Enter a valid IBAN.'}) {
    final re = RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]{11,30}$');
    _rules.add(
      _ValidationRule(
        (v) => (v != null && !re.hasMatch(v.replaceAll(' ', '').toUpperCase()))
            ? message
            : null,
      ),
    );
    return this;
  }

  /// Value must be a valid credit card number (Luhn algorithm).
  FormValidator creditCard({
    String message = 'Enter a valid credit card number.',
  }) {
    _rules.add(
      _ValidationRule((v) {
        if (v == null || v.isEmpty) {
          return null;
        }
        final digits = v.replaceAll(RegExp(r'\D'), '');
        if (digits.length < 13 || digits.length > 19) {
          return message;
        }
        var sum = 0;
        var alternate = false;
        for (var i = digits.length - 1; i >= 0; i--) {
          var n = int.parse(digits[i]);
          if (alternate) {
            n *= 2;
            if (n > 9) {
              n -= 9;
            }
          }
          sum += n;
          alternate = !alternate;
        }
        return sum % 10 == 0 ? null : message;
      }),
    );
    return this;
  }

  /// Value must be a valid postal code (4–10 alphanumeric characters).
  FormValidator postalCode({String message = 'Enter a valid postal code.'}) {
    final re = RegExp(r'^[A-Z0-9]{4,10}$', caseSensitive: false);
    _rules.add(
      _ValidationRule(
        (v) => (v != null && !re.hasMatch(v.trim())) ? message : null,
      ),
    );
    return this;
  }

  /// Value must contain at least one uppercase letter.
  FormValidator hasUppercase({
    String message = 'Must contain at least one uppercase letter.',
  }) {
    _rules.add(
      _ValidationRule(
        (v) => (v != null && !v.contains(RegExp(r'[A-Z]'))) ? message : null,
      ),
    );
    return this;
  }

  /// Value must contain at least one lowercase letter.
  FormValidator hasLowercase({
    String message = 'Must contain at least one lowercase letter.',
  }) {
    _rules.add(
      _ValidationRule(
        (v) => (v != null && !v.contains(RegExp(r'[a-z]'))) ? message : null,
      ),
    );
    return this;
  }

  /// Value must contain at least one digit.
  FormValidator hasDigit({
    String message = 'Must contain at least one digit.',
  }) {
    _rules.add(
      _ValidationRule(
        (v) => (v != null && !v.contains(RegExp(r'[0-9]'))) ? message : null,
      ),
    );
    return this;
  }

  /// Value must contain at least one special character.
  FormValidator hasSpecialChar({
    String message = 'Must contain at least one special character.',
  }) {
    final re = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\+=/\\]');
    _rules.add(
      _ValidationRule((v) => (v != null && !v.contains(re)) ? message : null),
    );
    return this;
  }

  /// Value must be a valid username: alphanumeric, underscores, 3–20 chars.
  FormValidator username({String message = 'Invalid username format.'}) {
    final re = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    _rules.add(
      _ValidationRule(
        (v) => (v != null && !re.hasMatch(v.trim())) ? message : null,
      ),
    );
    return this;
  }

  /// Value (parsed as [DateTime]) must fall within [from] and [to] (inclusive).
  FormValidator dateRange(DateTime from, DateTime to, {String? message}) {
    _rules.add(
      _ValidationRule((v) {
        if (v == null || v.isEmpty) {
          return null;
        }
        final parsed = DateTime.tryParse(v.trim());
        if (parsed == null) {
          return 'Enter a valid date (YYYY-MM-DD).';
        }
        final inRange = !parsed.isBefore(from) && !parsed.isAfter(to);
        return inRange
            ? null
            : (message ??
                  'Date must be between ${_fmt(from)} and ${_fmt(to)}.');
      }),
    );
    return this;
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Runs all rules against [value]. Returns the first error, or `null`.
  ///
  /// Returns `null` immediately for blank input when [optional] was called.
  String? validate(String? value) {
    if (_isOptional && (value == null || value.trim().isEmpty)) return null;
    for (final rule in _rules) {
      final error = rule.check(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Returns a validator callback for `TextFormField.validator`.
  String? Function(String?) build() => validate;
}

class _ValidationRule {
  const _ValidationRule(this.check);
  final String? Function(String?) check;
}
