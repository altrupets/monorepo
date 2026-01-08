import 'package:dartz/dartz.dart';
import 'package:altrupets/core/error/failures.dart';

/// Clase base para todos los casos de uso
/// [Type] - Tipo de retorno
/// [Params] - Parámetros de entrada
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Clase para casos de uso sin parámetros
class NoParams {
  const NoParams();
}
