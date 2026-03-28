import 'dart:io';

import 'package:flutter/foundation.dart';

class DebugNetworkInfo {
  final String environment;
  final String platform;
  final String? deviceType;
  final String? connectionType;
  final String backendUrl;

  DebugNetworkInfo({
    required this.environment,
    required this.platform,
    required this.backendUrl,
    this.deviceType,
    this.connectionType,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('[Network] Environment: $environment');
    buffer.writeln('[Network] Platform: $platform');
    if (deviceType != null) {
      buffer.writeln('[Network] Device Type: $deviceType');
    }
    if (connectionType != null) {
      buffer.writeln('[Network] Connection: $connectionType');
    }
    buffer.write('[Network] Backend URL: $backendUrl');
    return buffer.toString();
  }
}

class NetworkUtils {
  NetworkUtils._();

  static String getBackendUrl({String? overrideUrl}) {
    if (overrideUrl != null && overrideUrl.isNotEmpty) {
      return overrideUrl;
    }

    if (kDebugMode) {
      return _getDevUrl();
    }

    return _getProductionUrl();
  }

  static DebugNetworkInfo getDebugNetworkInfo({String? overrideUrl}) {
    final url = overrideUrl ?? getBackendUrl();

    if (kDebugMode) {
      return _getDebugNetworkInfoDev(url);
    }

    return DebugNetworkInfo(
      environment: 'production',
      platform: _getPlatformName(),
      backendUrl: url,
    );
  }

  static DebugNetworkInfo _getDebugNetworkInfoDev(String url) {
    final String platform = _getPlatformName();
    String? deviceType;
    String? connectionType;

    if (Platform.isAndroid) {
      final isEmulator = _isRunningOnEmulator();
      if (isEmulator) {
        deviceType = 'Emulator';
      } else {
        deviceType = 'Physical Device';
      }

      final isUsb = _isUsbConnection();
      connectionType = isUsb ? 'USB-C' : 'WiFi';
    }

    return DebugNetworkInfo(
      environment: 'development',
      platform: platform,
      deviceType: deviceType,
      connectionType: connectionType,
      backendUrl: url,
    );
  }

  static String _getPlatformName() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (kIsWeb) return 'Web';
    return 'Unknown';
  }

  static String _getDevUrl() {
    if (Platform.isAndroid) {
      return _getAndroidDevUrl();
    }

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return 'http://localhost:3001';
    }

    return 'http://localhost:3001';
  }

  static String _getAndroidDevUrl() {
    final isEmulator = _isRunningOnEmulator();

    if (isEmulator) {
      return 'http://10.0.2.2:3001';
    }

    return 'http://localhost:3001';
  }

  static bool _isRunningOnEmulator() {
    try {
      final androidInfo = Platform.operatingSystemVersion;
      return androidInfo.toLowerCase().contains('emulator') ||
          androidInfo.toLowerCase().contains('sdk');
    } catch (_) {
      return false;
    }
  }

  static bool _isUsbConnection() {
    try {
      final result = Process.runSync('adb', ['devices']);
      final output = result.stdout.toString();
      final lines = output.split('\n');

      final androidDevices = lines.where((line) {
        return line.contains('device') && (line.contains('.'));
      }).toList();

      if (androidDevices.isNotEmpty) {
        for (final line in androidDevices) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.isNotEmpty) {
            final deviceId = parts[0];
            if (deviceId.contains(':')) {
              return false;
            }
          }
        }
        return true;
      }
    } catch (_) {}
    return true;
  }

  static String _getProductionUrl() {
    const prodUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.altrupets.com',
    );
    return prodUrl;
  }

  static String getGraphQLEndpoint({String? baseUrl}) {
    final url = baseUrl ?? getBackendUrl();
    return '$url/graphql';
  }
}
