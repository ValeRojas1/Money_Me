import 'package:flutter/foundation.dart';
import 'package:money_me/core/errors/failures.dart';
import 'package:money_me/features/auth/domain/entities/user.dart';
import 'package:money_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:money_me/features/auth/domain/usecases/login_usecase.dart';
import 'package:money_me/features/auth/domain/usecases/register_usecase.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthProvider(this._loginUseCase, this._registerUseCase, this._repository);

  Future<void> initialize() async {
    if (_status != AuthStatus.initial) return;

    final token = _repository.token;
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    final (user, failure) = await _repository.getCurrentUser();
    if (failure != null || user == null) {
      await _repository.logout();
      _status = AuthStatus.unauthenticated;
      _user = null;
      _errorMessage = null;
    } else {
      _status = AuthStatus.authenticated;
      _user = user;
      _errorMessage = null;
    }
    notifyListeners();
  }

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get token => _repository.token;

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final (user, failure) = await _loginUseCase(email, password);

    if (failure != null) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = failure.message;
    } else {
      _status = AuthStatus.authenticated;
      _user = user;
      _errorMessage = null;
    }
    notifyListeners();
  }

  Future<void> register(String email, String password, String name) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final (user, failure) = await _registerUseCase(email, password, name);

    if (failure != null) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = failure.message;
    } else {
      _status = AuthStatus.authenticated;
      _user = user;
      _errorMessage = null;
    }
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _repository.deleteAccount();
    _status = AuthStatus.unauthenticated;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void logout() {
    _status = AuthStatus.unauthenticated;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    }
  }
}
