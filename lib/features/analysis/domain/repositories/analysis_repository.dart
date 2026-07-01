import 'package:money_me/core/errors/failures.dart';

abstract interface class AnalysisRepository {
  Future<(Map<String, dynamic>?, Failure?)> getSpendingAnalysis();
  Future<(Map<String, dynamic>?, Failure?)> getTrends();
  Future<(List<dynamic>?, Failure?)> getCategoryBreakdown();
  Future<(Map<String, dynamic>?, Failure?)> getIncomeVsExpenses();
  Future<(List<dynamic>?, Failure?)> getAlerts();
}
