import 'traky.dart';

Future<void> main() async {
  final traky = trakyFromEnvironment();
  final offices = await traky.offices.list();
  for (final office in offices.data) {
    print('${office.type.wire} ${office.id} ${office.name} ${office.city}');
  }

  final warehouses = await traky.offices.list(type: OfficeType.warehouse);
  print(warehouses.data.firstOrNull?.pricePerPoundClient);
  traky.close();
}
