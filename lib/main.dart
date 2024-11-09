import 'dart:io';

import 'package:aura_techwizard/views/AnalysisScreens/CombinedAnalysisScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
//mport 'package:aura_techwizard/keystroke_analysis.dart'; // Adjust path as necessary

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Update icon path if necessary

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  if (Platform.isAndroid) {
    // Request notifications permission on Android using permission_handler
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print("Notification permissions granted on Android.");
    } else {
      print("Notification permissions denied on Android.");
    }
  } else if (Platform.isIOS) {
    // Request notifications permission on iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications(); // Request notification permission here
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TextAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => AppUsageProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Alegreya',
        ),
        home: CombinedAnalysisScreen(),
      ),
    );
  }
}
