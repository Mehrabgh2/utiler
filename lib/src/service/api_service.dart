import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../logger/pretty_logger.dart';
import 'api_exception.dart';

class ApiService {
  final String? _baseUrl;
  final Map<String, String> _defaultHeaders;
  final Duration _timeout;
  final bool _logging;
  final http.Client client;

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
    } on TimeoutException catch (_) {
      throw ApiTimeoutException(_timeout.inSeconds);
    } catch (e, st) {
      throw ApiServerException(e, st);
    }
  }

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
    } on TimeoutException catch (_) {
      throw ApiTimeoutException(_timeout.inSeconds);
    } catch (e, st) {
      throw ApiServerException(e, st);
    }
  }

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
    } on TimeoutException catch (_) {
      throw ApiTimeoutException(_timeout.inSeconds);
    } catch (e, st) {
      throw ApiServerException(e, st);
    }
  }

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
    } on TimeoutException catch (_) {
      throw ApiTimeoutException(_timeout.inSeconds);
    } catch (e, st) {
      throw ApiServerException(e, st);
    }
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final String fullPath = _baseUrl == null ? endpoint : '$_baseUrl/$endpoint';
    queryParameters = queryParameters?.map<String, String>(
      (key, value) => MapEntry(key, value.toString()),
    );
    return Uri.parse(fullPath).replace(queryParameters: queryParameters);
  }

  Map<String, String> _mergeHeaders(Map<String, String>? customHeaders) {
    final headers = {..._defaultHeaders};
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  String? _encodeBody(dynamic data) {
    if (data is String) return data;
    if (data is Map<String, dynamic>) {
      return json.encode(data);
    }
    return data?.toString();
  }
}
