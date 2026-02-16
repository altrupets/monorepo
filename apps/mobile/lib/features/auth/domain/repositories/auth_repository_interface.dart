import 'package:dartz/dartz.dart';
import 'package:altrupets/core/error/failures.dart';
import 'package:altrupets/features/auth/domain/entities/user.dart';
import 'package:altrupets/features/auth/data/models/auth_payload.dart';

abstract class AuthRepositoryInterface {
  Future<Either<Failure, AuthPayload>> login(
    String username,
    String password,
  );
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> logout();
}
