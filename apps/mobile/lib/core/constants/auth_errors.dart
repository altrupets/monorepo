enum AuthErrorType {
  userNotFound,
  invalidPassword,
  accountLocked,
  networkError,
  unknownError,
}

extension AuthErrorTypeExtension on AuthErrorType {
  String get code {
    switch (this) {
      case AuthErrorType.userNotFound:
        return 'USER_NOT_FOUND';
      case AuthErrorType.invalidPassword:
        return 'INVALID_PASSWORD';
      case AuthErrorType.accountLocked:
        return 'ACCOUNT_LOCKED';
      case AuthErrorType.networkError:
        return 'NETWORK_ERROR';
      case AuthErrorType.unknownError:
        return 'UNKNOWN_ERROR';
    }
  }
}
