import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:altrupets/core/models/user_model.dart';
import 'package:altrupets/core/network/http_client_service.dart';
import 'package:altrupets/core/storage/secure_storage_service.dart';

/// Service for geolocation capture and management
/// Acts as a CLIENT of backend - captures location and sends to backend
class GeoLocationService {
  GeoLocationService({
    required HttpClientService httpClient,
    required SecureStorageService secureStorage,
  }) : _httpClient = httpClient,
       _secureStorage = secureStorage;
  final HttpClientService _httpClient;
  final SecureStorageService _secureStorage;

  // Cache keys
  static const String _lastLocationKey = 'last_known_location';
  static const String _locationTimestampKey = 'location_timestamp';

  // Cache expiration: 1 hour
  static const Duration _cacheExpiration = Duration(hours: 1);

  /// Get current GPS location
  /// Returns Position with latitude, longitude, accuracy, etc.
  Future<Position> getCurrentLocation() async {
    // Check if location services are enabled
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException(
        'Location services are disabled. Please enable location services.',
      );
    }

    // Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException(
          'Location permissions are denied',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionDeniedException(
        'Location permissions are permanently denied. Please enable them in settings.',
      );
    }

    // Get current position with high accuracy
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    // Cache location for offline use
    await _cacheLocation(position);

    return position;
  }

  /// Get current location and automatically convert to address
  /// Returns both Position and address information
  Future<LocationWithAddress?> getCurrentLocationWithAddress() async {
    final position = await getCurrentLocation();
    final address = await getAddressFromCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (address == null) {
      return null;
    }

    return LocationWithAddress(position: position, address: address);
  }

  /// Get last known location from cache
  /// Returns null if cache is expired or doesn't exist
  Future<Position?> getLastKnownLocation() async {
    try {
      final locationJson = await _secureStorage.read(key: _lastLocationKey);
      final timestampStr = await _secureStorage.read(
        key: _locationTimestampKey,
      );

      if (locationJson == null || timestampStr == null) {
        return null;
      }

      // Check if cache is expired
      final timestamp = DateTime.parse(timestampStr);
      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        return null;
      }

      final locationData = json.decode(locationJson);
      return Position(
        latitude: (locationData['latitude'] as num).toDouble(),
        longitude: (locationData['longitude'] as num).toDouble(),
        timestamp: timestamp,
        accuracy: (locationData['accuracy'] as num).toDouble(),
        altitude: (locationData['altitude'] as num).toDouble(),
        heading: (locationData['heading'] as num).toDouble(),
        speed: (locationData['speed'] as num).toDouble(),
        speedAccuracy: (locationData['speedAccuracy'] as num).toDouble(),
        altitudeAccuracy:
            (locationData['altitudeAccuracy'] as num?)?.toDouble() ?? 0.0,
        headingAccuracy:
            (locationData['headingAccuracy'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      return null;
    }
  }

  /// Update user location in backend
  /// Sends latitude/longitude to backend via GraphQL mutation
  Future<UserModel> updateUserLocation({
    required double latitude,
    required double longitude,
  }) async {
    const mutation = r'''
      mutation UpdateUserLocation($latitude: Float!, $longitude: Float!) {
        updateUserProfile(input: { latitude: $latitude, longitude: $longitude }) {
          id
          username
          email
          firstName
          lastName
          phone
          identification
          country
          province
          canton
          district
          bio
          organizationId
          latitude
          longitude
          isActive
          isVerified
          createdAt
          updatedAt
        }
      }
    ''';

    final response = await _httpClient.post<Map<String, dynamic>>(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {'latitude': latitude, 'longitude': longitude},
      },
    );

    if (response.data?['errors'] != null) {
      throw Exception(
        'Failed to update location: ${response.data?['errors'][0]['message']}',
      );
    }

    return UserModel.fromJson(
      response.data?['data']['updateUserProfile'] as Map<String, dynamic>,
    );
  }

  /// Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permissions
  /// Returns true if granted, false otherwise
  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Open app settings for manual permission configuration
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Cache location for offline use
  Future<void> _cacheLocation(Position position) async {
    final locationData = {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'altitude': position.altitude,
      'heading': position.heading,
      'speed': position.speed,
      'speedAccuracy': position.speedAccuracy,
      'altitudeAccuracy': position.altitudeAccuracy,
      'headingAccuracy': position.headingAccuracy,
    };

    await _secureStorage.write(
      key: _lastLocationKey,
      value: json.encode(locationData),
    );
    await _secureStorage.write(
      key: _locationTimestampKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Calculate distance between two coordinates in kilometers
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert meters to kilometers
  }

  /// Check if location accuracy meets minimum requirements
  bool isAccuracyAcceptable(Position position, double minAccuracyMeters) {
    return position.accuracy <= minAccuracyMeters;
  }

  /// Convert coordinates to address (province, canton, district)
  /// Returns a map with province, canton, and district
  Future<Map<String, String>?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return null;
      }

      final placemark = placemarks.first;

      // For Costa Rica, the administrative areas map to:
      // administrative = Province
      // subAdministrative = Canton
      // locality = District (often)

      return {
        'country': placemark.country ?? '',
        'province': placemark.administrativeArea ?? '',
        'canton': placemark.subAdministrativeArea ?? '',
        'district': placemark.locality ?? placemark.subLocality ?? '',
        'street': placemark.street ?? '',
      };
    } catch (e) {
      return null;
    }
  }
}

/// Exception thrown when location services are disabled
class LocationServiceDisabledException implements Exception {
  LocationServiceDisabledException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when location permissions are denied
class LocationPermissionDeniedException implements Exception {
  LocationPermissionDeniedException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Container for location with address information
class LocationWithAddress {
  LocationWithAddress({required this.position, required this.address});

  final Position position;
  final Map<String, String> address;

  String get province => address['province'] ?? '';
  String get canton => address['canton'] ?? '';
  String get district => address['district'] ?? '';
  String get country => address['country'] ?? '';
  String get street => address['street'] ?? '';
}
