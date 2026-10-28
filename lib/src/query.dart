/// Arma el query string. Los arrays salen unidos por coma (`types=CLIENT,SHIPPER`).
Map<String, String>? toQuery(Map<String, Object?>? input) {
  if (input == null) return null;
  final query = <String, String>{};
  for (final entry in input.entries) {
    final value = entry.value;
    if (value == null) continue;
    if (value is List) {
      if (value.isEmpty) continue;
      query[entry.key] = value.join(',');
      continue;
    }
    query[entry.key] = '$value';
  }
  if (query.isEmpty) return null;
  return query;
}
