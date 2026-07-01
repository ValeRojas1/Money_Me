import 'package:flutter/foundation.dart';

import 'package:money_me/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:money_me/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository repository;

  DashboardProvider({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  DashboardSummary? _summary;
  DashboardSummary? get summary => _summary;

  List<MonthlyTrendPoint> _monthlyTrend = [];
  List<MonthlyTrendPoint> get monthlyTrend => _monthlyTrend;

  List<TopCategoryItem> _topCategories = [];
  List<TopCategoryItem> get topCategories => _topCategories;

  List<BreakdownItem> _categoryBreakdown = [];
  List<BreakdownItem> get categoryBreakdown => _categoryBreakdown;

  List<BreakdownItem> _walletBreakdown = [];
  List<BreakdownItem> get walletBreakdown => _walletBreakdown;

  List<BudgetEntity> _budgets = [];
  List<BudgetEntity> get budgets => _budgets;

  List<BudgetAlert> _alerts = [];
  List<BudgetAlert> get alerts => _alerts;

  Future<void> loadAll({String? month}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.getSummary(month: month),
        repository.getMonthlyTrend(),
        repository.getTopCategories(),
        repository.getCategoryBreakdown(month: month),
        repository.getWalletBreakdown(),
        repository.getBudgets(month: month),
        repository.getBudgetAlerts(),
      ]);

      _summary = results[0] as DashboardSummary;
      _monthlyTrend = results[1] as List<MonthlyTrendPoint>;
      _topCategories = results[2] as List<TopCategoryItem>;
      _categoryBreakdown = results[3] as List<BreakdownItem>;
      _walletBreakdown = results[4] as List<BreakdownItem>;
      _budgets = results[5] as List<BudgetEntity>;
      _alerts = results[6] as List<BudgetAlert>;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh({String? month}) async {
    await loadAll(month: month);
  }

  Future<bool> createBudget(Map<String, dynamic> data) async {
    try {
      await repository.createBudget(data);
      await loadAll();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBudget(int id, Map<String, dynamic> data) async {
    try {
      await repository.updateBudget(id, data);
      await loadAll();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBudget(int id) async {
    try {
      await repository.deleteBudget(id);
      await loadAll();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
