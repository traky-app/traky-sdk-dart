import 'dart:io';

export 'package:traky/traky.dart';

import 'package:traky/traky.dart';

Traky trakyFromEnvironment() {
  final apiKey = Platform.environment['TRAKY_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    throw StateError('Define TRAKY_API_KEY (prefijo trk_).');
  }
  return Traky(apiKey: apiKey);
}
