import 'traky.dart';

Future<void> main() async {
  final traky = trakyFromEnvironment();
  final customer = await traky.customers.create(
    CustomerCreate(
      identityType: 'PASSPORT',
      identityNumber: 'A1234567',
      firstName: 'Ana',
      lastName: 'Paz',
      email: 'ana-${DateTime.now().millisecondsSinceEpoch}@example.com',
      createContact: false,
    ),
  );

  final created = await traky.contacts.create(
    ContactWrite(
      accountType: AccountType.personal,
      firstName: 'Luis',
      types: [ContactType.shipper],
      clientId: customer.id,
    ),
  );
  final page = await traky.contacts.list(
    clientId: customer.id,
    types: [ContactType.shipper],
  );
  print(page.data.map((row) => row.types.map((type) => type.wire)).toList());

  final loaded = await traky.contacts.retrieve(created.id);
  await traky.contacts.update(
    loaded.id,
    ContactWrite(types: [ContactType.shipper, ContactType.consignee]),
  );
  traky.close();
}
