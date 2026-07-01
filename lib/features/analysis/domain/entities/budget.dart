enum BudgetPeriod { weekly, monthly, quarterly, annual, custom }
enum BudgetStatus { active, paused, completed, expired }

class Budget {
  final int id;
  final int userId;
  final int categoryId;
  final String name;
  final BudgetPeriod period;
  final BudgetStatus status;
  final int limitCents;
  final int spentCents;
  final String currency;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isRollover;
  final int notifyAtPercentage;
  final DateTime createdAt;

  const Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.name,
    required this.period,
    this.status = BudgetStatus.active,
    required this.limitCents,
    this.spentCents = 0,
    this.currency = 'USD',
    required this.startDate,
    this.endDate,
    this.isRollover = false,
    this.notifyAtPercentage = 80,
    required this.createdAt,
  });

  double get limit => limitCents / 100;
  double get spent => spentCents / 100;
  double get remaining => (limitCents - spentCents) / 100;
  double get usagePercentage => limitCents > 0 ? (spentCents / limitCents) * 100 : 0;
}
