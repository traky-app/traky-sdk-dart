/// Lee un objeto JSON sin exigir que vengan todas las claves.
final class JsonMap {
  JsonMap(this.map);

  final Map<String, dynamic> map;

  static JsonMap of(Object? value) {
    if (value is Map) {
      return JsonMap(value.map((key, item) => MapEntry('$key', item)));
    }
    return JsonMap(const {});
  }

  String? string(String key) {
    final value = map[key];
    if (value is String) return value;
    return null;
  }

  double number(String key, {double fallback = 0}) {
    final value = map[key];
    if (value is num) return value.toDouble();
    return fallback;
  }

  double? numberOrNull(String key) {
    final value = map[key];
    if (value is num) return value.toDouble();
    return null;
  }

  int integer(String key, {int fallback = 0}) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  int? integerOrNull(String key) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  bool boolean(String key, {bool fallback = false}) {
    final value = map[key];
    if (value is bool) return value;
    return fallback;
  }

  bool? booleanOrNull(String key) {
    final value = map[key];
    if (value is bool) return value;
    return null;
  }

  List<T> list<T>(String key, T Function(Object? item) decode) {
    final value = map[key];
    if (value is! List) return <T>[];
    return [for (final item in value) decode(item)];
  }

  List<T>? listOrNull<T>(String key, T Function(Object? item) decode) {
    if (!map.containsKey(key) || map[key] == null) return null;
    return list(key, decode);
  }

  T? object<T>(String key, T Function(Object? json) decode) {
    final value = map[key];
    if (value is! Map) return null;
    return decode(value);
  }
}

/// Quita el centinela [absent]. Un `null` explícito se conserva.
Map<String, Object?> compact(Map<String, Object?> fields) {
  final json = <String, Object?>{};
  for (final entry in fields.entries) {
    if (identical(entry.value, absent)) continue;
    json[entry.key] = entry.value;
  }
  return json;
}

/// Marca un argumento que el llamador no envió.
const absent = Object();
