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

  /// Devuelve un estado por id.
  ///
  /// Scope: `organization:read`, `packages:read` o `packages:write`.
  Future<Status> retrieve(String id) {
    return _http.get(resourcePath('statuses', id), decode: Status.fromJson);
  }

  /// Crea un estado.
  ///
  /// El cuerpo es [StatusCreate]. `category` es `package`, `other` o `fleet`.
  /// `shipment` ya no se puede crear. Sin `position` el API deja 1.
  /// Scope: `packages:write` o `organization:read`.
  Future<Status> create(StatusCreate body) {
    return _http.post(
      '/org-api/v1/statuses',
      body: body.toJson(),
      decode: Status.fromJson,
    );
  }

  /// Actualiza un estado. Solo hace falta enviar los campos que cambian.
  ///
  /// `warehouseId` o `locationId` en `null` quita el vínculo.
  /// Scope: `packages:write` o `organization:read`.
  Future<Status> update(String id, StatusWrite body) {
    return _http.patch(
      resourcePath('statuses', id),
      body: body.toJson(),
      decode: Status.fromJson,
    );
  }

  /// Elimina un estado.
  ///
  /// Scope: `packages:write` o `organization:read`.
  Future<DeletedResource> delete(String id) {
    return _http.delete(
      resourcePath('statuses', id),
      decode: DeletedResource.fromJson,
    );
  }
}
