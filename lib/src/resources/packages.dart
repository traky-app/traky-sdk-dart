import '../http.dart';
import '../models.dart';

/// Paquetes exportados de la organización.
final class PackagesResource {
  PackagesResource(this._http);

  final TrakyHttp _http;

  /// Lista los paquetes de la organización, hasta 500, los más recientes.
  ///
  /// Cada paquete trae `packageType` (`WR`), `receiptNumber` y `packageNumber`.
  /// Scope: `packages:read`.
  Future<PackageExport> list() {
    return _http.get('/org-api/v1/packages', decode: PackageExport.fromJson);
  }

  /// Lista solo los paquetes ligados a Misiil.
  ///
  /// La respuesta agrega `source: "misiil"`. El recibo es el warehouse (`WHR…`).
  /// Scope: `packages:read`.
  Future<MisiilPackageExport> listFromMisiil() {
    return _http.get(
      '/org-api/v1/marketplaces/misiil/packages',
      decode: MisiilPackageExport.fromJson,
    );
  }

  /// Devuelve un paquete por id.
  ///
  /// Scope: `packages:read`.
  Future<Package> retrieve(String id) {
    return _http.get(resourcePath('packages', id), decode: Package.fromJson);
  }

  /// Crea un paquete.
  ///
  /// Hacen falta fecha, tracking, estado y oficina.
  /// Sin `receiptSerialNumber` el API reserva un recibo WR nuevo y este paquete es P1.
  /// Para colgar P2 en un recibo ya creado, envía su `receiptSerialNumber` y el índice.
  /// Scope: `packages:write` o `organization:read`.
  Future<Package> create(PackageCreate body) {
    return _http.post(
      '/org-api/v1/packages',
      body: body.toJson(),
      decode: Package.fromJson,
    );
  }

  /// Actualiza un paquete. Solo hace falta enviar los campos que cambian.
  ///
  /// Scope: `packages:write` o `organization:read`.
  Future<Package> update(String id, PackageWrite body) {
    return _http.patch(
      resourcePath('packages', id),
      body: body.toJson(),
      decode: Package.fromJson,
    );
  }

  /// Elimina un paquete. No borra el resto del recibo.
  ///
  /// Scope: `packages:write` o `organization:read`.
  Future<DeletedResource> delete(String id) {
    return _http.delete(
      resourcePath('packages', id),
      decode: DeletedResource.fromJson,
    );
  }
}
