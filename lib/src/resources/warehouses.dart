import '../http.dart';
import '../models.dart';

/// Bodegas de la organización. Atajo de `offices.list(type: OfficeType.warehouse)`.
final class WarehousesResource {
  WarehousesResource(this._http);

  final TrakyHttp _http;

  /// Lista las bodegas. Misma ruta que `offices.list`, con `type=warehouse`.
  ///
  /// El `id` se usa como `warehouseId` al crear un paquete o un recibo.
  /// Scope: `organization:read`, `packages:read` o `packages:write`.
  Future<WarehouseList> list() {
    return _http.get(
      '/org-api/v1/offices',
      query: {'type': 'warehouse'},
      decode: WarehouseList.fromJson,
    );
  }
}
