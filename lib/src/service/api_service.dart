import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:utiler/utiler.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ApiService
// ─────────────────────────────────────────────────────────────────────────────

/// A generic HTTP service that parses responses into strongly typed models.
///
/// [E] is the app-wide error type that extends [ApiError].
/// The user MUST provide an [ApiErrorParser<E>] — enforced at compile time.
///
/// Example:
/// ```dart
/// final api = ApiService<AppError>(
///   client: http.Client(),
///   registry: registry,
///   errorParser: AppErrorParser(),
///   baseUrl: 'https://api.example.com',
/// );
/// ```
class ApiService<E extends ApiError> {
  /// Creates an [ApiService] instance.
  ///
  /// - [client] is the underlying HTTP client used for requests.
  /// - [parsers] create registry with all model parsers.
  /// - [errorParser] parses error responses into [E]. Required — enforced at compile time.
  /// - [baseUrl] is the optional base URL for all endpoints.
  ///   Must NOT end with a trailing slash, e.g. `https://api.example.com`.
  /// - [defaultHeaders] are applied to every request.
  /// - [timeout] defines request timeout in seconds. Defaults to 20.
  /// - [logging] enables API logging via [PrettyLogger].
  ApiService({
    required this.client,
    List<ApiParser>? parsers,
    ApiErrorParser<E>? errorParser,
    String? baseUrl,
    Map<String, String> defaultHeaders = const {},
    int timeout = 20,
    bool logging = false,
  }) : _baseUrl = baseUrl?.trimRight().replaceAll(RegExp(r'/$'), ''),
       _defaultHeaders = defaultHeaders,
       _timeout = Duration(seconds: timeout),
       _logging = logging,
       _errorParser = errorParser ?? const SimpleApiErrorParser(),
       _registry = ParserRegistry(parsers ?? []);

  final http.Client client;
  final String? _baseUrl;
  final Map<String, String> _defaultHeaders;
  final Duration _timeout;
  final bool _logging;
  late final ParserRegistry _registry;

  /// Parses error responses into the app-wide error type [E].
  ///
  /// Provided at construction — cannot be null, enforced by required keyword.
  final ApiErrorParser<ApiError> _errorParser;

  // ── Public HTTP verbs ──────────────────────────────────────────────────────

