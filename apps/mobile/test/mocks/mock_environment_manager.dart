import 'package:mockito/mockito.dart';

class MockEnvironmentManager extends Mock {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #currentEnvironment) {
      return MockEnvironment();
    }
    return super.noSuchMethod(invocation);
  }
}

class MockEnvironment {
  String get apiBaseUrl => 'https://api.example.com';
  int get requestTimeoutSeconds => 30;
}
