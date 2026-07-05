import 'dart:async';
import 'package:geolocator/geolocator.dart';

class GeoLocation {
  const GeoLocation({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
  bool get isNorthernHemisphere => latitude >= 0;
  bool get isSouthernHemisphere => latitude < 0;
  double get absoluteLatitude => latitude.abs();
  @override
  String toString() => 'GeoLocation(lat: $latitude, lon: $longitude)';
}

abstract class LocationService {
  Future<double> getCurrentLatitude();
  Future<GeoLocation> getCurrentLocation();
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<double> getCurrentLatitude() async {
    final location = await getCurrentLocation();
    return location.latitude;
  }

  @override
  Future<GeoLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Location services are disabled. Please enable GPS to get your location.',
        code: LocationErrorCode.serviceDisabled,
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(
        'Location permission denied. Please grant location permission to calculate optimal solar angles.',
        code: LocationErrorCode.permissionDenied,
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission permanently denied. Please enable location permission in app settings.',
        code: LocationErrorCode.permissionDeniedForever,
      );
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, timeLimit: Duration(seconds: 10)),
      );
      return GeoLocation(latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      throw LocationException('Failed to get location: $e', code: LocationErrorCode.unknown);
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() => Geolocator.requestPermission();
}

enum LocationErrorCode { serviceDisabled, permissionDenied, permissionDeniedForever, unknown }

class LocationException implements Exception {
  const LocationException(this.message, {this.code = LocationErrorCode.unknown});
  final String message;
  final LocationErrorCode code;
  @override
  String toString() => message;
}
