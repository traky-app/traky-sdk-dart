import 'traky.dart';

Future<void> main() async {
  final traky = trakyFromEnvironment();
  final all = await traky.statuses.list();
  print('${all.data.length} estados');

  final packages = await traky.statuses.list(category: StatusCategory.package);
  for (final status in packages.data) {
    print('${status.position} ${status.label} ${status.id}');
  }
  traky.close();
}
