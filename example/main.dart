import 'traky.dart';

Future<void> main() async {
  final traky = trakyFromEnvironment();
  final organization = await traky.organization.retrieve();
  print('${organization.name} ${organization.slug}');

  final packages = await traky.packages.list();
  print('${packages.total} paquetes ${packages.exportedAt}');
  traky.close();
}
