import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geofencing_alarm/Service/background_service.dart';
import 'package:geofencing_alarm/full_map.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  const String mapboxAccessToken =
      'sk.eyJ1IjoiZXpoaWxhZGhhdmFuIiwiYSI6ImNseG4xM2Q1ZjBldDgybHNkbzJrbGprMWwifQ.MiNqk7annVoYrsWoHd0sDA';
  MapboxOptions.setAccessToken(mapboxAccessToken);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
      
      
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await _checkNotificationPermissions(flutterLocalNotificationsPlugin);

  await initializeService(); 

  runApp(MyApp(prefs: prefs));
}

Future<void> _checkNotificationPermissions(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  final bool? granted = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.areNotificationsEnabled();

  if (granted == false) {
    // Request permissions
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapbox Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FullMap(prefs: prefs),
    );
  }
}