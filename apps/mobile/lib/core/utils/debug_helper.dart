import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

class DebugHelper {
  DebugHelper._();

  static const String backendStartCommand =
      'make setup && make dev-minikube-deploy && make dev-terraform-deploy && make dev-harbor-deploy && make dev-images-build && make dev-argocd-push-and-deploy && make dev-gateway-start';

  static const String _adminServerUrl = 'http://localhost:3002';

  static void logBackendStartCommand() {
    debugPrint('Para reconectar el backend, ejecuta en terminal:');
    debugPrint('$backendStartCommand');
  }

  static Future<void> restartBackend() async {
    debugPrint('Solicitando reinicio del backend...');
    try {
      debugPrint('Llamando al admin server para reiniciar backend...');

      final response = await http.post(
        Uri.parse('$_adminServerUrl/restart-backend'),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        debugPrint('Solicitud de restart enviada correctamente');

        if (response.statusCode == 202) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final tailCommand =
              data['tail_command'] as String? ??
              'tail -f logs/backend/admin-server-*.log';
          debugPrint(
            'Puedes ver el progreso en tiempo real ejecutando en terminal:',
          );
          debugPrint(tailCommand);
        } else {
          debugPrint(
            'El backend se esta reiniciando (esto puede tomar varios minutos)',
          );
        }
      } else {
        debugPrint('Error del admin server: ${response.statusCode}');
        debugPrint('   ${response.body}');
      }
    } catch (e) {
      debugPrint('Error al intentar ejecutar comando debug local: $e');
      debugPrint('Asegurate de que el admin server este corriendo:');
      debugPrint('sudo systemctl start altrupets-admin');
    }
  }
}
