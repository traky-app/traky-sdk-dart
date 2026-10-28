import 'traky.dart';

Future<void> main() async {
  final traky = trakyFromEnvironment();
  final page = await traky.customers.list(
    limit: 5,
    types: [CustomerType.client],
  );
  print('${page.pagination.limit} por página');

  final created = await traky.customers.create(
    CustomerCreate(
      accountType: AccountType.personal,
      firstName: 'Ana',
      lastName: 'Paz',
      email: 'ana-${DateTime.now().millisecondsSinceEpoch}@example.com',
      createContact: false,
    ),
  );
  final loaded = await traky.customers.retrieve(created.id);
  await traky.customers.update(loaded.id, CustomerWrite(city: 'Quito'));
  await traky.customers.delete(loaded.id);
  traky.close();
}
