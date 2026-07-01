import 'package:money_me/core/errors/failures.dart';
import 'package:money_me/core/network/api_exceptions.dart';
import 'package:money_me/features/predictions/data/datasources/prediction_remote_datasource.dart';
import 'package:money_me/features/predictions/domain/repositories/prediction_repository.dart';

class PredictionRepositoryImpl implements PredictionRepository {
  final PredictionRemoteDataSource _remoteDataSource;

  PredictionRepositoryImpl(this._remoteDataSource);

  @override
  Future<(Map<String, dynamic>?, Failure?)> getMonthlySpendingPrediction() async {
    try {
      final result = await _remoteDataSource.getMonthlySpendingPrediction();
      return (result, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> getIncomePrediction() async {
    try {
      final result = await _remoteDataSource.getIncomePrediction();
      return (result, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> getWalletPrediction(
      int walletId, int balanceCents) async {
    try {
      final result =
          await _remoteDataSource.getWalletPrediction(walletId, balanceCents);
      return (result, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> getSavingsGoalPrediction(
      int goalCents, int currentCents) async {
    try {
      final result = await _remoteDataSource.getSavingsGoalPrediction(
          goalCents, currentCents);
      return (result, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> getBudgetRecommendations() async {
    try {
      final result = await _remoteDataSource.getBudgetRecommendations();
      return (result, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }
}
