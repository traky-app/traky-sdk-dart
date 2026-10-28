import '../http.dart';
import '../models.dart';

/// Estados de la organización: paquete, envío, otro y flota.
final class StatusesResource {
  StatusesResource(this._http);

  final TrakyHttp _http;

  /// Lista los estados.
  ///
  /// Sin [category] devuelve `package`, `shipment`, `other` y `fleet`.
  /// Scope: `organization:read`, `packages:read` o `packages:write`.
  Future<StatusList> list({StatusCategory? category}) {
    return _http.get(
      '/org-api/v1/statuses',
      query: {'category': category?.wire},
      decode: StatusList.fromJson,
    );
  }
}
