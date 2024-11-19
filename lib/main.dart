import 'dart:io';

import 'package:aura_techwizard/components/consts.dart';
import 'package:aura_techwizard/firebase_options.dart';
import 'package:aura_techwizard/resources/user_provider.dart';
import 'package:aura_techwizard/views/analysis_screens/analysis_screen.dart';
import 'package:aura_techwizard/views/auth_screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
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
  Gemini.init(apiKey: gemini_api_key);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppUsageProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TextAnalysisProvider(),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'Alegreya',
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    );
  }
}
