import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeofenceServiceHandler {
  final GeofenceService _geofenceService = GeofenceService.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final List<Geofence> _geofenceList = [];
  CircleAnnotationManager? _circleAnnotationManager;
  final SharedPreferences prefs;

  GeofenceServiceHandler({required this.prefs}) {
    _initializeService();
  }

  void _initializeService() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
  }

  Future<void> addGeofence(
    MapboxMap mapboxMap,
    double latitude,
    double longitude,
    double radius, {
    required List<String> enterMessages,
  }) async {
    var geofence = Geofence(
      id: 'geofence_${latitude}_$longitude',
      latitude: latitude,
      longitude: longitude,
      radius: [
        GeofenceRadius(
          id: 'radius_${radius}_${latitude}_$longitude',
          length: radius,
        ),
      ],
    );

    _geofenceList.add(geofence);

    prefs.setStringList('enterMessages_${geofence.id}', enterMessages);

    for (String message in enterMessages) {
      _saveReminder(message);
    }

    try {
      await _geofenceService.start(_geofenceList);
      print('Geofence added successfully');
      await _drawCircle(mapboxMap, latitude, longitude, radius);
    } catch (error) {
      if (error.toString().contains('ErrorCodes.ALREADY_STARTED')) {
        _geofenceService.addGeofence(geofence);
        print('Geofence added successfully after service was already started');
        await _drawCircle(mapboxMap, latitude, longitude, radius);
      } else {
        print('Failed to add geofence: $error');
      }
    }
  }

  Future<void> _drawCircle(MapboxMap mapboxMap, double latitude,
      double longitude, double radius) async {
    _circleAnnotationManager ??=
        await mapboxMap.annotations.createCircleAnnotationManager();

    _circleAnnotationManager?.create(CircleAnnotationOptions(
      geometry: Point(
        coordinates: Position(
          longitude,
          latitude,
        ),
      ),
      circleColor: Colors.blue.value,
      circleRadius: radius,
      circleOpacity: 0.5,
    ));
  }

  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus status,
      Location location) async {
    print('Geofence status changed: ${status.toString()}');
    if (status == GeofenceStatus.ENTER) {
      print("Entered geofence: ${geofence.id}");

    //  _recordEntryTime(geofence.latitude, geofence.longitude);

      List<String> enterMessages =
          prefs.getStringList('enterMessages_${geofence.id}') ??
              ['You have entered the geofence'];
      int notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);
      for (String message in enterMessages) {
        print('Showing notification: $message');
        
        String currentTime = DateTime.now().toString();
        print("current time :$currentTime");
        await _showNotification('Entered Geofence:', message + currentTime, notificationId,);
        
        notificationId++;
        markReminderAsDone(message);
      }
    }
  }

  void _recordEntryTime(double latitude, double longitude) {
    String geofenceId = 'geofence_${latitude}_$longitude';
    List<String> entryTimes =
        prefs.getStringList('entryTimes_$geofenceId') ?? [];

    String currentTime = DateTime.now().toString();
    entryTimes.add(currentTime);

    prefs.setStringList('entryTimes_$geofenceId', entryTimes);
    _incrementEntryCount(geofenceId);
  }

  void _incrementEntryCount(String geofenceId) {
    int entryCount = prefs.getInt('entryCount_$geofenceId') ?? 0;
    entryCount++;
    prefs.setInt('entryCount_$geofenceId', entryCount);
  }

  Future<void> _showNotification(
      String title, String body, int notificationId) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'geofence_channel',
        'Geofence Notifications',
        channelDescription: 'Notifications for geofence events',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: 'item x',
      );
      print('Notification shown: $title - $body');
    } catch (e) {
      print('Failed to show notification: $e');
    }
  }

  void _saveReminder(String reminder) {
    List<String> reminders = prefs.getStringList('reminders') ?? [];
    if (!reminders.contains(reminder)) {
      reminders.add(reminder);
      prefs.setStringList('reminders', reminders);
    }
  }

  void markReminderAsDone(String reminder) {
    List<String> reminders = prefs.getStringList('reminders') ?? [];
    if (reminders.contains(reminder)) {
      reminders.remove(reminder);
      prefs.setStringList('reminders', reminders);

      List<String> doneReminders = prefs.getStringList('doneReminders') ?? [];
      doneReminders.add(reminder);
      prefs.setStringList('doneReminders', doneReminders);
    }
  }

  List<String> getDoneReminders() {
    return prefs.getStringList('doneReminders') ?? [];
  }

  List<String> getReminders() {
    return prefs.getStringList('reminders') ?? [];
  }

  int getEntryCount(double latitude, double longitude) {
    String geofenceId = 'geofence_${latitude}_$longitude';
    return prefs.getInt('entryCount_$geofenceId') ?? 0;
  }
}
