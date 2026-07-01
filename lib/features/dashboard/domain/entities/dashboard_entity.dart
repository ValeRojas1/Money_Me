class DashboardSummary {
  final String month;
  final int incomeCents;
  final double income;
  final int expenseCents;
  final double expense;
  final int balanceCents;
  final double balance;
  final int transactionCount;
  final double? incomeVariation;
  final double? expenseVariation;

  DashboardSummary({
    required this.month,
    required this.incomeCents,
    required this.income,
    required this.expenseCents,
    required this.expense,
    required this.balanceCents,
    required this.balance,
    required this.transactionCount,
    this.incomeVariation,
    this.expenseVariation,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      month: json['month'] as String? ?? '',
      incomeCents: json['income_cents'] as int? ?? 0,
      income: (json['income'] as num?)?.toDouble() ?? 0,
      expenseCents: json['expense_cents'] as int? ?? 0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0,
      balanceCents: json['balance_cents'] as int? ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      transactionCount: json['transaction_count'] as int? ?? 0,
      incomeVariation: (json['income_variation'] as num?)?.toDouble(),
      expenseVariation: (json['expense_variation'] as num?)?.toDouble(),
    );
  }
}

class MonthlyTrendPoint {
  final String month;
  final String label;
  final int incomeCents;
  final double income;
  final int expenseCents;
  final double expense;
  final int balanceCents;
  final double balance;

  MonthlyTrendPoint({
    required this.month,
    required this.label,
    required this.incomeCents,
    required this.income,
    required this.expenseCents,
    required this.expense,
    required this.balanceCents,
    required this.balance,
  });

  factory MonthlyTrendPoint.fromJson(Map<String, dynamic> json) {
    return MonthlyTrendPoint(
      month: json['month'] as String? ?? '',
      label: json['label'] as String? ?? '',
      incomeCents: json['income_cents'] as int? ?? 0,
      income: (json['income'] as num?)?.toDouble() ?? 0,
      expenseCents: json['expense_cents'] as int? ?? 0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0,
      balanceCents: json['balance_cents'] as int? ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TopCategoryItem {
  final int categoryId;
  final int totalCents;
  final double total;
  final int count;
  final String? categoryName;

  TopCategoryItem({
    required this.categoryId,
    required this.totalCents,
    required this.total,
    required this.count,
    this.categoryName,
  });

  factory TopCategoryItem.fromJson(Map<String, dynamic> json) {
    return TopCategoryItem(
      categoryId: json['category_id'] as int? ?? 0,
      totalCents: json['total_cents'] as int? ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      count: json['count'] as int? ?? 0,
      categoryName: json['category_name'] as String?,
    );
  }
}

class BreakdownItem {
  final int id;
  final int totalCents;
  final double total;
  final double? percentage;
  final int? incomeCents;
  final double? income;
  final int? expenseCents;
  final double? expense;
  final int? balanceCents;
  final double? balance;

  BreakdownItem({
    required this.id,
    required this.totalCents,
    required this.total,
    this.percentage,
    this.incomeCents,
    this.income,
    this.expenseCents,
    this.expense,
    this.balanceCents,
    this.balance,
  });

  factory BreakdownItem.fromJson(Map<String, dynamic> json) {
    return BreakdownItem(
      id: json['category_id'] as int? ?? json['wallet_id'] as int? ?? 0,
      totalCents: json['total_cents'] as int? ?? json['expense_cents'] as int? ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? (json['expense'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble(),
      incomeCents: json['income_cents'] as int?,
      income: (json['income'] as num?)?.toDouble(),
      expenseCents: json['expense_cents'] as int?,
      expense: (json['expense'] as num?)?.toDouble(),
      balanceCents: json['balance_cents'] as int?,
      balance: (json['balance'] as num?)?.toDouble(),
    );
  }
}

class BudgetEntity {
  final int id;
  final int categoryId;
  final String name;
  final String period;
  final String status;
  final int limitCents;
  final double limit;
  final int spentCents;
  final double spent;
  final double percentage;
  final int remainingCents;
  final double remaining;
  final String currency;
  final String startDate;
  final String? endDate;
  final int notifyAtPercentage;
  final bool isRollover;

  BudgetEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.period,
    required this.status,
    required this.limitCents,
    required this.limit,
    required this.spentCents,
    required this.spent,
    required this.percentage,
    required this.remainingCents,
    required this.remaining,
    required this.currency,
    required this.startDate,
    this.endDate,
    required this.notifyAtPercentage,
    required this.isRollover,
  });

  factory BudgetEntity.fromJson(Map<String, dynamic> json) {
    return BudgetEntity(
      id: json['id'] as int,
      categoryId: json['category_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      period: json['period'] as String? ?? 'monthly',
      status: json['status'] as String? ?? 'active',
      limitCents: json['limit_cents'] as int? ?? 0,
      limit: (json['limit'] as num?)?.toDouble() ?? 0,
      spentCents: json['spent_cents'] as int? ?? 0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      remainingCents: json['remaining_cents'] as int? ?? 0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String?,
      notifyAtPercentage: json['notify_at_percentage'] as int? ?? 80,
      isRollover: json['is_rollover'] as bool? ?? false,
    );
  }
}

class BudgetAlert {
  final int budgetId;
  final String name;
  final int limitCents;
  final double limit;
  final int spentCents;
  final double spent;
  final double percentage;
  final String severity;
  final String message;

  BudgetAlert({
    required this.budgetId,
    required this.name,
    required this.limitCents,
    required this.limit,
    required this.spentCents,
    required this.spent,
    required this.percentage,
    required this.severity,
    required this.message,
  });

  factory BudgetAlert.fromJson(Map<String, dynamic> json) {
    return BudgetAlert(
      budgetId: json['budget_id'] as int,
      name: json['name'] as String? ?? '',
      limitCents: json['limit_cents'] as int? ?? 0,
      limit: (json['limit'] as num?)?.toDouble() ?? 0,
      spentCents: json['spent_cents'] as int? ?? 0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      severity: json['severity'] as String? ?? 'warning',
      message: json['message'] as String? ?? '',
    );
  }
}
