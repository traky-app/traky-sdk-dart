import 'traky.dart';

Future<void> main() async {
  final traky = trakyFromEnvironment();
  final customer = await traky.customers.create(
    CustomerCreate(
      accountType: AccountType.personal,
      firstName: 'Ana',
      lastName: 'Paz',
      email: 'ana@example.com',
      // false: solo el cliente. true o ausente: también un contacto SHIPPER.
      createContact: false,
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
      types: [ContactType.shipper],
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

  await traky.contacts.delete(contact.id);
  await traky.customers.delete(updated.id);
  traky.close();
}
