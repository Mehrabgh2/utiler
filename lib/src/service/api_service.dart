import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:utiler/src/logger/pretty_logger.dart';
import 'package:utiler/src/service/api_exception.dart';

/// A lightweight HTTP API client wrapper built on top of [http.Client].
///
/// [ApiService] provides:
/// - Base URL support
/// - Default headers merging
/// - Automatic JSON encoding
/// - Request timeout handling
/// - Structured exception mapping
/// - Optional request/response logging via [PrettyLogger]
///
/// It is intended to simplify REST API usage in Flutter applications
/// while keeping the interface minimal and testable.
///
/// Example:
/// ```dart
/// final api = ApiService(
///   client: http.Client(),
///   baseUrl: 'https://api.example.com',
///   logging: true,
/// );
///
/// final response = await api.get('/users');
/// ```
class ApiService {
  /// Creates an [ApiService] instance.
  ///
  /// - [client] is the underlying HTTP client used for requests.
  /// - [baseUrl] is the optional base URL for all endpoints.
  /// - [defaultHeaders] are applied to every request.
  /// - [timeout] defines request timeout in seconds.
  /// - [logging] enables API logging via [PrettyLogger].
  ApiService({
    required this.client,
    String? baseUrl,
    Map<String, String> defaultHeaders = const {},
    int timeout = 20,
    bool logging = false,
  }) : _baseUrl = baseUrl,
       _defaultHeaders = defaultHeaders,
       _timeout = Duration(seconds: timeout),
       _logging = logging;

  /// Underlying HTTP client used for network requests.
  final http.Client client;

  final String? _baseUrl;
  final Map<String, String> _defaultHeaders;
  final Duration _timeout;
  final bool _logging;

  /// Performs an HTTP GET request.
  ///
  /// Supports optional [queryParameters] and [headers].
  ///
  /// Throws:
  /// - [ApiTimeoutException] if request exceeds timeout
  /// - [ApiServerException] for unexpected errors
  Future<http.Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);

      final response = await client
          .get(uri, headers: _mergeHeaders(headers))
          .timeout(_timeout);

      if (_logging) {
        PrettyLogger.api(response);
      }

      return response;
    } on TimeoutException {
      throw ApiTimeoutException(_timeout.inSeconds);
    } catch (e, st) {
      throw ApiServerException(e, st);
    }
  }

  /// Performs an HTTP POST request.
  ///
  /// Automatically encodes [data] as JSON if it is a map.
  Future<http.Response> post(
    String endpoint,
    dynamic data, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      final response = await client
          .post(uri, headers: _mergeHeaders(headers), body: _encodeBody(data))
          .timeout(_timeout);

      if (_logging) {
        PrettyLogger.api(response);
      }

      return response;
    } on TimeoutException {
      throw ApiTimeoutException(_timeout.inSeconds);
    } catch (e, st) {
      throw ApiServerException(e, st);
    }
  }

  /// Performs an HTTP PUT request.
  Future<http.Response> put(
    String endpoint,
    dynamic data, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      final response = await client
          .put(uri, headers: _mergeHeaders(headers), body: _encodeBody(data))
          .timeout(_timeout);

      if (_logging) {
        PrettyLogger.api(response);
      }

      return response;
    } on TimeoutException {
      throw ApiTimeoutException(_timeout.inSeconds);
    } catch (e, st) {
      throw ApiServerException(e, st);
    }
  }

  /// Performs an HTTP DELETE request.
  Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);

      final response = await client
          .delete(uri, headers: _mergeHeaders(headers))
          .timeout(_timeout);

      if (_logging) {
        PrettyLogger.api(response);
      }

      return response;
    } on TimeoutException {
      throw ApiTimeoutException(_timeout.inSeconds);
    } catch (e, st) {
      throw ApiServerException(e, st);
    }
  }

  /// Builds a full request URI from [endpoint] and optional query parameters.
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final String fullPath = _baseUrl == null ? endpoint : '$_baseUrl/$endpoint';

    final encodedQuery = queryParameters?.map<String, String>(
      (key, value) => MapEntry(key, value.toString()),
    );

    return Uri.parse(fullPath).replace(queryParameters: encodedQuery);
  }

  /// Merges default headers with custom request headers.
  Map<String, String> _mergeHeaders(Map<String, String>? customHeaders) {
    final headers = {..._defaultHeaders};
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  /// Encodes request body into a string format suitable for HTTP transport.
  String? _encodeBody(dynamic data) {
    if (data is String) return data;
    if (data is Map<String, dynamic>) {
      return json.encode(data);
    }
    return data?.toString();
  }
}
