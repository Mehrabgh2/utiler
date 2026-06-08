import 'package:flutter/material.dart';

/// Built-in transition styles for theme and locale switching.
///
/// Pass a [ValuesAnimationType] to [ThemeScope.changeTheme],
/// [LocaleScope.changeLocale], or the `animation` parameters on
/// [ValuesScope], [UtilerScope], and [BuildContext] extension methods.
///
/// Animation resolution priority (theme and locale):
/// 1. Per-call [ValuesAnimationType] argument
/// 2. [ValuesRuntime.themeAnimation] / [ValuesRuntime.localeAnimation]
///    (set by [UtilerScope] or scope widgets)
/// 3. Instant switch when both are `null`
///
/// Example:
/// ```dart
/// // App-wide default from ValuesScope:
/// ValuesScope(
///   themeAnimation: ValuesAnimationType.circle,
///   child: MyApp(),
/// );
///
/// // Override for a single switch:
/// context.changeAppTheme('dark', ValuesAnimationType.fade);
/// ```
enum ValuesAnimationType {
  /// Circular ripple expanding from the tap point.
  circle,

  /// Rectangular reveal expanding from the tap point.
  box,

  /// New content fades in over the previous screen.
  fadeIn,

  /// Previous screen fades out to reveal new content.
  fadeOut,

  /// Smooth cross-fade between old and new content.
  fade,

  /// New content slides up into view.
  slideUp,

  /// New content slides down into view.
  slideDown,

  /// New content slides in from the left.
  slideLeft,

  /// New content slides in from the right.
  slideRight,

  /// New content scales up from the tap point.
  scale,

  /// Circular zoom reveal with an ease-out curve.
  zoom,

  /// Blur clears as the circular reveal expands.
  blurReveal,
}

/// Helpers for [ValuesAnimationType].
///
/// Provides transition metadata used by [ValuesTransitionBuilder].
extension ValuesAnimationTypeX on ValuesAnimationType {
  /// Whether this style reveals content with a path mask.
  bool get usesPathReveal => switch (this) {
    ValuesAnimationType.circle ||
    ValuesAnimationType.box ||
    ValuesAnimationType.zoom ||
    ValuesAnimationType.blurReveal => true,
    _ => false,
  };

  /// Recommended curve for this transition.
  Curve get curve => switch (this) {
    ValuesAnimationType.fadeIn => Curves.easeIn,
    ValuesAnimationType.fadeOut => Curves.easeOut,
    ValuesAnimationType.fade => Curves.easeInOut,
    ValuesAnimationType.slideUp ||
    ValuesAnimationType.slideDown ||
    ValuesAnimationType.slideLeft ||
    ValuesAnimationType.slideRight => Curves.easeOutCubic,
    ValuesAnimationType.scale => Curves.easeOutBack,
    ValuesAnimationType.zoom => Curves.easeOutCubic,
    _ => Curves.easeInOutCubic,
  };

  /// Whether the reveal should apply a blur effect while animating.
  bool get usesBlur => this == ValuesAnimationType.blurReveal;

  /// Parses a persisted animation name from storage or configuration.
  ///
  /// Returns [fallback] when [value] is `null`, empty, or not a known
  /// [ValuesAnimationType.name].
  ///
  /// Example:
  /// ```dart
  /// final type = ValuesAnimationTypeX.parse(
  ///   prefs.getString('theme_animation'),
  ///   fallback: ValuesAnimationType.circle,
  /// );
  /// ```
  static ValuesAnimationType? parse(
    String? value, {
    ValuesAnimationType? fallback,
  }) {
    if (value == null || value.isEmpty) {
      return fallback;
    }
    for (final type in ValuesAnimationType.values) {
      if (type.name == value) {
        return type;
      }
    }
    return fallback;
  }
}
