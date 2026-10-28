import '../http.dart';
import '../models.dart';

/// Recibos de la organización.
///
/// Un recibo agrupa paquetes P1, P2… con el mismo código (`WR…` o `WHR…`).
/// `id` es el id del primer paquete.
final class ReceiptsResource {
  ReceiptsResource(this._http);

  final TrakyHttp _http;

  /// Lista los recibos de la organización.
  ///
  /// Cada fila es un recibo, no un paquete. No incluye `packages`.
  /// Scope: `packages:read`.
  Future<ReceiptPage> list({
    int? page,
    int? limit,
    String? trackingNumber,
    String? locationId,
    String? customerId,
    String? shipperId,
    String? itemStatusId,
  }) {
    return _http.get(
      '/org-api/v1/receipts',
      query: {
        'page': page,
        'limit': limit,
        'trackingNumber': trackingNumber,
        'locationId': locationId,
        'customerId': customerId,
        'shipperId': shipperId,
        'itemStatusId': itemStatusId,
      },
      decode: ReceiptPage.fromJson,
    );
  }

  /// Devuelve un recibo y sus paquetes.
  ///
  /// Puedes pasar el id de cualquier pieza del recibo. La respuesta usa el id de P1.
  /// Scope: `packages:read`.
  Future<Receipt> retrieve(String id) {
    return _http.get(resourcePath('receipts', id), decode: Receipt.fromJson);
  }

  /// Crea un recibo con una o más piezas.
  ///
  /// La primera pieza reserva el WR, salvo que envíes `externalReceiptCode` (`WHR…`).
  /// Scope: `packages:write` o `organization:read`.
  Future<Receipt> create(ReceiptCreate body) {
    return _http.post(
      '/org-api/v1/receipts',
      body: body.toJson(),
      decode: Receipt.fromJson,
    );
  }

  /// Actualiza un recibo.
  ///
  /// Los campos de la cabecera se aplican a todas las piezas.
  /// `packages` cambia una pieza que ya existe, por su id.
  /// Scope: `packages:write` o `organization:read`.
  Future<Receipt> update(String id, ReceiptUpdate body) {
    return _http.patch(
      resourcePath('receipts', id),
      body: body.toJson(),
      decode: Receipt.fromJson,
    );
  }

  /// Elimina el recibo completo: todas sus piezas.
  ///
  /// Scope: `packages:write` o `organization:read`.
  Future<DeletedReceipt> delete(String id) {
    return _http.delete(
      resourcePath('receipts', id),
      decode: DeletedReceipt.fromJson,
    );
  }
}
