/// Error base del SDK. Los fallos de red y de configuración también lo usan.
class TrakyException implements Exception {
  TrakyException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'TrakyException: $message';
}

/// La API respondió con un status HTTP de error.
///
/// El cuerpo suele ser el JSON de Nest: `{ statusCode, message, error }`.
class TrakyApiException extends TrakyException {
  TrakyApiException(super.message, this.status, this.body);

  final int status;
  final Object? body;

  static TrakyApiException fromResponse(int status, Object? body) {
    return TrakyApiException(_messageFromBody(body, status), status, body);
  }

  @override
  String toString() => 'TrakyApiException: $message';
}

String _messageFromBody(Object? body, int status) {
  if (body is! Map) return 'Traky respondió $status.';

  final message = body['message'];
  if (message is String && message.trim().isNotEmpty) {
    return message.trim();
  }
  if (message is List) {
    final parts = message
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (parts.isNotEmpty) return parts.join('; ');
  }
  final error = body['error'];
  if (error is String && error.trim().isNotEmpty) return error.trim();
  return 'Traky respondió $status.';
}
