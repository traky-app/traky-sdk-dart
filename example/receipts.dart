import 'traky.dart';

Future<void> main() async {
  final traky = trakyFromEnvironment();
  final page = await traky.receipts.list(limit: 10);
  print('${page.data.length} recibos en esta página');

  final statuses = await traky.statuses.list(category: StatusCategory.package);
  final offices = await traky.offices.list();
  final status = statuses.data.where((row) => row.isActive).firstOrNull ??
      statuses.data.firstOrNull;
  final office = offices.data.where((row) => row.isActive).firstOrNull ??
      offices.data.firstOrNull;
  if (status == null || office == null) {
    throw StateError('Hace falta un estado de paquete y una sucursal.');
  }

  final stamp = DateTime.now().millisecondsSinceEpoch;
  final created = await traky.receipts.create(
    ReceiptCreate(
      registrationDate: DateTime.now().toUtc().toIso8601String(),
      locationId: office.id,
      itemStatusId: status.id,
      warehouseComments: 'Ejemplo SDK',
      packages: [
        ReceiptPackageLine(trackingNumber: 'SDK-A-$stamp', weight: 1),
        ReceiptPackageLine(trackingNumber: 'SDK-B-$stamp', weight: 2),
      ],
    ),
  );
  print('${created.receiptNumber} ${created.packageCount} paquetes');

  final loaded = await traky.receipts.retrieve(created.id);
  final packages = loaded.packages;
  final second = packages != null && packages.length > 1 ? packages[1] : null;
  await traky.receipts.update(
    loaded.id,
    ReceiptUpdate(
      comments: 'Ropa',
      packages: second == null
          ? null
          : [ReceiptPackagePatch(id: second.id, weight: 3)],
    ),
  );
  await traky.receipts.delete(loaded.id);
  traky.close();
}
