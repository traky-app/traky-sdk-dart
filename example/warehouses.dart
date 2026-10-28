import 'traky.dart';

Future<void> main() async {
  final traky = trakyFromEnvironment();
  final warehouses = await traky.warehouses.list();
  for (final warehouse in warehouses.data) {
    print(
      '${warehouse.id} ${warehouse.name} ${warehouse.city} ${warehouse.pricePerPoundClient}',
    );
  }
  traky.close();
}
