import 'package:money_me/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:money_me/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:money_me/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource dataSource;

  DashboardRepositoryImpl({required this.dataSource});

  @override
  Future<DashboardSummary> getSummary({String? month}) async {
    final json = await dataSource.getSummary(month: month);
    return DashboardSummary.fromJson(json);
  }

  @override
  Future<List<MonthlyTrendPoint>> getMonthlyTrend({int months = 12}) async {
    final json = await dataSource.getMonthlyTrend(months: months);
    final list = json['months'] as List? ?? [];
    return list
        .map((e) => MonthlyTrendPoint.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<TopCategoryItem>> getTopCategories({int limit = 5}) async {
    final json = await dataSource.getTopCategories(limit: limit);
    final list = json['items'] as List? ?? [];
    return list
        .map((e) => TopCategoryItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<BreakdownItem>> getCategoryBreakdown({String? month}) async {
    final json = await dataSource.getCategoryBreakdown(month: month);
    final list = json['items'] as List? ?? [];
    return list
        .map((e) => BreakdownItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<BreakdownItem>> getWalletBreakdown() async {
    final json = await dataSource.getWalletBreakdown();
    final list = json['items'] as List? ?? [];
    return list
        .map((e) => BreakdownItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<BudgetEntity>> getBudgets({String? month}) async {
    final list = await dataSource.getBudgetsRaw(month: month);
    return list
        .map((e) => BudgetEntity.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<BudgetEntity> createBudget(Map<String, dynamic> data) async {
    final json = await dataSource.createBudget(data);
    return BudgetEntity.fromJson(json);
  }

  @override
  Future<BudgetEntity> updateBudget(int id, Map<String, dynamic> data) async {
    final json = await dataSource.updateBudget(id, data);
    return BudgetEntity.fromJson(json);
  }

  @override
  Future<void> deleteBudget(int id) async {
    await dataSource.deleteBudget(id);
  }

  @override
  Future<List<BudgetAlert>> getBudgetAlerts() async {
    final list = await dataSource.getBudgetAlertsRaw();
    return list
        .map((e) => BudgetAlert.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
