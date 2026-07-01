import 'package:money_me/core/errors/failures.dart';
import 'package:money_me/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  String? get token;
  Future<(User?, Failure?)> login(String email, String password);
  Future<(User?, Failure?)> register(String email, String password, String name);
  Future<(User?, Failure?)> getCurrentUser();
  Future<void> deleteAccount();
  Future<void> logout();
}
