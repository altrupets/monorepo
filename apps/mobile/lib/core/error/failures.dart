import 'package:equatable/equatable.dart';

/// Clase base para todos los tipos de fallos
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

/// Fallo del servidor
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

/// Fallo de caché
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de caché']);
}

/// Fallo de red
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}
