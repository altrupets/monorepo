import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';

enum DeepLinkType { captureRequest, rescue, unknown }

class DeepLinkData {
  const DeepLinkData({required this.type, required this.id});

  final DeepLinkType type;
  final String id;
}

class DeepLinkService {
  DeepLinkService() {
    _init();
  }

  final AppLinks _appLinks = AppLinks();
  StreamController<DeepLinkData>? _deepLinkController;
  StreamSubscription<Uri>? _subscription;

  void _init() {
    _deepLinkController = StreamController<DeepLinkData>.broadcast();
  }

  Stream<DeepLinkData> get deepLinks => _deepLinkController!.stream;

  Future<void> handleInitialLink() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink.toString());
      }
    } catch (e) {
      debugPrint('[DeepLinkService] Error getting initial link: $e');
    }
  }

  void startListening() {
    _subscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleLink(uri.toString());
      },
      onError: (Object err) {
        debugPrint('[DeepLinkService] Stream error: $err');
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleLink(String link) {
    debugPrint('[DeepLinkService] Handling link: $link');

    final uri = Uri.tryParse(link);
    if (uri == null) return;

    if (uri.scheme != 'altrupets') return;

    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) return;

    final type = pathSegments[0];
    final id = pathSegments.length > 1 ? pathSegments[1] : '';

    DeepLinkType deepLinkType;
    switch (type) {
      case 'capturas':
      case 'captures':
        deepLinkType = DeepLinkType.captureRequest;
        break;
      case 'rescates':
      case 'rescues':
        deepLinkType = DeepLinkType.rescue;
        break;
      default:
        deepLinkType = DeepLinkType.unknown;
    }

    if (deepLinkType != DeepLinkType.unknown && id.isNotEmpty) {
      _deepLinkController?.add(DeepLinkData(type: deepLinkType, id: id));
    }
  }

  void dispose() {
    stopListening();
    _deepLinkController?.close();
  }

  static DeepLinkData? parseDeepLinkFromMessage(String message) {
    final uri = Uri.tryParse(message);
    if (uri == null) return null;

    if (uri.scheme != 'altrupets') return null;

    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) return null;

    final type = pathSegments[0];
    final id = pathSegments.length > 1 ? pathSegments[1] : '';

    DeepLinkType deepLinkType;
    switch (type) {
      case 'capturas':
      case 'captures':
        deepLinkType = DeepLinkType.captureRequest;
        break;
      case 'rescates':
      case 'rescues':
        deepLinkType = DeepLinkType.rescue;
        break;
      default:
        return null;
    }

    if (id.isEmpty) return null;

    return DeepLinkData(type: deepLinkType, id: id);
  }
}

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final service = DeepLinkService();
  ref.onDispose(() => service.dispose());
  return service;
});

final deepLinkStreamProvider = StreamProvider<DeepLinkData>((ref) {
  final service = ref.watch(deepLinkServiceProvider);
  return service.deepLinks;
});
