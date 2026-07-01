import 'package:money_me/core/network/api_client.dart';
import 'package:money_me/core/network/api_constants.dart' show ApiConstants;
import 'package:money_me/features/auth/data/models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSource(this._client);

  Future<Map<String, dynamic>> login(String email, String password) async {
    return _client.post(ApiConstants.login, body: {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    return _client.post(ApiConstants.register, body: {
      'email': email,
      'password': password,
      'name': name,
    });
  }

  Future<UserModel> getCurrentUser({String? token}) async {
    final response = await _client.get(
      ApiConstants.me,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    final userData = response['profile'] as Map<String, dynamic>? ?? {};
    return UserModel.fromUserJson({
      'id': response['id'],
      'email': response['email'],
      'name': userData['name'] ?? '',
    });
  }

  Future<void> deleteAccount({String? token}) async {
    await _client.delete(
      '${ApiConstants.apiPrefix}/auth/account',
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
  }
}
