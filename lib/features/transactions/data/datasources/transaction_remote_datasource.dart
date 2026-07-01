import 'dart:convert';

import 'package:money_me/core/network/api_client.dart';
import 'package:money_me/core/network/api_constants.dart';
import 'package:money_me/features/auth/presentation/providers/auth_provider.dart';

class TransactionRemoteDataSource {
  final ApiClient client;
  final AuthProvider authProvider;

  TransactionRemoteDataSource({
    required this.client,
    required this.authProvider,
  });

  Future<Map<String, String>> _headers() async {
    final token = authProvider.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> list({
    String? search,
    int? categoryId,
    String? type,
    int? walletId,
    String? status,
    String? startDate,
    String? endDate,
    String sortBy = 'date',
    String sortOrder = 'desc',
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null) params['category_id'] = categoryId.toString();
    if (type != null) params['type'] = type;
    if (walletId != null) params['wallet_id'] = walletId.toString();
    if (status != null) params['status'] = status;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;

    final queryString =
        params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final path = '/api/v1/transactions/?$queryString';
    return client.get(path, headers: await _headers());
  }

  Future<Map<String, dynamic>> get(int id) async {
    return client.get('/api/v1/transactions/$id', headers: await _headers());
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    return client.post('/api/v1/transactions/', body: data, headers: await _headers());
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    return client.put('/api/v1/transactions/$id', body: data, headers: await _headers());
  }

  Future<void> delete(int id) async {
    await client.delete('/api/v1/transactions/$id', headers: await _headers());
  }

  Future<Map<String, dynamic>> categorizeSuggestion(int id) async {
    return client.post('/api/v1/transactions/$id/categorize-suggestion',
        headers: await _headers());
  }

  Future<List<Map<String, dynamic>>> categories({String? type}) async {
    final path =
        type != null ? '/api/v1/categories/?type=$type' : '/api/v1/categories/';
    final result = await client.get(path, headers: await _headers());
    return (result['items'] as List?)?.cast<Map<String, dynamic>>() ??
        (result as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    return client.post('/api/v1/categories/', body: data, headers: await _headers());
  }

  Future<void> deleteCategory(int id) async {
    await client.delete('/api/v1/categories/$id', headers: await _headers());
  }
}
