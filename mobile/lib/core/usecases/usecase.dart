import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Clase base para todos los casos de uso
/// [Type] - Tipo de retorno
/// [Params] - Parámetros de entrada
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Clase para casos de uso sin parámetros
class NoParams {
  const NoParams();
}