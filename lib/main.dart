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

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: const OrtodoxApp(),
    ),
  );
}
