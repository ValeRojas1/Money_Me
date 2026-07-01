import 'package:money_me/core/errors/failures.dart';
import 'package:money_me/features/auth/domain/entities/user.dart';
import 'package:money_me/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<(User?, Failure?)> call(String email, String password) {
    return _repository.login(email, password);
  }
}
