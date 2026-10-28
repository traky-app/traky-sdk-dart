import '../http.dart';
import '../models.dart';

/// Organización dueña de la API key.
final class OrganizationResource {
  OrganizationResource(this._http);

  final TrakyHttp _http;

  /// Devuelve la organización de la API key.
  ///
  /// Scope: `organization:read`.
  Future<Organization> retrieve() {
    return _http.get(
      '/org-api/v1/organization',
      decode: Organization.fromJson,
    );
  }
}
