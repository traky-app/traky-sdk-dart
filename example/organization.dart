import 'traky.dart';

Future<void> main() async {
  final traky = trakyFromEnvironment();
  final organization = await traky.organization.retrieve();
  print('${organization.id} ${organization.name} ${organization.slug}');
  traky.close();
}
