import 'package:geolocator/geolocator.dart';

class LocationService {
  // Istanbul coordinates as fallback
  static const double _fallbackLat = 41.0082;
  static const double _fallbackLng = 28.9784;

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _getFallbackPosition();
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _getFallbackPosition();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _getFallbackPosition();
      }

      // If allowed, get real position
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      // Any error -> Fallback
      return _getFallbackPosition();
    }
  }

  Position _getFallbackPosition() {
    return Position(
      longitude: _fallbackLng,
      latitude: _fallbackLat,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }
}
