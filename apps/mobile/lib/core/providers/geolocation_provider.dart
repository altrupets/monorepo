import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/geolocation_service.dart';
import '../network/http_client_service.dart';
import '../storage/secure_storage_service.dart';

/// Provider for GeoLocationService
final geoLocationServiceProvider = Provider<GeoLocationService>((ref) {
  final httpClient = ref.watch(httpClientServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);

  return GeoLocationService(
    httpClient: httpClient,
    secureStorage: secureStorage,
  );
});
