import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:traky/traky.dart';

const organization = {
  'id': 'ent_1',
  'name': 'Demo',
  'slug': 'demo',
  'enterpriseCode': 'DM',
  'countryCode': 'EC',
  'currency': 'USD',
  'organizationId': 'org_1',
};

http.Response jsonResponse(Object? body, [int status = 200]) {
  return http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );
}

Traky clientWith(
  Future<http.Response> Function(http.Request request) handler, {
  String? baseUrl,
  Duration? timeout,
  Map<String, String>? headers,
  String apiKey = 'trk_test',
}) {
  return Traky(
    apiKey: apiKey,
    baseUrl: baseUrl,
    timeout: timeout ?? const Duration(seconds: 30),
    headers: headers,
    httpClient: MockClient(handler),
  );
}

void main() {
  test('exige api key', () {
    expect(() => Traky(apiKey: '   '), throwsA(isA<TrakyException>()));
  });

  test('pide la organización con Bearer y sin barra final', () async {
    final client = clientWith(baseUrl: 'https://api.traky.app/', (
      request,
    ) async {
      expect(request.url.toString(),
          'https://api.traky.app/org-api/v1/organization');
      expect(request.headers['authorization'], 'Bearer trk_test');
      expect(request.headers['user-agent'], startsWith('traky/'));
      return jsonResponse(organization);
    });

    final loaded = await client.organization.retrieve();
    expect(loaded.id, 'ent_1');
    expect(loaded.name, 'Demo');
    expect(loaded.slug, 'demo');
    expect(loaded.enterpriseCode, 'DM');
    expect(loaded.countryCode, 'EC');
    expect(loaded.currency, 'USD');
    expect(loaded.organizationId, 'org_1');
  });

  test('recorre todas las funciones del SDK', () async {
    final calls = <String>[];
    final client = clientWith((request) async {
      calls.add('${request.method} ${request.url.path}${_query(request.url)}');
      return jsonResponse({
        'id': 'res_1',
        'data': <Object?>[],
        'total': 0,
        'exportedAt': '2026-10-27T00:00:00.000Z',
        'source': 'misiil',
        'pagination': {'limit': 50},
        'deleted': true,
        'deletedCount': 1,
      });
    });

    await client.organization.retrieve();
    await client.statuses.list();
    await client.statuses.list(category: StatusCategory.package);
    await client.offices.list();
    await client.warehouses.list();
    await client.packages.list();
    await client.packages.listFromMisiil();
    await client.packages.retrieve('pkg_1');
    await client.packages.create(
      PackageCreate(
        registrationDate: '2026-10-27T00:00:00.000Z',
        trackingNumber: '1Z999',
        itemStatusId: 'st_1',
        locationId: 'loc_1',
      ),
    );
    await client.packages
        .update('pkg_1', PackageWrite(warehouseComments: 'Nota'));
    await client.packages.delete('pkg_1');
    await client.receipts.list();
    await client.receipts.retrieve('pkg_1');
    await client.receipts.create(
      ReceiptCreate(
        registrationDate: '2026-10-27T00:00:00.000Z',
        locationId: 'loc_1',
        itemStatusId: 'st_1',
        packages: [ReceiptPackageLine(trackingNumber: '1Z111')],
      ),
    );
    await client.receipts.update('pkg_1', ReceiptUpdate(comments: 'Ropa'));
    await client.receipts.delete('pkg_1');
    await client.customers.list();
    await client.customers.retrieve('cus_1');
    await client.customers.create(
      CustomerCreate(firstName: 'Ana', createContact: false),
    );
    await client.customers.update('cus_1', CustomerWrite(lastName: 'Paz'));
    await client.customers.delete('cus_1');
    await client.contacts.list();
    await client.contacts.retrieve('con_1');
    await client.contacts.create(
      ContactWrite(firstName: 'Luis', types: [ContactType.shipper]),
    );
    await client.contacts.update(
      'con_1',
      ContactWrite(types: [ContactType.consignee]),
    );
    await client.contacts.delete('con_1');

    expect(calls, [
      'GET /org-api/v1/organization',
      'GET /org-api/v1/statuses',
      'GET /org-api/v1/statuses?category=package',
      'GET /org-api/v1/offices',
      'GET /org-api/v1/offices?type=warehouse',
      'GET /org-api/v1/packages',
      'GET /org-api/v1/marketplaces/misiil/packages',
      'GET /org-api/v1/packages/pkg_1',
      'POST /org-api/v1/packages',
      'PATCH /org-api/v1/packages/pkg_1',
      'DELETE /org-api/v1/packages/pkg_1',
      'GET /org-api/v1/receipts',
      'GET /org-api/v1/receipts/pkg_1',
      'POST /org-api/v1/receipts',
      'PATCH /org-api/v1/receipts/pkg_1',
      'DELETE /org-api/v1/receipts/pkg_1',
      'GET /org-api/v1/customers',
      'GET /org-api/v1/customers/cus_1',
      'POST /org-api/v1/customers',
      'PATCH /org-api/v1/customers/cus_1',
      'DELETE /org-api/v1/customers/cus_1',
      'GET /org-api/v1/contacts',
      'GET /org-api/v1/contacts/con_1',
      'POST /org-api/v1/contacts',
      'PATCH /org-api/v1/contacts/con_1',
      'DELETE /org-api/v1/contacts/con_1',
    ]);
  });

  test('exporta paquetes y paquetes de Misiil', () async {
    final paths = <String>[];
    final client = clientWith((request) async {
      paths.add(request.url.path);
      if (request.url.path.endsWith('/marketplaces/misiil/packages')) {
        return jsonResponse({
          'data': <Object?>[],
          'total': 0,
          'exportedAt': '2026-10-24T00:00:00.000Z',
          'source': 'misiil',
        });
      }
      return jsonResponse({
        'data': <Object?>[],
        'total': 0,
        'exportedAt': '2026-10-24T00:00:00.000Z',
      });
    });

    await client.packages.list();
    final misiil = await client.packages.listFromMisiil();
    expect(paths, [
      '/org-api/v1/packages',
      '/org-api/v1/marketplaces/misiil/packages',
    ]);
    expect(misiil.source, 'misiil');
  });

  test('hace el CRUD de paquetes y de recibos', () async {
    final calls = <({String method, String url, String? body})>[];
    final client = clientWith((request) async {
      calls.add((
        method: request.method,
        url: '${request.url.path}${_query(request.url)}',
        body: request.body.isEmpty ? null : request.body,
      ));
      return jsonResponse({
        'id': 'pkg_1',
        'deleted': true,
        'deletedCount': 2,
        'data': <Object?>[],
        'pagination': {'limit': 50},
      });
    });

    await client.packages.retrieve('pkg 1');
    await client.packages.create(
      PackageCreate(
        registrationDate: '2026-10-27T00:00:00.000Z',
        trackingNumber: '1Z999',
        itemStatusId: 'st_1',
        locationId: 'loc_1',
      ),
    );
    await client.packages.update(
      'pkg_1',
      PackageWrite(warehouseComments: 'Retener'),
    );
    await client.packages.delete('pkg_1');
    await client.receipts.list(page: 2, trackingNumber: 'WR0000008');
    await client.receipts.retrieve('pkg_1');
    await client.receipts.create(
      ReceiptCreate(
        registrationDate: '2026-10-27T00:00:00.000Z',
        locationId: 'loc_1',
        itemStatusId: 'st_1',
        packages: [
          ReceiptPackageLine(trackingNumber: '1Z111'),
          ReceiptPackageLine(trackingNumber: '1Z222'),
        ],
      ),
    );
    await client.receipts.update(
      'pkg_1',
      ReceiptUpdate(
        warehouseComments: 'Frágil',
        packages: [ReceiptPackagePatch(id: 'pkg_2', weight: 4)],
      ),
    );
    await client.receipts.delete('pkg_1');

    expect(calls.map((call) => '${call.method} ${call.url}').toList(), [
      'GET /org-api/v1/packages/pkg%201',
      'POST /org-api/v1/packages',
      'PATCH /org-api/v1/packages/pkg_1',
      'DELETE /org-api/v1/packages/pkg_1',
      'GET /org-api/v1/receipts?page=2&trackingNumber=WR0000008',
      'GET /org-api/v1/receipts/pkg_1',
      'POST /org-api/v1/receipts',
      'PATCH /org-api/v1/receipts/pkg_1',
      'DELETE /org-api/v1/receipts/pkg_1',
    ]);
    expect(jsonDecode(calls[1].body!), {
      'registrationDate': '2026-10-27T00:00:00.000Z',
      'trackingNumber': '1Z999',
      'itemStatusId': 'st_1',
      'locationId': 'loc_1',
    });
    expect(calls[6].body, contains('"trackingNumber":"1Z111"'));
    expect(jsonDecode(calls[7].body!), {
      'warehouseComments': 'Frágil',
      'packages': [
        {'id': 'pkg_2', 'weight': 4},
      ],
    });
  });

  test('hace el CRUD de clientes y contactos', () async {
    final calls = <({String method, String url, String? body})>[];
    final client = clientWith((request) async {
      calls.add((
        method: request.method,
        url: '${request.url.path}${_query(request.url)}',
        body: request.body.isEmpty ? null : request.body,
      ));
      return jsonResponse({
        'id': 'cus_1',
        'data': <Object?>[],
        'pagination': {'limit': 50},
        'deleted': true,
      });
    });

    await client.customers.list(
      page: 2,
      isActive: true,
      types: [CustomerType.client, CustomerType.shipper],
    );
    await client.customers.retrieve('cus 1');
    await client.customers.create(CustomerCreate(firstName: 'Ana'));
    await client.customers.update('cus_1', CustomerWrite(lastName: 'Paz'));
    await client.customers.delete('cus_1');
    await client.contacts.list(linked: false, clientId: 'cus_1');
    await client.contacts.create(
      ContactWrite(firstName: 'Luis', clientId: 'cus_1'),
    );
    await client.contacts.update('con_1', ContactWrite(clientId: null));
    await client.contacts.retrieve('con_1');
    await client.contacts.delete('con_1');

    expect(calls.map((call) => '${call.method} ${call.url}').toList(), [
      'GET /org-api/v1/customers?isActive=true&types=CLIENT%2CSHIPPER&page=2',
      'GET /org-api/v1/customers/cus%201',
      'POST /org-api/v1/customers',
      'PATCH /org-api/v1/customers/cus_1',
      'DELETE /org-api/v1/customers/cus_1',
      'GET /org-api/v1/contacts?clientId=cus_1&linked=false',
      'POST /org-api/v1/contacts',
      'PATCH /org-api/v1/contacts/con_1',
      'GET /org-api/v1/contacts/con_1',
      'DELETE /org-api/v1/contacts/con_1',
    ]);
    expect(jsonDecode(calls[2].body!), {'firstName': 'Ana'});
    expect(jsonDecode(calls[7].body!), {'clientId': null});
  });

  test('traduce el error de Nest', () async {
    final client = clientWith(
      apiKey: 'trk_invalid',
      (_) async => jsonResponse({
        'statusCode': 401,
        'message': 'API key inválida, revocada o sin empresa vinculada',
        'error': 'Unauthorized',
      }, 401),
    );

    await expectLater(
      client.organization.retrieve(),
      throwsA(
        isA<TrakyApiException>()
            .having((error) => error.status, 'status', 401)
            .having(
              (error) => error.message,
              'message',
              'API key inválida, revocada o sin empresa vinculada',
            ),
      ),
    );
  });

  test('une mensajes de validación y usa el status si no hay cuerpo', () async {
    final validation = clientWith(
      (_) async => jsonResponse({
        'message': ['firstName es obligatorio', '  ', 'email inválido'],
      }, 400),
    );
    final empty = clientWith((_) async => http.Response('', 502));
    final plain = clientWith((_) async => http.Response('no json', 502));
    final named = clientWith(
      (_) async => jsonResponse({'error': 'Unauthorized'}, 401),
    );

    await expectLater(
      validation.organization.retrieve(),
      throwsA(
        isA<TrakyApiException>().having(
          (error) => error.message,
          'message',
          'firstName es obligatorio; email inválido',
        ),
      ),
    );
    await expectLater(
      empty.organization.retrieve(),
      throwsA(
        isA<TrakyApiException>().having(
          (error) => error.message,
          'message',
          'Traky respondió 502.',
        ),
      ),
    );
    await expectLater(
      plain.organization.retrieve(),
      throwsA(
        isA<TrakyApiException>().having(
          (error) => error.message,
          'message',
          'Traky respondió 502.',
        ),
      ),
    );
    await expectLater(
      named.organization.retrieve(),
      throwsA(
        isA<TrakyApiException>().having(
          (error) => error.message,
          'message',
          'Unauthorized',
        ),
      ),
    );
  });

  test('no deja que un header extra reemplace Authorization', () async {
    final client = clientWith(
      headers: {
        'Authorization': 'Bearer otro',
        'Content-Type': 'text/plain',
        'X-Request-Id': 'req_1',
      },
      (request) async {
        expect(request.headers['authorization'], 'Bearer trk_test');
        expect(request.headers['content-type'], 'application/json');
        expect(request.headers['x-request-id'], 'req_1');
        return jsonResponse({'id': 'pkg_1'});
      },
    );

    await client.packages.create(
      PackageCreate(
        registrationDate: '2026-10-27T00:00:00.000Z',
        trackingNumber: '1Z999',
        itemStatusId: 'st_1',
        locationId: 'loc_1',
        receiptSerialNumber: 1204,
        receiptPackageIndex: 2,
      ),
    );
  });

  test('agrega P2 a un recibo y borra solo ese paquete', () async {
    final calls = <({String method, String url, String? body})>[];
    final client = clientWith((request) async {
      calls.add((
        method: request.method,
        url: request.url.path,
        body: request.body.isEmpty ? null : request.body,
      ));
      if (request.method == 'DELETE') {
        return jsonResponse({'id': 'pkg_2', 'deleted': true});
      }
      return jsonResponse({
        'id': 'pkg_2',
        'packageNumber': 'WR00001204P2',
        'receiptNumber': 'WR00001204',
      });
    });

    final created = await client.packages.create(
      PackageCreate(
        registrationDate: '2026-10-27T00:00:00.000Z',
        trackingNumber: '1Z222',
        itemStatusId: 'st_1',
        locationId: 'loc_1',
        receiptSerialNumber: 1204,
        receiptPackageIndex: 2,
        weight: 3,
        comments: 'Ropa',
      ),
    );
    final removed = await client.packages.delete(created.id);

    expect(created.packageNumber, 'WR00001204P2');
    expect(removed.id, 'pkg_2');
    expect(removed.deleted, isTrue);
    expect(calls.map((call) => '${call.method} ${call.url}').toList(), [
      'POST /org-api/v1/packages',
      'DELETE /org-api/v1/packages/pkg_2',
    ]);
    expect(jsonDecode(calls[0].body!), {
      'registrationDate': '2026-10-27T00:00:00.000Z',
      'trackingNumber': '1Z222',
      'receiptPackageIndex': 2,
      'receiptSerialNumber': 1204,
      'weight': 3,
      'itemStatusId': 'st_1',
      'locationId': 'loc_1',
      'comments': 'Ropa',
    });
    expect(calls[1].body, isNull);
  });

  test('lista estados, sucursales y bodegas', () async {
    final paths = <String>[];
    final client = clientWith((request) async {
      paths.add('${request.method} ${request.url.path}${_query(request.url)}');
      return jsonResponse({'data': <Object?>[]});
    });

    await client.statuses.list();
    await client.statuses.list(category: StatusCategory.shipment);
    await client.offices.list();
    await client.offices.list(type: OfficeType.office);
    await client.warehouses.list();
    expect(paths, [
      'GET /org-api/v1/statuses',
      'GET /org-api/v1/statuses?category=shipment',
      'GET /org-api/v1/offices',
      'GET /org-api/v1/offices?type=office',
      'GET /org-api/v1/offices?type=warehouse',
    ]);
  });

  test('envía clientId null para desvincular', () async {
    String? body;
    final client = clientWith((request) async {
      body = request.body;
      return jsonResponse({
        'id': 'con_1',
        'data': <Object?>[],
        'pagination': {'limit': 50}
      });
    });

    await client.contacts.update('con_1', ContactWrite(clientId: null));
    expect(jsonDecode(body!), {'clientId': null});
  });

  test('falla si la petición expira', () async {
    final client = Traky(
      apiKey: 'trk_test',
      timeout: const Duration(milliseconds: 15),
      httpClient: _HangClient(),
    );

    await expectLater(
      client.packages.list(),
      throwsA(
        isA<TrakyException>().having(
          (error) => error.message,
          'message',
          contains('superó 15 ms'),
        ),
      ),
    );
  }, timeout: const Timeout(Duration(seconds: 2)));
}

String _query(Uri uri) {
  if (!uri.hasQuery) return '';
  return '?${uri.query}';
}

final class _HangClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return Completer<http.StreamedResponse>().future;
  }
}
