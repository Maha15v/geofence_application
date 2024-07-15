import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntryTimesPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final SharedPreferences prefs;

  const EntryTimesPage({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.prefs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int entryCount = _getEntryCount(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text('Entry Times'),
      ),
      body: FutureBuilder<List<String>>(
        future: _getEntryTimes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<String>? entryTimes = snapshot.data;
            if (entryTimes != null && entryTimes.isNotEmpty) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Entry Count: $entryCount',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: entryTimes.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(entryTimes[index]),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text('No entry times recorded.'));
            }
          }
        },
      ),
    );
  }

  Future<List<String>> _getEntryTimes() async {
    return prefs.getStringList('entryTimes_${latitude}_${longitude}') ?? [];
  }

  int _getEntryCount(double latitude, double longitude) {
    String geofenceId = 'geofence_${latitude}_$longitude';
    return prefs.getInt('entryCount_$geofenceId') ?? 0;
  }
}
