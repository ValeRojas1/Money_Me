import 'package:money_me/core/errors/failures.dart';

abstract interface class PredictionRepository {
  Future<(Map<String, dynamic>?, Failure?)> getMonthlySpendingPrediction();
  Future<(Map<String, dynamic>?, Failure?)> getIncomePrediction();
  Future<(Map<String, dynamic>?, Failure?)> getWalletPrediction(int walletId, int balanceCents);
  Future<(Map<String, dynamic>?, Failure?)> getSavingsGoalPrediction(int goalCents, int currentCents);
  Future<(Map<String, dynamic>?, Failure?)> getBudgetRecommendations();
}
