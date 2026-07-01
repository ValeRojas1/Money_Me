import 'package:flutter/foundation.dart';
import 'package:money_me/features/analysis/domain/entities/analysis_data.dart';
import 'package:money_me/features/analysis/domain/repositories/analysis_repository.dart';

enum AnalysisStatus { initial, loading, loaded, error }

class AnalysisProvider extends ChangeNotifier {
  final AnalysisRepository _repository;

  AnalysisStatus _status = AnalysisStatus.initial;
  IncomeVsExpenses? _incomeVsExpenses;
  List<MonthlyComparison> _monthlyComparison = [];
  List<CategoryTrend> _categoryTrends = [];
  List<SpendingTrend> _spendingTrends = [];
  MovementFrequency? _frequency;
  List<AnomalyAlert> _alerts = [];
  String? _errorMessage;

  AnalysisProvider(this._repository);

  AnalysisStatus get status => _status;
  IncomeVsExpenses? get incomeVsExpenses => _incomeVsExpenses;
  List<MonthlyComparison> get monthlyComparison => _monthlyComparison;
  List<CategoryTrend> get categoryTrends => _categoryTrends;
  List<SpendingTrend> get spendingTrends => _spendingTrends;
  MovementFrequency? get frequency => _frequency;
  List<AnomalyAlert> get alerts => _alerts;
  String? get errorMessage => _errorMessage;

  Future<void> loadAll() async {
    _status = AnalysisStatus.loading;
    notifyListeners();

    await Future.wait([
      _loadSpendingAnalysis(),
      _loadTrends(),
      _loadCategories(),
      _loadIncomeVsExpenses(),
      _loadAlerts(),
    ]);

    _status = AnalysisStatus.loaded;
    notifyListeners();
  }

  Future<void> _loadSpendingAnalysis() async {
    final (data, failure) = await _repository.getSpendingAnalysis();
    if (data != null) {
      _monthlyComparison = (data['monthly_comparison'] as List<dynamic>?)
              ?.map((e) => MonthlyComparison.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _frequency = MovementFrequency.fromJson(
          data['frequency'] as Map<String, dynamic>? ?? {});
    }
  }

  Future<void> _loadTrends() async {
    final (data, failure) = await _repository.getTrends();
    if (data != null) {
      _spendingTrends = (data['monthly_trend'] as List<dynamic>?)
              ?.map((e) => SpendingTrend.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    }
  }

  Future<void> _loadCategories() async {
    final (data, failure) = await _repository.getCategoryBreakdown();
    if (data != null) {
      _categoryTrends = data
          .map((e) => CategoryTrend.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _loadIncomeVsExpenses() async {
    final (data, failure) = await _repository.getIncomeVsExpenses();
    if (data != null) {
      _incomeVsExpenses = IncomeVsExpenses.fromJson(data);
    }
  }

  Future<void> _loadAlerts() async {
    final (data, failure) = await _repository.getAlerts();
    if (data != null) {
      _alerts = data
          .map((e) => AnomalyAlert.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }
}
