import 'package:money_me/core/network/api_client.dart';
import 'package:money_me/core/network/api_constants.dart' show ApiConstants;

class PredictionRemoteDataSource {
  final ApiClient _client;

  PredictionRemoteDataSource(this._client);

  Future<Map<String, dynamic>> getMonthlySpendingPrediction() {
    return _client.get(ApiConstants.predictionsMonthly);
  }

  Future<Map<String, dynamic>> getIncomePrediction() {
    return _client.get('${ApiConstants.apiPrefix}/predictions/income');
  }

  Future<Map<String, dynamic>> getWalletPrediction(int walletId, int balanceCents) {
    return _client.get(
      '${ApiConstants.apiPrefix}/predictions/wallet/$walletId',
      headers: {'current_balance_cents': balanceCents.toString()},
    );
  }

  Future<Map<String, dynamic>> getSavingsGoalPrediction(int goalCents, int currentCents) {
    return _client.get(ApiConstants.predictionsSavings);
  }

  Future<Map<String, dynamic>> getBudgetRecommendations() {
    return _client.get(ApiConstants.predictionsBudget);
  }
}
