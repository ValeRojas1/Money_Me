import 'package:money_me/core/network/api_client.dart';
import 'package:money_me/features/auth/presentation/providers/auth_provider.dart';

class DashboardRemoteDataSource {
  final ApiClient client;
  final AuthProvider authProvider;

  DashboardRemoteDataSource({required this.client, required this.authProvider});

  Future<Map<String, String>> _headers() async {
    final token = authProvider.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getSummary({String? month}) async {
    final path = month != null
        ? '/api/v1/dashboard/summary?month=$month'
        : '/api/v1/dashboard/summary';
    return client.get(path, headers: await _headers());
  }

  Future<Map<String, dynamic>> getMonthlyTrend({int months = 12}) async {
    return client.get(
      '/api/v1/dashboard/monthly-trend?months=$months',
      headers: await _headers(),
    );
  }

  Future<Map<String, dynamic>> getTopCategories({int limit = 5}) async {
    return client.get(
      '/api/v1/dashboard/top-categories?limit=$limit',
      headers: await _headers(),
    );
  }

  Future<Map<String, dynamic>> getCategoryBreakdown({String? month}) async {
    final path = month != null
        ? '/api/v1/dashboard/category-breakdown?month=$month'
        : '/api/v1/dashboard/category-breakdown';
    return client.get(path, headers: await _headers());
  }

  Future<Map<String, dynamic>> getWalletBreakdown() async {
    return client.get('/api/v1/dashboard/wallet-breakdown', headers: await _headers());
  }

  Future<Map<String, dynamic>> getBudgets({String? month}) async {
    final path = month != null
        ? '/api/v1/budgets/?month=$month'
        : '/api/v1/budgets/';
    return client.get(path, headers: await _headers());
  }

  Future<List<dynamic>> getBudgetsRaw({String? month}) async {
    final path = month != null
        ? '/api/v1/budgets/?month=$month'
        : '/api/v1/budgets/';
    final result = await client.get(path, headers: await _headers());
    return _extractList(result);
  }

  Future<Map<String, dynamic>> createBudget(Map<String, dynamic> data) async {
    return client.post('/api/v1/budgets/', body: data, headers: await _headers());
  }

  Future<Map<String, dynamic>> updateBudget(int id, Map<String, dynamic> data) async {
    return client.put('/api/v1/budgets/$id', body: data, headers: await _headers());
  }

  Future<void> deleteBudget(int id) async {
    await client.delete('/api/v1/budgets/$id', headers: await _headers());
  }

  Future<List<dynamic>> getBudgetAlertsRaw() async {
    final result = await client.get('/api/v1/budgets/alerts', headers: await _headers());
    return _extractList(result);
  }

  List<dynamic> _extractList(Map<String, dynamic> result) {
    final value = result['items'] ?? result['data'];
    if (value is List) return value;
    return [];
  }
}
