/// Essential utilities for Dart and Flutter applications.
///
/// Utiler bundles everyday helpers into a single import: async rate limiting,
/// safe error handling, logging, responsive layout widgets, collection
/// extensions, and optional app-wide theme/locale management via
/// [UtilerScope].
///
/// @example
/// ```dart
/// import 'package:utiler/utiler.dart';
///
/// void main() {
///   runApp(
///     UtilerScope(
///       enabledLog: true,
///       themes: myThemes,
///       locales: myLocales,
///       child: const MyApp(),
///     ),
///   );
/// }
/// ```
library;

export 'src/async/debouncer.dart';
export 'src/async/retey.dart';
export 'src/async/throttler.dart';
export 'src/concurrency/batch_executor.dart';
export 'src/concurrency/parallel_executor.dart';
export 'src/core/either.dart';
export 'src/core/guard.dart';
export 'src/core/internet_connectivity.dart';
export 'src/core/lazy_value.dart';
export 'src/core/lifecycle_handler.dart';
export 'src/extension/context_extension.dart';
export 'src/extension/iterable_extension.dart';
export 'src/extension/list_extension.dart';
export 'src/extension/map_extension.dart';
export 'src/extension/num_extension.dart';
export 'src/extension/string_extension.dart';
export 'src/logger/logger.dart';
export 'src/logger/logger_console.dart';
export 'src/logger/pretty_logger.dart';
export 'src/logger/stopwatch_logger.dart';
export 'src/service/api_error.dart';
export 'src/service/api_error_parser.dart';
export 'src/service/api_exception.dart';
export 'src/service/api_model.dart';
export 'src/service/api_parser.dart';
export 'src/service/api_response.dart';
export 'src/service/api_service.dart';
export 'src/service/parser_registery.dart';
export 'src/service/simple_api_error.dart';
export 'src/ui/color_extension.dart';
export 'src/ui/colorful_safearea.dart';
export 'src/ui/expandable_widget.dart';
export 'src/ui/gap_extension.dart';
export 'src/ui/gaps.dart';
export 'src/ui/inkwell_button.dart';
export 'src/ui/keyboard_dismiss.dart';
export 'src/ui/responsive.dart';
export 'src/utiler_scope.dart';
export 'src/values/animation/values_animation_type.dart';
export 'src/values/locale/locale_extension.dart';
export 'src/values/locale/locale_values.dart';
export 'src/values/theme/theme_extension.dart';
export 'src/values/theme/theme_values.dart';
