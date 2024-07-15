// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geofencing_alarm/Service/geofence_service.dart';

class ReminderListPage extends StatefulWidget {
  final SharedPreferences prefs;

  const ReminderListPage({super.key, required this.prefs});

  @override
  State createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  List<String> reminders = [];
  List<String> doneReminders = [];
  late GeofenceServiceHandler _geofenceServiceHandler;

  @override
  void initState() {
    super.initState();
    _geofenceServiceHandler = GeofenceServiceHandler(prefs: widget.prefs);
    _loadReminders();
  }

  void _loadReminders() {
    setState(() {
      reminders = _geofenceServiceHandler.getReminders();
      doneReminders = _geofenceServiceHandler.getDoneReminders();
    });
    print('Loaded reminders in _loadReminders: $reminders');
    print('Loaded done reminders in _loadReminders: $doneReminders');
  }

  void _markAsDone(int index) {
    String reminder = reminders[index];
    _geofenceServiceHandler.markReminderAsDone(reminder);
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    print('Reminders in build: $reminders');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
      ),
      body: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          String reminder = reminders[index];
          bool isDone = doneReminders.contains(reminder);

          return ListTile(
            title: Text(reminder),
            trailing: isDone
                ? const Icon(Icons.check, color: Colors.green)
                : IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      _markAsDone(index);
                    },
                  ),
          );
        },
      ),
    );
  }
}
