import 'package:flutter_test/flutter_test.dart';
import 'package:money_me/core/errors/failures.dart';
import 'package:money_me/features/auth/domain/entities/user.dart';
import 'package:money_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:money_me/features/auth/domain/usecases/login_usecase.dart';
import 'package:money_me/features/auth/domain/usecases/register_usecase.dart';
import 'package:money_me/features/auth/presentation/providers/auth_provider.dart';

class MockAuthRepository implements AuthRepository {
  @override
  String? token = 'mock_token';

  @override
  Future<(User?, Failure?)> login(String email, String password) async {
    if (email == 'fail@test.com') {
      return (null, AuthFailure('Invalid credentials'));
    }
    return (User(id: 1, email: email, name: 'Test', createdAt: DateTime.now(), updatedAt: DateTime.now()), null);
  }

  @override
  Future<(User?, Failure?)> register(String email, String password, String name) async {
    return (User(id: 1, email: email, name: name, createdAt: DateTime.now(), updatedAt: DateTime.now()), null);
  }

  @override
  Future<(User?, Failure?)> getCurrentUser() async {
    return (User(id: 1, email: 'test@test.com', name: 'Test', createdAt: DateTime.now(), updatedAt: DateTime.now()), null);
  }

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> logout() async {
    token = null;
  }
}

void main() {
  late MockAuthRepository repository;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late AuthProvider provider;

  setUp(() {
    repository = MockAuthRepository();
    loginUseCase = LoginUseCase(repository);
    registerUseCase = RegisterUseCase(repository);
    provider = AuthProvider(loginUseCase, registerUseCase, repository);
  });

  group('AuthProvider', () {
    test('initial status is initial', () {
      expect(provider.status, AuthStatus.initial);
      expect(provider.user, isNull);
      expect(provider.errorMessage, isNull);
    });

    test('login sets authenticated status', () async {
      await provider.login('test@test.com', 'password');
      expect(provider.status, AuthStatus.authenticated);
      expect(provider.user, isNotNull);
      expect(provider.user!.email, 'test@test.com');
      expect(provider.errorMessage, isNull);
    });

    test('login failure sets error status', () async {
      await provider.login('fail@test.com', 'password');
      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.errorMessage, isNotNull);
    });

    test('register sets authenticated status', () async {
      await provider.register('new@test.com', 'Password1', 'New User');
      expect(provider.status, AuthStatus.authenticated);
      expect(provider.user, isNotNull);
      expect(provider.user!.name, 'New User');
    });

    test('logout clears user and sets unauthenticated', () {
      provider.logout();
      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.user, isNull);
      expect(provider.errorMessage, isNull);
    });

    test('deleteAccount clears user and sets unauthenticated', () async {
      await provider.deleteAccount();
      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.user, isNull);
    });

    test('clearError resets error state', () {
      provider.clearError();
      expect(provider.errorMessage, isNull);
    });

    test('initialize with token sets authenticated', () async {
      repository.token = 'existing_token';
      await provider.initialize();
      expect(provider.status, AuthStatus.authenticated);
      expect(provider.user, isNotNull);
    });

    test('initialize without token sets unauthenticated', () async {
      repository.token = null;
      await provider.initialize();
      expect(provider.status, AuthStatus.unauthenticated);
    });

    test('token getter returns repository token', () {
      repository.token = 'test_token';
      expect(provider.token, 'test_token');
    });
  });
}
