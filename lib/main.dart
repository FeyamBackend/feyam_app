import 'package:feyam/app/bootstrap.dart';
import 'package:feyam/core/config/app_flavor.dart';

Future<void> main() async {
  await bootstrap(flavor: AppFlavor.prod);
}
