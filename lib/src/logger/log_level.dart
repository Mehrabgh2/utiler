/// Defines the severity level of a log message.
///
/// This enum is typically used by logging systems (e.g. [PrettyLogger])
/// to categorize and filter log output based on importance.
///
/// Levels are ordered conceptually from least to most severe:
/// - [debug]: detailed development information
/// - [verbose]: very detailed diagnostic information
/// - [info]: general operational messages
/// - [success]: successful operations or milestones
/// - [warning]: potential issues or unexpected states
/// - [error]: failures or exceptions that need attention
enum LogLevel {
  /// Detailed information useful during development.
  debug,

  /// General informational messages about app flow.
  info,

  /// Indicates a successful operation or completion.
  success,

  /// Indicates a potential problem or unusual situation.
  warning,

  /// Indicates an error or failed operation.
  error,

  /// Highly detailed diagnostic messages for tracing execution flow.
  verbose,
}
