import 'package:money_me/core/errors/failures.dart';
import 'package:money_me/features/auth/domain/entities/user.dart';
import 'package:money_me/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<(User?, Failure?)> call(String email, String password, String name) {
    return _repository.register(email, password, name);
  }
}
