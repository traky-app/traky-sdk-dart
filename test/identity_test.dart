import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:traky/traky.dart';

Traky recording(List<String?> bodies) {
  return Traky(
    apiKey: 'trk_test',
    httpClient: MockClient((request) async {
      bodies.add(request.body.isEmpty ? null : request.body);
      return http.Response(
        jsonEncode({'id': 'cus_1', 'types': ['CLIENT']}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }),
  );
}

Traky blocked() {
  return Traky(
    apiKey: 'trk_test',
    httpClient: MockClient((_) async => throw StateError('no debe llamar al API')),
  );
}

void main() {
  test('clasifica cédula, RUC, pasaporte y el resto', () {
    expect(identityKind('cedula'), IdentityKind.cedula);
    expect(identityKind('EC_CEDULA'), IdentityKind.cedula);
    expect(identityKind('Cédula'), IdentityKind.cedula);
    expect(identityKind('ruc'), IdentityKind.ruc);
    expect(identityKind('EC_RUC'), IdentityKind.ruc);
    expect(identityKind('PASSPORT'), IdentityKind.passport);
    expect(identityKind('pasaporte'), IdentityKind.passport);
    expect(identityKind('DNI'), IdentityKind.other);
    expect(identityKind(''), isNull);
    expect(identityKind(null), isNull);
  });

  test('no deja enviar nombres con cédula o RUC', () async {
    final cases = [
      CustomerCreate(
        identityType: 'CEDULA',
        identityNumber: '1710034065',
        firstName: 'Ana',
      ),
      CustomerCreate(
        identityType: 'CEDULA',
        identityNumber: '1710034065',
        lastName: 'Paz',
      ),
      CustomerCreate(
        identityType: 'EC_CEDULA',
        identityNumber: '1710034065',
        companyName: 'ACME',
      ),
      CustomerCreate(
        identityType: 'RUC',
        identityNumber: '1790012345001',
        companyName: 'ACME',
      ),
      CustomerCreate(
        identityType: 'EC_RUC',
        identityNumber: '1790012345001',
        firstName: 'ACME',
      ),
    ];

    for (final body in cases) {
      await expectLater(blocked().customers.create(body), throwsA(isA<TrakyException>()));
      await expectLater(
        blocked().customers.update('cus_1', body),
        throwsA(isA<TrakyException>()),
      );
    }
  });

  test('envía la cédula sola para que el API cree el contacto', () async {
    final bodies = <String?>[];
    await recording(bodies).customers.create(
      CustomerCreate(
        identityType: 'CEDULA',
        identityNumber: '1710034065',
        email: 'ana@example.com',
      ),
    );
    expect(jsonDecode(bodies.single!), {
      'identityType': 'CEDULA',
      'identityNumber': '1710034065',
      'email': 'ana@example.com',
    });
  });

  test('puede omitir el contacto automático en un RUC', () async {
    final bodies = <String?>[];
    await recording(bodies).customers.create(
      CustomerCreate(
        identityType: 'RUC',
        identityNumber: '1790012345001',
        createContact: false,
      ),
    );
    expect(jsonDecode(bodies.single!), {
      'identityType': 'RUC',
      'identityNumber': '1790012345001',
      'createContact': false,
    });
  });

  test('pide 10 dígitos en la cédula y 13 en el RUC', () async {
    await expectLater(
      blocked().customers.create(
        CustomerCreate(identityType: 'CEDULA', identityNumber: '171'),
      ),
      throwsA(isA<TrakyException>().having((error) => error.message, 'message', contains('10 dígitos'))),
    );
    await expectLater(
      blocked().customers.create(CustomerCreate(identityType: 'RUC')),
      throwsA(isA<TrakyException>().having((error) => error.message, 'message', contains('obligatorio'))),
    );
    await expectLater(
      blocked().customers.create(
        CustomerCreate(identityType: 'RUC', identityNumber: '179001234500'),
      ),
      throwsA(isA<TrakyException>().having((error) => error.message, 'message', contains('13 dígitos'))),
    );
  });

  test('exige nombre y apellido en el pasaporte', () async {
    await expectLater(
      blocked().customers.create(
        CustomerCreate(identityType: 'PASSPORT', identityNumber: 'A1234567'),
      ),
      throwsA(isA<TrakyException>().having(
        (error) => error.message,
        'message',
        contains('firstName y lastName'),
      )),
    );
    await expectLater(
      blocked().customers.create(
        CustomerCreate(
          identityType: 'PASAPORTE',
          identityNumber: 'A1234567',
          firstName: 'Ana',
          lastName: 'Paz',
          companyName: 'ACME',
        ),
      ),
      throwsA(isA<TrakyException>().having(
        (error) => error.message,
        'message',
        contains('companyName'),
      )),
    );
    await expectLater(
      blocked().customers.create(
        CustomerCreate(
          identityType: 'PASSPORT',
          identityNumber: 'A12',
          firstName: 'Ana',
          lastName: 'Paz',
        ),
      ),
      throwsA(isA<TrakyException>().having(
        (error) => error.message,
        'message',
        contains('entre 5 y 20'),
      )),
    );
  });

  test('envía el pasaporte con nombre y apellido', () async {
    final bodies = <String?>[];
    await recording(bodies).customers.create(
      CustomerCreate(
        identityType: 'PASSPORT',
        identityNumber: 'A1234567',
        firstName: 'Ana',
        lastName: 'Paz',
        email: 'ana@example.com',
      ),
    );
    final body = jsonDecode(bodies.single!) as Map<String, Object?>;
    expect(body['firstName'], 'Ana');
    expect(body['lastName'], 'Paz');
    expect(body.containsKey('createContact'), isFalse);
  });

  test('deja pasar un DNI y un alta sin documento', () async {
    final bodies = <String?>[];
    final client = recording(bodies);
    await client.customers.create(
      CustomerCreate(identityType: 'DNI', identityNumber: '12345678', firstName: 'Ana'),
    );
    await client.customers.create(
      CustomerCreate(firstName: 'Ana', createContact: true),
    );
    expect(jsonDecode(bodies[1]!), {'firstName': 'Ana', 'createContact': true});
  });

  test('en un update sin tipo no bloquea el nombre', () {
    expect(
      () => assertCustomerIdentityWrite(creating: false, firstName: 'Ana'),
      returnsNormally,
    );
  });

  test('en un update a cédula vuelve a exigir solo el número', () async {
    final bodies = <String?>[];
    await recording(bodies).customers.update(
      'cus_1',
      CustomerWrite(
        identityType: 'CEDULA',
        identityNumber: '1710034065',
        city: 'Quito',
      ),
    );
    expect(jsonDecode(bodies.single!), {
      'identityType': 'CEDULA',
      'identityNumber': '1710034065',
      'city': 'Quito',
    });
  });

  test('trata espacios como nombre vacío en cédula', () {
    expect(
      () => assertCustomerIdentityWrite(
        creating: true,
        identityType: 'CEDULA',
        identityNumber: '1710034065',
        firstName: '   ',
        lastName: '',
        companyName: null,
      ),
      returnsNormally,
    );
  });
}