  /// Performs an HTTP GET request and parses the response using registered parser.
  ///
  /// Returns [Right<T>] on success, [Left<E>] on server error.
  ///
  /// Supports nullable response body (e.g. 204 No Content returns null).
  ///
  /// Throws:
  /// - [ApiTimeoutException] if the request exceeds [_timeout].
  /// - [ApiServerException] for unexpected runtime errors.
  Future<ApiResponse<T?, E>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _execute<T?>(() async {
      final uri = _buildUri(endpoint, queryParameters);

      final response = await client
          .get(uri, headers: _mergeHeaders(headers))
          .timeout(_timeout);

      _log(response);
      return _parseResponse<T>(response);
    });
  }

  /// Performs an HTTP POST request and parses the response using registered parser.
  ///
  /// [data] can be a [Map<String, dynamic>] (auto JSON-encoded) or a [String].
  ///
  /// Returns [Right<T>] on success, [Left<E>] on server error.
  Future<ApiResponse<T?, E>> post<T>(
    String endpoint,
    dynamic data, {
    Map<String, String>? headers,
  }) {
    return _execute<T?>(() async {
      final uri = _buildUri(endpoint);
      final encoded = await _encodeBody(data);

      final response = await client
          .post(
            uri,
            headers: _mergeHeaders(headers, isJson: data is Map),
            body: encoded,
          )
          .timeout(_timeout);

      _log(response);
      return _parseResponse<T>(response);
    });
  }

  /// Performs an HTTP PUT request and parses the response using registered parser.
  ///
  /// Returns [Right<T>] on success, [Left<E>] on server error.
  Future<ApiResponse<T?, E>> put<T>(
    String endpoint,
    dynamic data, {
    Map<String, String>? headers,
  }) {
    return _execute<T?>(() async {
      final uri = _buildUri(endpoint);
      final encoded = await _encodeBody(data);

      final response = await client
          .put(
            uri,
            headers: _mergeHeaders(headers, isJson: data is Map),
            body: encoded,
          )
          .timeout(_timeout);

      _log(response);
      return _parseResponse<T>(response);
    });
  }

  /// Performs an HTTP PATCH request and parses the response using registered parser.
  ///
  /// Returns [Right<T>] on success, [Left<E>] on server error.
  Future<ApiResponse<T?, E>> patch<T>(
    String endpoint,
    dynamic data, {
    Map<String, String>? headers,
  }) {
    return _execute<T?>(() async {
      final uri = _buildUri(endpoint);
      final encoded = await _encodeBody(data);

      final response = await client
          .patch(
            uri,
            headers: _mergeHeaders(headers, isJson: data is Map),
            body: encoded,
          )
          .timeout(_timeout);

      _log(response);
      return _parseResponse<T>(response);
    });
  }

  /// Performs an HTTP DELETE request and parses the response using registered parser.
  ///
  /// Returns [Right<T>] on success, [Left<E>] on server error.
  Future<ApiResponse<T?, E>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _execute<T?>(() async {
      final uri = _buildUri(endpoint, queryParameters);

      final response = await client
          .delete(uri, headers: _mergeHeaders(headers))
          .timeout(_timeout);

      _log(response);
      return _parseResponse<T>(response);
    });
  }

  // ── List HTTP verbs ────────────────────────────────────────────────────────

  /// Performs a GET request expecting a JSON ARRAY response.
  ///
  /// Each item is parsed using registered parser for [T].
  /// Corrupted items are skipped and collected in [ApiResponse.parseErrors].
  ///
  /// Returns [Right<List<T>>] on success, [Left<E>] on server error.
  Future<ApiResponse<List<T>, E>> getList<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _execute<List<T>>(() async {
      final uri = _buildUri(endpoint, queryParameters);

      final response = await client
          .get(uri, headers: _mergeHeaders(headers))
          .timeout(_timeout);

      _log(response);
      return _parseListResponse<T>(response);
    });
  }

  /// Performs a POST request expecting a JSON ARRAY response.
  ///
  /// Returns [Right<List<T>>] on success, [Left<E>] on server error.
  Future<ApiResponse<List<T>, E>> postList<T>(
    String endpoint,
    dynamic data, {
    Map<String, String>? headers,
  }) {
    return _execute<List<T>>(() async {
      final uri = _buildUri(endpoint);
      final encoded = await _encodeBody(data);

      final response = await client
          .post(
            uri,
            headers: _mergeHeaders(headers, isJson: data is Map),
            body: encoded,
          )
          .timeout(_timeout);

      _log(response);
      return _parseListResponse<T>(response);
    });
  }

  /// Performs a PUT request expecting a JSON ARRAY response.
  ///
  /// Returns [Right<List<T>>] on success, [Left<E>] on server error.
  Future<ApiResponse<List<T>, E>> putList<T>(
    String endpoint,
    dynamic data, {
    Map<String, String>? headers,
  }) {
    return _execute<List<T>>(() async {
      final uri = _buildUri(endpoint);
      final encoded = await _encodeBody(data);

      final response = await client
          .put(
            uri,
            headers: _mergeHeaders(headers, isJson: data is Map),
            body: encoded,
          )
          .timeout(_timeout);

      _log(response);
      return _parseListResponse<T>(response);
    });
  }

  /// Performs a PATCH request expecting a JSON ARRAY response.
  ///
  /// Returns [Right<List<T>>] on success, [Left<E>] on server error.
  Future<ApiResponse<List<T>, E>> patchList<T>(
    String endpoint,
    dynamic data, {
    Map<String, String>? headers,
  }) {
    return _execute<List<T>>(() async {
      final uri = _buildUri(endpoint);
      final encoded = await _encodeBody(data);

      final response = await client
          .patch(
            uri,
            headers: _mergeHeaders(headers, isJson: data is Map),
            body: encoded,
          )
          .timeout(_timeout);

      _log(response);
      return _parseListResponse<T>(response);
    });
  }

  // ── File operations ────────────────────────────────────────────────────────

  /// Uploads a file using a multipart HTTP POST request.
  ///
  /// - [endpoint] is the target API endpoint.
  /// - [filePath] is the absolute path to the file on disk.
  /// - [fileField] is the form field name expected by the server. Defaults to `'file'`.
  /// - [fields] are optional additional form fields sent alongside the file.
  /// - [headers] are optional request-specific headers merged with [_defaultHeaders].
  ///
  /// Returns [Right<T>] with the parsed response on success.
  /// Returns [Left<E>] with a typed error on server error.
  ///
  /// Throws:
  /// - [ApiTimeoutException] if the request exceeds [_timeout].
  /// - [ApiServerException] for unexpected runtime errors.
  ///
  /// Example:
  /// ```dart
  /// final response = await api.uploadFile<UploadResult>(
  ///   'attachments/upload',
  ///   filePath: '/storage/image.png',
  ///   fileField: 'attachment',
  ///   fields: {'userId': '42'},
  /// );
  ///
  /// response.result.fold(
  ///   (error) => print(error.message),
  ///   (result) => print(result),
  /// );
  /// ```
  Future<ApiResponse<T?, E>> uploadFile<T>(
    String endpoint, {
    required String filePath,
    String fileField = 'file',
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) {
    return _execute<T?>(() async {
      final uri = _buildUri(endpoint);

      final request = http.MultipartRequest('POST', uri);

      /// Merge default headers — skip Content-Type since multipart
      /// sets its own boundary-based content type automatically.
      final merged = _mergeHeaders(headers);
      merged.remove('Content-Type');
      request.headers.addAll(merged);

      /// Attach additional form fields if provided.
      if (fields != null) {
        request.fields.addAll(fields);
      }

      /// Attach the file from disk as a multipart file.
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);

      _log(response);
      return _parseResponse<T>(response);
    });
  }

  /// Downloads a file from the given [endpoint] and saves it to [savePath].
  ///
  /// - [endpoint] is the target API endpoint.
  /// - [savePath] is the absolute path where the downloaded file will be saved.
  /// - [queryParameters] are optional query parameters appended to the URL.
  /// - [headers] are optional request-specific headers merged with [_defaultHeaders].
  /// - [onProgress] is an optional callback reporting download progress as a
  ///   value between `0.0` and `1.0`. Called repeatedly as bytes are received.
  ///
  /// Returns [Right<String>] with [savePath] on success so the caller knows
  /// where the file was saved.
  /// Returns [Left<E>] with a typed error on server error.
  ///
  /// Throws:
  /// - [ApiTimeoutException] if the request exceeds [_timeout].
  /// - [ApiServerException] for unexpected runtime errors.
  ///
  /// Example:
  /// ```dart
  /// final response = await api.downloadFile(
  ///   'reports/monthly.pdf',
  ///   savePath: '/storage/downloads/monthly.pdf',
  ///   onProgress: (progress) => print('${(progress * 100).toInt()}%'),
  /// );
  ///
  /// response.result.fold(
  ///   (error) => print(error.message),
  ///   (path)  => print('Saved to $path'),
  /// );
  /// ```
  Future<ApiResponse<String?, E>> downloadFile(
    String endpoint, {
    required String savePath,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    void Function(double progress)? onProgress,
  }) {
    return _execute<String?>(() async {
      final uri = _buildUri(endpoint, queryParameters);

      final request = http.Request('GET', uri);
      request.headers.addAll(_mergeHeaders(headers));

      final streamed = await client.send(request).timeout(_timeout);

      /// Non-2xx responses are parsed as typed errors via [_errorParser]
      /// and returned as [Left<E>] instead of saving the file.
      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        final body = await streamed.stream.bytesToString();
        final error = _errorParser.fromJson(
          _safeDecodeError(body, streamed.statusCode),
        );
        return ApiResponse<String?, E>(
          statusCode: streamed.statusCode,
          result: Left(error as E),
          rawBody: body,
        );
      }

      /// Stream response bytes directly to disk to avoid loading
      /// the entire file into memory — safe for large files.
      final file = File(savePath);
      final sink = file.openWrite();

      final totalBytes = streamed.contentLength ?? 0;
      var receivedBytes = 0;

      await for (final chunk in streamed.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;

        /// Report progress only when total size is known and callback is provided.
        if (onProgress != null && totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
      }

      await sink.flush();
      await sink.close();

      return ApiResponse<String?, E>(
        statusCode: streamed.statusCode,
        result: Right(savePath),
      );
    });
  }

  // ── Execution wrapper (shared error handling) ──────────────────────────────

  /// Centralized execution wrapper:
  /// - Handles timeout
  /// - Wraps unexpected errors
  /// - Keeps all HTTP methods DRY
  Future<ApiResponse<T, E>> _execute<T>(
    Future<ApiResponse<T, E>> Function() action,
  ) async {
    try {
      return await action();
    } on TimeoutException {
      throw ApiTimeoutException(_timeout.inSeconds);
    } catch (e, st) {
      if (e is ApiTimeoutException) rethrow;
      print(e.toString());
      throw ApiServerException(e, st);
    }
  }

  // ── Parsing ────────────────────────────────────────────────────────────────

  /// Decodes JSON response and converts it into model using registered parser.
  ///
  /// Supports:
  /// - Empty body → returns null wrapped in [Right]
  /// - Non-2xx status → parses error body into [E] and wraps in [Left]
  /// - Object JSON → parsed model wrapped in [Right]
  /// - Array JSON → throws (use getList)
  Future<ApiResponse<T?, E>> _parseResponse<T>(http.Response response) async {
    final rawBody = response.body;

    // handle empty response (e.g. 204 No Content)
    if (rawBody.trim().isEmpty) {
      return ApiResponse<T?, E>(
        statusCode: response.statusCode,
        result: Right(null),
        rawBody: rawBody,
      );
    }

    /// Non-2xx responses are parsed as typed errors via [_errorParser]
    /// and returned as [Left<E>] instead of throwing.
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = _errorParser.fromJson(
        _safeDecodeError(rawBody, response.statusCode),
      );
      return ApiResponse<T?, E>(
        statusCode: response.statusCode,
        result: Left(error as E),
        rawBody: rawBody,
      );
    }

    final decoded = await compute(json.decode, rawBody);

    if (decoded is List) {
      throw StateError(
        'Expected JSON object but got array. Use list methods (getList/postList/...).',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Unexpected JSON shape: ${decoded.runtimeType}');
    }

    final parser = _registry.get<T>();
    if (parser == null) {
      return ApiResponse<T?, E>(
        statusCode: response.statusCode,
        result: Right(rawBody as T?),
        rawBody: rawBody,
      );
    }
    final parsed = parser.fromJson(decoded);

    return ApiResponse<T?, E>(
      statusCode: response.statusCode,
      result: Right(parsed),
      rawBody: rawBody,
    );
  }

  /// Parses list response where JSON is expected to be an array.
  ///
  /// - Non-2xx responses are parsed as typed errors via [_errorParser]
  ///   and returned as [Left<E>] instead of throwing.
  /// - Corrupted items are skipped and collected in [ApiResponse.parseErrors].
  Future<ApiResponse<List<T>, E>> _parseListResponse<T>(
    http.Response response,
  ) async {
    final rawBody = response.body;

    /// Non-2xx responses are parsed as typed errors via [_errorParser]
    /// and returned as [Left<E>] instead of throwing.
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = _errorParser.fromJson(
        _safeDecodeError(rawBody, response.statusCode),
      );
      return ApiResponse<List<T>, E>(
        statusCode: response.statusCode,
        result: Left(error as E),
        rawBody: rawBody,
      );
    }

    final decoded = await compute(json.decode, rawBody);

    if (decoded is! List) {
      throw FormatException(
        'Expected JSON array but got ${decoded.runtimeType}',
      );
    }

    final parser = _registry.get<T>();
    if (parser == null) {
      return ApiResponse<List<T>, E>(
        statusCode: response.statusCode,
        result: Right([rawBody as T]),
        rawBody: rawBody,
      );
    }

    final items = <T>[];
    final errors = <({int index, Object error, StackTrace stack})>[];

    for (var i = 0; i < decoded.length; i++) {
      try {
        final raw = decoded[i];
        if (raw is! Map<String, dynamic>) {
          throw FormatException('Expected object but got ${raw.runtimeType}');
        }
        items.add(parser.fromJson(raw));
      } catch (e, st) {
        errors.add((index: i, error: e, stack: st));
      }
    }

    return ApiResponse<List<T>, E>(
      statusCode: response.statusCode,
      result: Right(items),
      rawBody: rawBody,
      parseErrors: errors,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Safely decodes an error response body into a [Map].
  ///
  /// Falls back to a generic error map if the body is not valid JSON —
  /// server may return HTML, plain text, or an empty body on errors.
  Map<String, dynamic> _safeDecodeError(String body, int statusCode) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        if (decoded.isNotEmpty) {
          return decoded;
        }
      }
    } catch (_) {}

    /// Body is not valid JSON — use raw body text as the error message
    /// so the caller still gets a meaningful [ApiError.message].
    return {
      'message': body.trim().isNotEmpty ? body.trim() : 'Unknown error',
      'code': statusCode,
    };
  }

  /// Builds a full [Uri] from [endpoint] and optional query parameters.
  ///
  /// Handles leading slashes on [endpoint] so double-slashes are avoided.
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    // Normalise: strip leading slash from endpoint so joining is always safe.
    final normalised = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;
    final fullPath = _baseUrl == null ? normalised : '$_baseUrl/$normalised';

    final encodedQuery = queryParameters?.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return Uri.parse(fullPath).replace(queryParameters: encodedQuery);
  }

  /// Merges [_defaultHeaders] with [customHeaders].
  ///
  /// When [isJson] is true, adds `Content-Type: application/json` unless it is
  /// already present in [customHeaders] or [_defaultHeaders].
  Map<String, String> _mergeHeaders(
    Map<String, String>? customHeaders, {
    bool isJson = false,
  }) {
    final merged = <String, String>{..._defaultHeaders};
    if (isJson && !merged.containsKey('Content-Type')) {
      merged['Content-Type'] = 'application/json';
    }
    if (customHeaders != null) {
      merged.addAll(customHeaders); // custom headers win
    }
    return merged;
  }

  /// Encodes [data] for HTTP transport.
  ///
  /// - [Map<String, dynamic>] → JSON string via [compute] (background isolate)
  /// - [String]               → returned as-is
  /// - anything else          → [toString()]
  Future<String?> _encodeBody(dynamic data) async {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map<String, dynamic>) {
      // Heavy encode off the main thread
      return compute(json.encode, data);
    }
    return data.toString();
  }

  void _log(http.Response response) {
    if (_logging) {
      unawaited(PrettyLogger.api(response));
    }
  }
}
