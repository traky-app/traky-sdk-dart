import 'dart:convert';

import 'package:http/http.dart' as http;

import 'errors.dart';
import 'query.dart';
import 'version.dart';

const defaultBaseUrl = 'https://api.traky.app';

const _defaultTimeout = Duration(seconds: 30);

final class TrakyHttp {
  TrakyHttp({
    required String apiKey,
    String? baseUrl,
    http.Client? httpClient,
    this.timeout = _defaultTimeout,
    Map<String, String>? headers,
  })  : apiKey = _requiredKey(apiKey),
        baseUrl = _normalizeBase(baseUrl ?? defaultBaseUrl),
        _headers = headers ?? const {},
        _client = httpClient ?? http.Client(),
        _ownsClient = httpClient == null;

  final String apiKey;
  final String baseUrl;
  final Duration timeout;
  final Map<String, String> _headers;
  final http.Client _client;
  final bool _ownsClient;

  Future<T> get<T>(
    String path, {
    Map<String, Object?>? query,
    required T Function(Object? json) decode,
  }) {
    return request('GET', path, query: query, decode: decode);
  }

  Future<T> post<T>(
    String path, {
    Object? body,
    required T Function(Object? json) decode,
  }) {
    return request('POST', path, body: body, decode: decode);
  }

  Future<T> patch<T>(
    String path, {
    Object? body,
    required T Function(Object? json) decode,
  }) {
    return request('PATCH', path, body: body, decode: decode);
  }

  Future<T> delete<T>(
    String path, {
    required T Function(Object? json) decode,
  }) {
    return request('DELETE', path, decode: decode);
  }

  Future<T> request<T>(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    required T Function(Object? json) decode,
  }) async {
    final uri = _uri(path, toQuery(query));
    final request = http.Request(method, uri);
    request.headers.addAll({
      'Accept': 'application/json',
      ..._headers,
      'Authorization': 'Bearer $apiKey',
      'User-Agent': '$sdkName/$sdkVersion',
    });
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    try {
      final streamed = await _client.send(request).timeout(
        timeout,
        onTimeout: () {
          throw TrakyException(
            'La petición a Traky superó ${timeout.inMilliseconds} ms.',
          );
        },
      );
      final response = await http.Response.fromStream(streamed);
      final payload = _readBody(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw TrakyApiException.fromResponse(response.statusCode, payload);
      }
      return decode(payload);
    } on TrakyException {
      rethrow;
    } catch (error) {
      throw TrakyException(
        'No se pudo contactar la API de Traky.',
        cause: error,
      );
    }
  }

  void close() {
    if (_ownsClient) _client.close();
  }

  Uri _uri(String path, Map<String, String>? query) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$normalized');
    if (query == null) return uri;
    return uri.replace(queryParameters: query);
  }
}

String _requiredKey(String apiKey) {
  final trimmed = apiKey.trim();
  if (trimmed.isEmpty) {
    throw TrakyException(
      'Falta la API key. Créala en Traky y pásala en `apiKey` (prefijo trk_).',
    );
  }
  return trimmed;
}

String _normalizeBase(String baseUrl) {
  var value = baseUrl.trim();
  while (value.endsWith('/')) {
    value = value.substring(0, value.length - 1);
  }
  return value;
}

Object? _readBody(String text) {
  if (text.isEmpty) return null;
  try {
    return jsonDecode(text);
  } on FormatException {
    return text;
  }
}

String resourcePath(String collection, String id) {
  return '/org-api/v1/$collection/${Uri.encodeComponent(id)}';
}
