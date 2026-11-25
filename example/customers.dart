import 'traky.dart';

Future<void> main() async {
  final traky = trakyFromEnvironment();
  final page = await traky.customers.list(
    limit: 5,
    types: [CustomerType.client],
  );
  print('${page.pagination.limit} por página');

  // Cédula y RUC: solo el número. El API completa el nombre y, si no
  // pasas createContact: false, también el contacto SHIPPER.
  // Pasaporte: el nombre y el apellido sí se envían.
  final created = await traky.customers.create(
    CustomerCreate(
      identityType: 'PASSPORT',
      identityNumber: 'A1234567',
      firstName: 'Ana',
      lastName: 'Paz',
      email: 'ana-${DateTime.now().millisecondsSinceEpoch}@example.com',
    ),
  );
  final loaded = await traky.customers.retrieve(created.id);
  await traky.customers.update(loaded.id, CustomerWrite(city: 'Quito'));
  traky.close();
}
