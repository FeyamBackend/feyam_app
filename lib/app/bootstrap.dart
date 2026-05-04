import 'package:feyam/app/app.dart';
import 'package:feyam/core/config/app_config.dart';
import 'package:feyam/core/config/app_flavor.dart';
import 'package:feyam/core/di/injection_container.dart';
import 'package:flutter/material.dart';


Future<void> bootstrap({ required AppFlavor flavor }) async {
  var appConfig = AppConfig.fromFlavor(flavor);

  configureDependencies(appConfig: appConfig);
  runApp(const FeyamApp());
}