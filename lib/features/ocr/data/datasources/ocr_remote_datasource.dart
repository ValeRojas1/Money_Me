import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:money_me/core/network/api_client.dart';
import 'package:money_me/core/network/api_constants.dart' show ApiConstants;
import 'package:money_me/features/auth/presentation/providers/auth_provider.dart';
import 'package:money_me/features/ocr/data/models/ocr_result_model.dart';

class OcrRemoteDataSource {
  final ApiClient _client;
  final AuthProvider _authProvider;

  OcrRemoteDataSource(this._client, this._authProvider);

  Future<Map<String, String>> _headers() async {
    final token = _authProvider.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<OcrResultModel>> scanReceiptBytes(List<int> bytes, String filename) async {
    final token = _authProvider.token;
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ocrScanReceipt}');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename))
      ..headers.addAll({
        if (token != null) 'Authorization': 'Bearer $token',
      });

    final streamed = await request.send().timeout(ApiConstants.timeout);
    final response = await http.Response.fromStream(streamed);
    final data = jsonDecode(response.body);

    if (response.statusCode >= 400) {
      final message = data is Map && data['detail'] is String
          ? data['detail'] as String
          : response.body;
      throw Exception(message);
    }

    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => OcrResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProcessedCaptureModel>> getHistory() async {
    final response = await _client.get(ApiConstants.ocrHistory, headers: await _headers());
    final list = response['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => ProcessedCaptureModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> confirmCapture(int captureId, Map<String, dynamic>? edits) async {
    return _client.post('/api/v1/ocr/$captureId/confirm', body: edits, headers: await _headers());
  }

  Future<Map<String, dynamic>> rejectCapture(int captureId) async {
    return _client.post('/api/v1/ocr/$captureId/reject', headers: await _headers());
  }

  Future<Map<String, dynamic>> saveManualEntry(Map<String, dynamic> data) async {
    return _client.post('/api/v1/ocr/manual', body: data, headers: await _headers());
  }
}
