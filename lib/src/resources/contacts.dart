import '../http.dart';
import '../models.dart';

/// Contactos comerciales de la organización, sin portal.
///
/// El rol se envía en `types` ([ContactType]).
final class ContactsResource {
  ContactsResource(this._http);

  final TrakyHttp _http;

  /// Lista los contactos.
  ///
  /// [types] filtra por rol. [clientId] limita a los de un cliente.
  /// Scope: `contacts:read` o `organization:read`.
  Future<DirectoryPage<Contact>> list({
    int? page,
    int? limit,
    String? search,
    bool? isActive,
    List<ContactType>? types,
    String? clientId,
    bool? unlinked,
    bool? linked,
    DirectorySort? sortBy,
  }) {
    return _http.get(
      '/org-api/v1/contacts',
      query: {
        'page': page,
        'limit': limit,
        'search': search,
        'isActive': isActive,
        'types': types?.map((type) => type.wire).toList(),
        'clientId': clientId,
        'unlinked': unlinked,
        'linked': linked,
        'sortBy': sortBy?.wire,
      },
      decode: DirectoryPage.decoder(Contact.fromJson),
    );
  }

  /// Devuelve un contacto por id.
  ///
  /// Scope: `contacts:read` o `organization:read`.
  Future<Contact> retrieve(String id) {
    return _http.get(resourcePath('contacts', id), decode: Contact.fromJson);
  }

  /// Crea un contacto.
  ///
  /// Cuenta `PERSONAL` (por defecto): `firstName`. Cuenta `BUSINESS`: `companyName`.
  /// Si omites `types`, queda `SHIPPER`. `CLIENT` no es válido.
  /// Scope: `contacts:write` o `organization:read`.
  Future<Contact> create(ContactWrite body) {
    return _http.post(
      '/org-api/v1/contacts',
      body: body.toJson(),
      decode: Contact.fromJson,
    );
  }

  /// Actualiza un contacto. Solo hace falta enviar los campos que cambian.
  ///
  /// `clientId: null` desvincula al cliente. `types` reemplaza los roles.
  /// Scope: `contacts:write` o `organization:read`.
  Future<Contact> update(String id, ContactWrite body) {
    return _http.patch(
      resourcePath('contacts', id),
      body: body.toJson(),
      decode: Contact.fromJson,
    );
  }

  /// Elimina un contacto.
  ///
  /// Scope: `contacts:write` o `organization:read`.
  Future<DeletedResource> delete(String id) {
    return _http.delete(
      resourcePath('contacts', id),
      decode: DeletedResource.fromJson,
    );
  }
}
