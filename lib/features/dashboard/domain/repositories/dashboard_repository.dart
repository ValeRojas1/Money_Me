import 'package:money_me/features/dashboard/domain/entities/dashboard_entity.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> getSummary({String? month});

  Future<List<MonthlyTrendPoint>> getMonthlyTrend({int months = 12});

  Future<List<TopCategoryItem>> getTopCategories({int limit = 5});

  Future<List<BreakdownItem>> getCategoryBreakdown({String? month});

  Future<List<BreakdownItem>> getWalletBreakdown();

  Future<List<BudgetEntity>> getBudgets({String? month});

  Future<BudgetEntity> createBudget(Map<String, dynamic> data);

  Future<BudgetEntity> updateBudget(int id, Map<String, dynamic> data);

  Future<void> deleteBudget(int id);

  Future<List<BudgetAlert>> getBudgetAlerts();
}
