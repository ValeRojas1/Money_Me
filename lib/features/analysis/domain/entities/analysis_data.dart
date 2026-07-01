class IncomeVsExpenses {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final double expenseRatio;

  const IncomeVsExpenses({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.expenseRatio,
  });

  factory IncomeVsExpenses.fromJson(Map<String, dynamic> json) {
    return IncomeVsExpenses(
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      expenseRatio: (json['expense_ratio'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MonthlyComparison {
  final String month;
  final double income;
  final double expenses;
  final double balance;
  final int count;

  const MonthlyComparison({
    required this.month,
    required this.income,
    required this.expenses,
    required this.balance,
    required this.count,
  });

  factory MonthlyComparison.fromJson(Map<String, dynamic> json) {
    return MonthlyComparison(
      month: json['month'] as String? ?? '',
      income: (json['income'] as num?)?.toDouble() ?? 0,
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      count: json['count'] as int? ?? 0,
    );
  }
}

class CategoryTrend {
  final int categoryId;
  final double total;
  final int count;
  final double avgPerMonth;

  const CategoryTrend({
    required this.categoryId,
    required this.total,
    required this.count,
    required this.avgPerMonth,
  });

  factory CategoryTrend.fromJson(Map<String, dynamic> json) {
    return CategoryTrend(
      categoryId: json['category_id'] as int? ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      count: json['count'] as int? ?? 0,
      avgPerMonth: (json['avg_per_month'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SpendingTrend {
  final String month;
  final double total;

  const SpendingTrend({required this.month, required this.total});

  factory SpendingTrend.fromJson(Map<String, dynamic> json) {
    return SpendingTrend(
      month: json['month'] as String? ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MovementFrequency {
  final double avgPerDay;
  final double avgPerWeek;
  final double avgPerMonth;
  final int total;
  final int expenseCount;
  final int incomeCount;

  const MovementFrequency({
    required this.avgPerDay,
    required this.avgPerWeek,
    required this.avgPerMonth,
    required this.total,
    required this.expenseCount,
    required this.incomeCount,
  });

  factory MovementFrequency.fromJson(Map<String, dynamic> json) {
    return MovementFrequency(
      avgPerDay: (json['avg_per_day'] as num?)?.toDouble() ?? 0,
      avgPerWeek: (json['avg_per_week'] as num?)?.toDouble() ?? 0,
      avgPerMonth: (json['avg_per_month'] as num?)?.toDouble() ?? 0,
      total: json['total'] as int? ?? 0,
      expenseCount: json['expense_count'] as int? ?? 0,
      incomeCount: json['income_count'] as int? ?? 0,
    );
  }
}

class AnomalyAlert {
  final String type;
  final String severity;
  final String title;
  final String message;

  const AnomalyAlert({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
  });

  factory AnomalyAlert.fromJson(Map<String, dynamic> json) {
    return AnomalyAlert(
      type: json['type'] as String? ?? '',
      severity: json['severity'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}
