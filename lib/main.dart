import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'providers/app_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezones
  tz.initializeTimeZones();

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // Initialize provider before runApp to avoid race condition with null data
  final appProvider = AppProvider();
  await appProvider.init();

  runApp(
    ChangeNotifierProvider<AppProvider>.value(
      value: appProvider,
      child: const OrtodoxApp(),
    ),
  );
}
