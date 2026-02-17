import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/http_client_service.dart';
import '../../features/onboarding/domain/services/registration_service.dart';

/// Provider for RegistrationService
final registrationServiceProvider = Provider<RegistrationService>((ref) {
  final httpClient = ref.watch(httpClientServiceProvider);
  return RegistrationService(httpClient: httpClient);
});
