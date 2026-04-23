import 'package:feyam_app/app/bootstrap.dart';
import 'package:feyam_app/core/config/app_flavor.dart';

Future<void> main() async {
  await bootstrap(flavor: AppFlavor.dev);
}
