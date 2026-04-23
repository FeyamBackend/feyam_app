import 'package:feyam_app/core/config/app_config.dart';
import 'package:feyam_app/core/config/app_flavor.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

void configureDependencies({AppConfig? appConfig}) {
  if (sl.isRegistered<AppConfig>()) {
    return;
  }

  sl.registerLazySingleton<AppConfig>(
    () => appConfig ?? AppConfig.fromFlavor(AppFlavor.dev),
  );
  
}
