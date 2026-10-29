# traky

SDK de Dart para la [API de organización de Traky](https://api.traky.app). Autentica con una API key (`trk_…`) y llama a `/org-api/v1`.

La documentación está en https://traky.app/docs.

Sirve en Flutter, en servidores y en scripts. La única dependencia es [`package:http`](https://pub.dev/packages/http). Requiere Dart 3.4 o superior.

Es el mismo cliente que [`@traky-app/sdk`](https://www.npmjs.com/package/@traky-app/sdk), en Dart.

## Instalación

```bash
dart pub add traky
```

```bash
flutter pub add traky
```

## Uso

Crea la API key en Traky (ajustes de desarrollador de la empresa) y guárdala en `TRAKY_API_KEY`.

```dart
import 'dart:io';

import 'package:traky/traky.dart';

final traky = Traky(
  apiKey: Platform.environment['TRAKY_API_KEY']!,
);

final organization = await traky.organization.retrieve();
final packages = await traky.packages.list();
final misiil = await traky.packages.listFromMisiil();

final created = await traky.packages.create(
  PackageCreate(
    registrationDate: DateTime.now().toUtc().toIso8601String(),
    trackingNumber: '1Z999',
    itemStatusId: '00000000-0000-4000-8000-000000000001',
    locationId: '00000000-0000-4000-8000-000000000002',
    weight: 2,
  ),
);
await traky.packages.update(
  created.id,
  PackageWrite(warehouseComments: 'Retener'),
);

final receipt = await traky.receipts.create(
  ReceiptCreate(
    registrationDate: DateTime.now().toUtc().toIso8601String(),
    locationId: '00000000-0000-4000-8000-000000000002',
    itemStatusId: '00000000-0000-4000-8000-000000000001',
    packages: [
      ReceiptPackageLine(trackingNumber: '1Z111', weight: 1),
      ReceiptPackageLine(trackingNumber: '1Z222', weight: 2),
    ],
  ),
);
await traky.receipts.update(
  receipt.id,
  ReceiptUpdate(warehouseComments: 'Frágil'),
);
await traky.receipts.delete(receipt.id);

final customer = await traky.customers.create(
  CustomerCreate(
    accountType: AccountType.personal,
    firstName: 'Ana',
    email: 'ana@example.com',
    createContact: false,
  ),
);
await traky.customers.update(customer.id, CustomerWrite(lastName: 'Paz'));

final contact = await traky.contacts.create(
  ContactWrite(
    firstName: 'Luis',
    types: [ContactType.shipper],
    clientId: customer.id,
  ),
);
await traky.contacts.update(
  contact.id,
  ContactWrite(types: [ContactType.shipper, ContactType.consignee]),
);
await traky.contacts.delete(contact.id);
```

El ejemplo de cada recurso está en `example/`: `organization.dart`, `statuses.dart`, `offices.dart`, `warehouses.dart`, `packages.dart`, `receipts.dart`, `customers.dart` y `contacts.dart`. `example/directory.dart` crea y borra un cliente y un contacto juntos. Al pasar el cursor sobre `create`, `update`, `list`, `retrieve` o `delete` el editor muestra el cuerpo que hay que enviar.

| Método | Endpoint | Scope |
| --- | --- | --- |
| `organization.retrieve()` | `GET /org-api/v1/organization` | `organization:read` |
| `statuses.list()` / `statuses.retrieve()` | `GET /org-api/v1/statuses` | `organization:read`, `packages:read` o `packages:write` |
| `statuses.create()` / `update()` / `delete()` | `POST`, `PATCH`, `DELETE /org-api/v1/statuses` | `packages:write` o `organization:read` |
| `offices.list()` | `GET /org-api/v1/offices` | `organization:read`, `packages:read` o `packages:write` |
| `offices.list(type: …)` | `GET /org-api/v1/offices?type=office` o `warehouse` | `organization:read`, `packages:read` o `packages:write` |
| `warehouses.list()` | `GET /org-api/v1/offices?type=warehouse` | `organization:read`, `packages:read` o `packages:write` |
| `packages.list()` | `GET /org-api/v1/packages` | `packages:read` |
| `packages.retrieve()` | `GET /org-api/v1/packages/:id` | `packages:read` |
| `packages.create()` / `update()` / `delete()` | `POST`, `PATCH`, `DELETE /org-api/v1/packages` | `packages:write` o `organization:read` |
| `packages.listFromMisiil()` | `GET /org-api/v1/marketplaces/misiil/packages` | `packages:read` |
| `receipts.list()` / `receipts.retrieve()` | `GET /org-api/v1/receipts` | `packages:read` |
| `receipts.create()` / `update()` / `delete()` | `POST`, `PATCH`, `DELETE /org-api/v1/receipts` | `packages:write` o `organization:read` |
| `customers.list()` / `customers.retrieve()` | `GET /org-api/v1/customers` | `customers:read` o `organization:read` |
| `customers.create()` / `update()` / `delete()` | `POST`, `PATCH`, `DELETE /org-api/v1/customers` | `customers:write` o `organization:read` |
| `contacts.list()` / `contacts.retrieve()` | `GET /org-api/v1/contacts` | `contacts:read` o `organization:read` |
| `contacts.create()` / `update()` / `delete()` | `POST`, `PATCH`, `DELETE /org-api/v1/contacts` | `contacts:write` o `organization:read` |

`statuses.list()` sin categoría devuelve los estados de paquete, envío, otro y flota. `statuses.create` recibe `StatusCreate`: `label`, `description`, `category` (`package`, `other` o `fleet`) e `icon`. `shipment` ya no se puede crear. `statuses.update` recibe `StatusWrite`. `warehouseId` o `locationId` en `null` quita ese vínculo. Las claves ya creadas con `organization:read` pueden usar este CRUD. Una clave solo con `packages:read` puede listar, no escribir. El id de un estado de paquete es el `itemStatusId` de un paquete o un recibo. `offices.list()` devuelve sucursales y bodegas. Cada fila trae `type`: `office` atiende al cliente y `warehouse` es bodega. `offices.list(type: OfficeType.office)` deja solo sucursales; `OfficeType.warehouse` (o `warehouses.list()`) deja solo bodegas. El id de una sucursal es el `locationId` de un paquete; el de una bodega, el `warehouseId`. Una bodega también trae `pricePerPoundClient` y `pricePerPoundProvider`.

`packages.list()` devuelve hasta 500 paquetes, los más recientes. Cada paquete trae `packageType` (`WR`), `receiptNumber` y `packageNumber`. En Misiil el recibo es el warehouse (`WHR…`) y el código de paquete es ese recibo más `P1`. `packages.listFromMisiil()` devuelve solo los paquetes ligados a Misiil y agrega `source: "misiil"`. La nota de bodega va en `warehouseComments` y la descripción en `comments`.

`packages.create` recibe `PackageCreate`: fecha, tracking, `itemStatusId` y `locationId`. Sin `receiptSerialNumber` el API abre un recibo WR y el paquete queda como P1. Para agregar P2 a un recibo ya creado, envía el `receiptSerialNumber` de ese recibo y `receiptPackageIndex`. `packages.delete` borra solo ese paquete.

Un recibo es el grupo de paquetes que comparten código. `receipts.create` recibe `ReceiptCreate` y la lista `packages` (P1, P2…). `externalReceiptCode` (`WHR…`) usa el warehouse del proveedor en lugar de la secuencia WR. El `id` del recibo es el id del primer paquete. Puedes pasar el id de cualquier pieza a `retrieve`, `update` y `delete`. `receipts.update` aplica la cabecera a todas las piezas; `packages` dentro del cuerpo cambia una pieza que ya existe. `receipts.delete` elimina el recibo completo. Las claves ya creadas con `organization:read` pueden usar este CRUD. Una clave solo con `packages:read` puede listar, no escribir.

`customers.create` recibe `CustomerCreate`. Cuenta `PERSONAL` pide `firstName` y cuenta `BUSINESS` pide `companyName`. No se envía `types`; el API lo guarda como `CLIENT`. `createContact: true` (o ausente) crea además un contacto `SHIPPER` con los mismos datos; `false` crea solo el cliente. `customers.update` recibe `CustomerWrite`. `contacts` es el contacto comercial y el cuerpo es `ContactWrite`. Su `types` sale de `contactTypes` (`SHIPPER`, `CONSIGNEE`, `CARRIER`, `FORWARDER`, `NOTIFY_PARTY`, `BROKER`, `IMPORTER`, `EXPORTER`, `AGENT`, `WAREHOUSE`). Si no se envía, queda `SHIPPER`. `clientId` lo vincula al cliente. Pasa `clientId: null` para desvincularlo. Las claves ya creadas con `organization:read` pueden usar este CRUD. La respuesta no incluye el id de autenticación ni la contraseña del portal.

La API también acepta la key en el header `X-Api-Key`; este SDK envía `Authorization: Bearer`.

### Entorno local

```dart
final traky = Traky(
  apiKey: Platform.environment['TRAKY_API_KEY']!,
  baseUrl: 'http://localhost:4000',
);
```

### Errores

```dart
import 'package:traky/traky.dart';

try {
  await traky.organization.retrieve();
} on TrakyApiException catch (error) {
  print('${error.status} ${error.message} ${error.body}');
}
```

## Desarrollo

```bash
dart pub get
dart analyze
dart test
```

Para añadir un recurso, crea una clase en `lib/src/resources/` y cuélgala de `Traky` en `lib/src/client.dart`. Las peticiones pasan por `TrakyHttp`.

Los ejemplos se corren con la API key en el entorno:

```bash
TRAKY_API_KEY=trk_… dart run example/main.dart
```

## Publicar

El paquete es público: `traky`. Se publica en pub.dev cuando se publica un release de GitHub.

Antes del release, deja la misma versión en `pubspec.yaml` y en `lib/src/version.dart`. El tag tiene que ser esa versión con `v` delante (`v1.1.4` para `1.1.4`). Al publicar el release, el workflow hace checkout de ese tag, comprueba que coincida y sube el paquete si esa versión aún no está en pub.dev. Un borrador no publica.

En pub.dev hay que crear el paquete y autorizar este repositorio (Automated publishing):

- Repositorio: `traky-app/traky-sdk-dart`
- Workflow: `publish.yml`
- Tag pattern: `v{{version}}`

`dart pub publish` corre después de `dart analyze` y `dart test`.
