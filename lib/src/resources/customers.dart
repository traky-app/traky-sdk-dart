import '../http.dart';
import '../models.dart';

/// Clientes con portal de la organización dueña de la API key.
final class CustomersResource {
  CustomersResource(this._http);

  final TrakyHttp _http;

  /// Lista los clientes.
  ///
  /// [types] filtra por rol. El alta deja siempre `CLIENT`.
  /// Scope: `customers:read` o `organization:read`.
  Future<DirectoryPage<Customer>> list({
    String? search,
    bool? isActive,
    DirectorySort? sortBy,
    String? tagId,
    List<CustomerType>? types,
    int? page,
    int? limit,
    String? cursor,
  }) {
    return _http.get(
      '/org-api/v1/customers',
      query: {
        'search': search,
        'isActive': isActive,
        'sortBy': sortBy?.wire,
        'tagId': tagId,
        'types': types?.map((type) => type.wire).toList(),
        'page': page,
        'limit': limit,
        'cursor': cursor,
      },
      decode: DirectoryPage.decoder(Customer.fromJson),
    );
  }

  /// Devuelve un cliente por id.
  ///
  /// Scope: `customers:read` o `organization:read`.
  Future<Customer> retrieve(String id) {
    return _http.get(resourcePath('customers', id), decode: Customer.fromJson);
  }

  /// Crea un cliente.
  ///
  /// No envíes `types`: el API guarda `CLIENT`.
  /// Cuenta `PERSONAL` (por defecto): `firstName`. Cuenta `BUSINESS`: `companyName`.
  /// `createContact: true` (o ausente) crea un contacto `SHIPPER` con los mismos datos.
  /// `createContact: false` crea solo el cliente.
  /// Scope: `customers:write` o `organization:read`.
  Future<Customer> create(CustomerCreate body) {
    return _http.post(
      '/org-api/v1/customers',
      body: body.toJson(),
      decode: Customer.fromJson,
    );
  }

  /// Actualiza un cliente. Solo hace falta enviar los campos que cambian.
  ///
  /// Scope: `customers:write` o `organization:read`.
  Future<Customer> update(String id, CustomerWrite body) {
    return _http.patch(
      resourcePath('customers', id),
      body: body.toJson(),
      decode: Customer.fromJson,
    );
  }

  /// Elimina un cliente.
  ///
  /// Scope: `customers:write` o `organization:read`.
  Future<DeletedResource> delete(String id) {
    return _http.delete(
      resourcePath('customers', id),
      decode: DeletedResource.fromJson,
    );
  }
}
