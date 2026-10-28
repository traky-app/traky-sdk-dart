import '../http.dart';
import '../models.dart';

/// Offices de la organización: sucursal de atención o bodega, según `type`.
final class OfficesResource {
  OfficesResource(this._http);

  final TrakyHttp _http;

  /// Lista los offices.
  ///
  /// Sin [type] devuelve sucursales (`office`) y bodegas (`warehouse`).
  /// El `id` de un `office` se usa como `locationId`. El de un `warehouse`, como `warehouseId`.
  /// Scope: `organization:read`, `packages:read` o `packages:write`.
  Future<OfficeList> list({OfficeType? type}) {
    return _http.get(
      '/org-api/v1/offices',
      query: {'type': type?.wire},
      decode: OfficeList.fromJson,
    );
  }
}
