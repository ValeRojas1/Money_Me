import 'package:money_me/core/errors/failures.dart';
import 'package:money_me/core/network/api_exceptions.dart';
import 'package:money_me/features/analysis/data/datasources/analysis_remote_datasource.dart';
import 'package:money_me/features/analysis/domain/repositories/analysis_repository.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  final AnalysisRemoteDataSource _remoteDataSource;

  AnalysisRepositoryImpl(this._remoteDataSource);

  @override
  Future<(Map<String, dynamic>?, Failure?)> getSpendingAnalysis() async {
    try {
      final result = await _remoteDataSource.getSpendingAnalysis();
      return (result, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> getTrends() async {
    try {
      final result = await _remoteDataSource.getTrends();
      return (result, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }

  @override
  Future<(List<dynamic>?, Failure?)> getCategoryBreakdown() async {
    try {
      final result = await _remoteDataSource.getCategoryBreakdown();
      final list = result['data'] as List<dynamic>? ?? [];
      return (list, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> getIncomeVsExpenses() async {
    try {
      final result = await _remoteDataSource.getIncomeVsExpenses();
      return (result, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }

  @override
  Future<(List<dynamic>?, Failure?)> getAlerts() async {
    try {
      final result = await _remoteDataSource.getAlerts();
      final list = result['data'] as List<dynamic>? ?? result as List<dynamic>? ?? [];
      if (list is List<dynamic>) return (list, null);
      return (result['data'] as List<dynamic>? ?? [], null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    }
  }
}
