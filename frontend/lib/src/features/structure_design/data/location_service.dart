import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Represents a geographic location with latitude and longitude.
class GeoLocation {
  const GeoLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  /// Returns true if this location is in the northern hemisphere.
  bool get isNorthernHemisphere => latitude >= 0;

  /// Returns true if this location is in the southern hemisphere.
  bool get isSouthernHemisphere => latitude < 0;

  /// Gets the absolute latitude value (0-90 degrees).
  double get absoluteLatitude => latitude.abs();

  @override
  String toString() => 'GeoLocation(lat: $latitude, lon: $longitude)';
}

abstract class LocationService {
  /// Gets the current latitude only (for backward compatibility).
  Future<double> getCurrentLatitude();

  /// Gets the full geographic location (latitude and longitude).
  Future<GeoLocation> getCurrentLocation();

  /// Checks if location services are enabled.
  Future<bool> isLocationServiceEnabled();

  /// Checks the current location permission status.
  Future<LocationPermission> checkPermission();

  /// Requests location permission from the user.
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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return GeoLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      throw LocationException(
        'Failed to get location: \$e',
        code: LocationErrorCode.unknown,
      );
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }
}

/// Error codes for location-related errors.
enum LocationErrorCode {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unknown,
}

class LocationException implements Exception {
  const LocationException(this.message, {this.code = LocationErrorCode.unknown});

  final String message;
  final LocationErrorCode code;

  @override
  String toString() => message;
}
