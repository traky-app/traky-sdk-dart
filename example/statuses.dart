import 'traky.dart';

Future<void> main() async {
  final traky = trakyFromEnvironment();
  final all = await traky.statuses.list();
  print('${all.data.length} estados');

  final packages = await traky.statuses.list(category: StatusCategory.package);
  for (final status in packages.data) {
    print('${status.position} ${status.label} ${status.id}');
  }

  final created = await traky.statuses.create(
    StatusCreate(
      label: 'En bodega',
      description: 'El paquete está en la bodega',
      category: StatusCategory.package,
      icon: 'package',
      position: 2,
    ),
  );
  final loaded = await traky.statuses.retrieve(created.id);
  await traky.statuses.update(
    loaded.id,
    StatusWrite(isHiddenFromClient: true),
  );
  await traky.statuses.delete(loaded.id);
  traky.close();
}
