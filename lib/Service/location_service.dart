// ignore_for_file: avoid_print

import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    var status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<geolocator.Position?> getUserLocation() async {
    bool serviceEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    geolocator.LocationPermission permission = await geolocator.Geolocator.checkPermission();
    if (permission == geolocator.LocationPermission.denied) {
      permission = await geolocator.Geolocator.requestPermission();
      if (permission == geolocator.LocationPermission.denied) {
        return null;
      }
    }

    if (permission == geolocator.LocationPermission.deniedForever) {
      return null;
    }

    return await geolocator.Geolocator.getCurrentPosition(
      desiredAccuracy: geolocator.LocationAccuracy.high,
    );
  }

  static Future<geolocator.Position?> initializeLocation() async {
    bool permissionGranted = await requestLocationPermission();
    if (permissionGranted) {
      return await getUserLocation();
    } else {
      print("Location permission denied");
      return null;
    }
  }
}
