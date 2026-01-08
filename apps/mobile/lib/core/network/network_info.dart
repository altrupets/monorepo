import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Interfaz para verificar conectividad de red
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementación de NetworkInfo
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this.connectionChecker);

  final InternetConnectionChecker connectionChecker;

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
