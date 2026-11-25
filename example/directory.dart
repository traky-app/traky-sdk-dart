import 'traky.dart';

Future<void> main() async {
  final traky = trakyFromEnvironment();
  // true o ausente: el API crea el contacto SHIPPER con el nombre verificado.
  final customer = await traky.customers.create(
    CustomerCreate(
      identityType: 'PASSPORT',
      identityNumber: 'A1234567',
      firstName: 'Ana',
      lastName: 'Paz',
      email: 'ana@example.com',
    ),
  );
  final updated = await traky.customers.update(
    customer.id,
    CustomerWrite(city: 'Quito'),
  );

  final contact = await traky.contacts.create(
    ContactWrite(
      accountType: AccountType.personal,
      firstName: 'Luis',
      types: [ContactType.consignee],
      clientId: updated.id,
    ),
  );
  await traky.contacts.update(
    contact.id,
    ContactWrite(types: [ContactType.shipper, ContactType.consignee]),
  );

  final page = await traky.contacts.list(
    clientId: updated.id,
    types: [ContactType.shipper],
  );
  print(page.data.map((row) => row.types.map((type) => type.wire)).toList());
  traky.close();
}
