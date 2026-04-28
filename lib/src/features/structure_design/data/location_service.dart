import 'package:geolocator/geolocator.dart';

abstract class LocationService {
  Future<double> getCurrentLatitude();
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<double> getCurrentLatitude() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Location service is disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission denied. Enter latitude manually.',
      );
    }

    final position = await Geolocator.getCurrentPosition();
    return position.latitude;
  }
}

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}
