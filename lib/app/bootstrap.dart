import 'package:feyam/app/app.dart';
import 'package:feyam/core/config/app_config.dart';
import 'package:feyam/core/config/app_flavor.dart';
import 'package:feyam/core/config/firebase_options.dart';
import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/push/background_message_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> bootstrap({required AppFlavor flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: firebaseOptionsFor(flavor));
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  var appConfig = AppConfig.fromFlavor(flavor);

  configureDependencies(appConfig: appConfig);
  runApp(const FeyamApp());
}
