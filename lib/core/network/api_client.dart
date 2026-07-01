import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'api_constants.dart' show ApiConstants;
import 'api_exceptions.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? headers}) {
    return _request('GET', path, headers: headers);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    return _request('POST', path, body: body, headers: headers);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    return _request('PUT', path, body: body, headers: headers);
  }

  Future<Map<String, dynamic>> delete(String path, {Map<String, String>? headers}) {
    return _request('DELETE', path, headers: headers);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final requestHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    try {
      late http.Response response;
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: requestHeaders)
              .timeout(ApiConstants.timeout);
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: requestHeaders,
                body: body == null ? null : jsonEncode(body),
              )
              .timeout(ApiConstants.timeout);
        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: requestHeaders,
                body: body == null ? null : jsonEncode(body),
              )
              .timeout(ApiConstants.timeout);
        case 'DELETE':
          response = await _client
              .delete(uri, headers: requestHeaders)
              .timeout(ApiConstants.timeout);
        default:
          throw ApiException(statusCode: 0, message: 'Unsupported HTTP method: $method');
      }

      Map<String, dynamic> data = {};
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            data = decoded;
          } else if (decoded is List) {
            data = {'items': decoded, 'data': decoded};
          } else {
            data = {'data': decoded};
          }
        } on FormatException {
          data = {'detail': response.body};
        }
      }

      if (response.statusCode >= 400) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(data, response.body),
        );
      }

      return data;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        statusCode: 0,
        message: 'Request timed out. Check that the API is running at ${ApiConstants.baseUrl}',
      );
    } catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Could not connect to the API at ${ApiConstants.baseUrl}. '
            'Make sure the backend is running on port 8000.',
      );
    }
  }

  String _extractErrorMessage(Map<String, dynamic> data, String rawBody) {
    final detail = data['detail'];
    if (detail is String && detail.isNotEmpty) {
      return detail;
    }
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first['msg'] != null) {
        return first['msg'].toString();
      }
      return detail.first.toString();
    }
    if (data['message'] is String) {
      return data['message'] as String;
    }
    return rawBody.isNotEmpty ? rawBody : 'Unknown error';
  }

  void dispose() {
    _client.close();
  }
}
