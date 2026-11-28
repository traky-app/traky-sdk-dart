import '../http.dart';
import '../identity.dart';
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
  /// Cédula y RUC: solo `identityNumber`. El API verifica y completa el nombre.
  /// Pasaporte: `identityNumber`, `firstName` y `lastName`.
  /// `createContact: true` o ausente crea un contacto `CONSIGNEE` (consignatario) con esos datos.
  /// `createContact: false` crea solo el cliente.
  /// Scope: `customers:write` o `organization:read`.
  Future<Customer> create(CustomerCreate body) async {
    assertCustomerIdentityWrite(
      creating: true,
      identityType: body.identityType,
      identityNumber: body.identityNumber,
      firstName: body.firstName,
      lastName: body.lastName,
      companyName: body.companyName,
    );
    return _http.post(
      '/org-api/v1/customers',
      body: body.toJson(),
      decode: Customer.fromJson,
    );
  }

  /// Actualiza un cliente. Solo hace falta enviar los campos que cambian.
  ///
  /// Si cambias a cédula o RUC, envía solo el número. El API vuelve a verificar.
  /// Scope: `customers:write` o `organization:read`.
  Future<Customer> update(String id, CustomerWrite body) async {
    assertCustomerIdentityWrite(
      creating: false,
      identityType: body.identityType,
      identityNumber: body.identityNumber,
      firstName: body.firstName,
      lastName: body.lastName,
      companyName: body.companyName,
    );
    return _http.patch(
      resourcePath('customers', id),
      body: body.toJson(),
      decode: Customer.fromJson,
    );
  }
}
