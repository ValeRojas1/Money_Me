import 'package:money_me/core/network/api_client.dart';
import 'package:money_me/core/network/api_constants.dart' show ApiConstants;

class AnalysisRemoteDataSource {
  final ApiClient _client;

  AnalysisRemoteDataSource(this._client);

  Future<Map<String, dynamic>> getSpendingAnalysis() {
    return _client.get(ApiConstants.analysisSpending);
  }

  Future<Map<String, dynamic>> getTrends() {
    return _client.get(ApiConstants.analysisTrends);
  }

  Future<Map<String, dynamic>> getCategoryBreakdown() {
    return _client.get(ApiConstants.analysisCategories);
  }

  Future<Map<String, dynamic>> getIncomeVsExpenses() {
    return _client.get(ApiConstants.analysisIncomeVsExpenses);
  }

  Future<Map<String, dynamic>> getAlerts() {
    return _client.get('${ApiConstants.apiPrefix}/analysis/alerts');
  }
}
