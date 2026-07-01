import 'package:money_me/core/errors/failures.dart';
import 'package:money_me/core/network/api_exceptions.dart';
import 'package:money_me/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:money_me/features/auth/data/models/user_model.dart';
import 'package:money_me/features/auth/domain/entities/user.dart';
import 'package:money_me/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  String? _token;

  AuthRepositoryImpl(this._remoteDataSource);

  String? get token => _token;

  @override
  Future<(User?, Failure?)> login(String email, String password) async {
    try {
      final response = await _remoteDataSource.login(email, password);
      _token = response['access_token'] as String?;
      final userData = response['user'] as Map<String, dynamic>? ?? {};
      final user = UserModel.fromJson(userData);
      return (user, null);
    } on ApiException catch (e) {
      return (null, AuthFailure(e.message));
    } catch (e) {
      return (null, AuthFailure(e.toString()));
    }
  }

  @override
  Future<(User?, Failure?)> register(String email, String password, String name) async {
    try {
      final response = await _remoteDataSource.register(email, password, name);
      _token = response['access_token'] as String?;
      final userData = response['user'] as Map<String, dynamic>? ?? {};
      final user = UserModel.fromJson(userData);
      return (user, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<(User?, Failure?)> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser(token: _token);
      return (user, null);
    } on ApiException catch (e) {
      return (null, AuthFailure(e.message));
    } catch (e) {
      return (null, AuthFailure(e.toString()));
    }
  }

  @override
  Future<void> deleteAccount() async {
    await _remoteDataSource.deleteAccount(token: _token);
    _token = null;
  }

  @override
  Future<void> logout() async {
    _token = null;
  }
}
