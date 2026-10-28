import 'traky.dart';

Future<void> main() async {
  final traky = trakyFromEnvironment();
  final listed = await traky.packages.list();
  print('${listed.total} paquetes');

  final misiil = await traky.packages.listFromMisiil();
  print('${misiil.total} paquetes de Misiil');

  final statuses = await traky.statuses.list(category: StatusCategory.package);
  final offices = await traky.offices.list();
  final status = statuses.data.where((row) => row.isActive).firstOrNull ??
      statuses.data.firstOrNull;
  final office = offices.data.where((row) => row.isActive).firstOrNull ??
      offices.data.firstOrNull;
  if (status == null || office == null) {
    throw StateError('Hace falta un estado de paquete y una sucursal.');
  }

  final created = await traky.packages.create(
    PackageCreate(
      registrationDate: DateTime.now().toUtc().toIso8601String(),
      trackingNumber: 'SDK${DateTime.now().millisecondsSinceEpoch}',
      itemStatusId: status.id,
      locationId: office.id,
      weight: 1,
      comments: 'Ejemplo del SDK',
    ),
  );
  print('${created.receiptNumber} ${created.packageNumber}');

  final one = await traky.packages.retrieve(created.id);
  await traky.packages.update(
    one.id,
    PackageWrite(warehouseComments: 'Ejemplo SDK'),
  );
  await traky.packages.delete(one.id);
  traky.close();
}
