import 'package:http/http.dart' as http;

import 'http.dart';
import 'models.dart';
import 'resources/contacts.dart';
import 'resources/customers.dart';
import 'resources/offices.dart';
import 'resources/organization.dart';
import 'resources/packages.dart';
import 'resources/receipts.dart';
import 'resources/statuses.dart';
import 'resources/warehouses.dart';

/// Cliente de la API de organización (`/org-api/v1`).
///
/// ```dart
/// final traky = Traky(apiKey: apiKey);
/// final organization = await traky.organization.retrieve();
/// ```
final class Traky {
  /// [apiKey] con prefijo `trk_`. [baseUrl] solo si no es producción.
  ///
  /// [httpClient] sustituye el cliente HTTP. Útil en tests.
  /// Si no lo pasas, [close] cierra el cliente interno.
  Traky({
    required String apiKey,
    String? baseUrl,
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 30),
    Map<String, String>? headers,
  }) : _http = TrakyHttp(
          apiKey: apiKey,
          baseUrl: baseUrl,
          httpClient: httpClient,
          timeout: timeout,
          headers: headers,
        ) {
    organization = OrganizationResource(_http);
    statuses = StatusesResource(_http);
    offices = OfficesResource(_http);
    warehouses = WarehousesResource(_http);
    packages = PackagesResource(_http);
    receipts = ReceiptsResource(_http);
    customers = CustomersResource(_http);
    contacts = ContactsResource(_http);
  }

  final TrakyHttp _http;

  /// Organización dueña de la API key.
  late final OrganizationResource organization;

  /// Estados de paquete, envío, otro y flota.
  late final StatusesResource statuses;

  /// Offices. `type` es `office` o `warehouse`.
  late final OfficesResource offices;

  /// Bodegas. Atajo de `offices.list(type: OfficeType.warehouse)`.
  late final WarehousesResource warehouses;

  /// Paquetes de la organización.
  late final PackagesResource packages;

  /// Recibos: grupos de paquetes con el mismo código.
  late final ReceiptsResource receipts;

  /// Clientes con portal. El alta usa [CustomerCreate] (`createContact`).
  late final CustomersResource customers;

  /// Contactos comerciales. El rol se envía en [ContactWrite.types].
  late final ContactsResource contacts;

  /// Cierra el cliente HTTP interno. No cierra un [http.Client] que hayas pasado.
  void close() => _http.close();
}
