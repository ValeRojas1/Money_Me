import 'package:flutter_test/flutter_test.dart';
import 'package:money_me/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:money_me/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:money_me/features/dashboard/presentation/providers/dashboard_provider.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSummary> getSummary({String? month}) async {
    return DashboardSummary(
      month: month ?? '2026-07', incomeCents: 500000, income: 5000.0,
      expenseCents: 300000, expense: 3000.0, balanceCents: 200000,
      balance: 2000.0, transactionCount: 10,
    );
  }

  @override
  Future<List<MonthlyTrendPoint>> getMonthlyTrend({int months = 12}) async {
    return [MonthlyTrendPoint(
      month: '2026-07', label: 'Jul', incomeCents: 500000, income: 5000.0,
      expenseCents: 300000, expense: 3000.0, balanceCents: 200000, balance: 2000.0,
    )];
  }

  @override
  Future<List<TopCategoryItem>> getTopCategories({int limit = 5}) async {
    return [TopCategoryItem(categoryId: 1, categoryName: 'Food', totalCents: 150000, total: 1500.0, count: 5)];
  }

  @override
  Future<List<BreakdownItem>> getCategoryBreakdown({String? month}) async {
    return [BreakdownItem(id: 1, totalCents: 150000, total: 1500.0, percentage: 50.0)];
  }

  @override
  Future<List<BreakdownItem>> getWalletBreakdown() async {
    return [BreakdownItem(id: 1, totalCents: 500000, total: 5000.0, percentage: 100.0)];
  }

  @override
  Future<List<BudgetEntity>> getBudgets({String? month}) async {
    return [BudgetEntity(
      id: 1, categoryId: 1, name: 'Food Budget', period: 'monthly', status: 'active',
      limitCents: 200000, limit: 2000.0, spentCents: 150000, spent: 1500.0,
      percentage: 75.0, remainingCents: 50000, remaining: 500.0,
      currency: 'USD', startDate: '2026-07-01', notifyAtPercentage: 80,
      isRollover: false,
    )];
  }

  @override
  Future<BudgetEntity> createBudget(Map<String, dynamic> data) async {
    return BudgetEntity(
      id: 1, categoryId: data['category_id'] as int? ?? 0,
      name: data['name'] as String? ?? '', period: 'monthly', status: 'active',
      limitCents: data['limit_cents'] as int? ?? 0, limit: 0.0,
      spentCents: 0, spent: 0.0, percentage: 0.0, remainingCents: 0,
      remaining: 0.0, currency: 'USD', startDate: '2026-07-01',
      notifyAtPercentage: 80, isRollover: false,
    );
  }

  @override
  Future<BudgetEntity> updateBudget(int id, Map<String, dynamic> data) async {
    return BudgetEntity(
      id: id, categoryId: 1, name: 'Updated', period: 'monthly', status: 'active',
      limitCents: 300000, limit: 3000.0, spentCents: 0, spent: 0.0,
      percentage: 0.0, remainingCents: 0, remaining: 0.0,
      currency: 'USD', startDate: '2026-07-01', notifyAtPercentage: 80,
      isRollover: false,
    );
  }

  @override
  Future<void> deleteBudget(int id) async {}

  @override
  Future<List<BudgetAlert>> getBudgetAlerts() async {
    return [BudgetAlert(
      budgetId: 1, name: 'Over budget', limitCents: 100000,
      limit: 1000.0, spentCents: 120000, spent: 1200.0,
      percentage: 120.0, severity: 'danger',
      message: 'Youve exceeded your budget!',
    )];
  }
}

void main() {
  late MockDashboardRepository repository;
  late DashboardProvider provider;

  setUp(() {
    repository = MockDashboardRepository();
    provider = DashboardProvider(repository: repository);
  });

  group('DashboardProvider', () {
    test('initial state is empty', () {
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
      expect(provider.summary, isNull);
      expect(provider.monthlyTrend, isEmpty);
    });

    test('loadAll populates all data', () async {
      await provider.loadAll();
      expect(provider.summary, isNotNull);
      expect(provider.summary!.month, '2026-07');
      expect(provider.monthlyTrend, isNotEmpty);
      expect(provider.topCategories, isNotEmpty);
      expect(provider.categoryBreakdown, isNotEmpty);
      expect(provider.walletBreakdown, isNotEmpty);
      expect(provider.budgets, isNotEmpty);
      expect(provider.alerts, isNotEmpty);
    });

    test('refresh reloads all data', () async {
      await provider.refresh();
      expect(provider.summary, isNotNull);
    });

    test('loadAll with month filter', () async {
      await provider.loadAll(month: '2026-06');
      expect(provider.summary!.month, '2026-06');
    });

    test('createBudget returns true and reloads', () async {
      final result = await provider.createBudget({
        'category_id': 1, 'name': 'Test Budget', 'period': 'monthly',
        'limit_cents': 50000,
      });
      expect(result, isTrue);
    });

    test('updateBudget returns true', () async {
      final result = await provider.updateBudget(1, {'name': 'Updated'});
      expect(result, isTrue);
    });

    test('deleteBudget returns true', () async {
      final result = await provider.deleteBudget(1);
      expect(result, isTrue);
    });

    test('error is null on successful load', () async {
      await provider.loadAll();
      expect(provider.error, isNull);
    });
  });
}
