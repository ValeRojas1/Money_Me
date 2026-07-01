class SpendingForecast {
  final double predictedAmount;
  final double confidence;
  final String method;
  final String? trendDirection;

  const SpendingForecast({
    required this.predictedAmount,
    required this.confidence,
    this.method = 'hybrid',
    this.trendDirection,
  });

  factory SpendingForecast.fromJson(Map<String, dynamic> json) {
    return SpendingForecast(
      predictedAmount: (json['predicted_amount'] as num?)?.toDouble() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      method: json['method'] as String? ?? 'average',
      trendDirection: json['trend_direction'] as String?,
    );
  }
}

class IncomeForecast {
  final double predictedIncome;
  final double confidence;
  final bool isRegular;

  const IncomeForecast({
    required this.predictedIncome,
    required this.confidence,
    required this.isRegular,
  });

  factory IncomeForecast.fromJson(Map<String, dynamic> json) {
    return IncomeForecast(
      predictedIncome: (json['predicted_income'] as num?)?.toDouble() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      isRegular: json['is_regular'] as bool? ?? false,
    );
  }
}

class WalletForecast {
  final int walletId;
  final double currentBalance;
  final double projectedBalance;
  final double monthlyNet;

  const WalletForecast({
    required this.walletId,
    required this.currentBalance,
    required this.projectedBalance,
    required this.monthlyNet,
  });

  factory WalletForecast.fromJson(Map<String, dynamic> json) {
    return WalletForecast(
      walletId: json['wallet_id'] as int? ?? 0,
      currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0,
      projectedBalance: (json['projected_balance'] as num?)?.toDouble() ?? 0,
      monthlyNet: (json['monthly_net'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SavingsGoalProjection {
  final double goalAmount;
  final double currentSavings;
  final bool goalAchieved;
  final int estimatedMonths;
  final String estimatedDate;

  const SavingsGoalProjection({
    required this.goalAmount,
    required this.currentSavings,
    required this.goalAchieved,
    required this.estimatedMonths,
    required this.estimatedDate,
  });

  factory SavingsGoalProjection.fromJson(Map<String, dynamic> json) {
    return SavingsGoalProjection(
      goalAmount: (json['goal_amount_cents'] as num?)?.toDouble() ?? 0 / 100,
      currentSavings: (json['current_savings_cents'] as num?)?.toDouble() ?? 0 / 100,
      goalAchieved: json['goal_achieved'] as bool? ?? false,
      estimatedMonths: json['estimated_months'] as int? ?? 0,
      estimatedDate: json['estimated_date'] as String? ?? '',
    );
  }
}

class FinancialTip {
  final String type;
  final String priority;
  final String icon;
  final String title;
  final String message;

  const FinancialTip({
    required this.type,
    required this.priority,
    required this.icon,
    required this.title,
    required this.message,
  });

  factory FinancialTip.fromJson(Map<String, dynamic> json) {
    return FinancialTip(
      type: json['type'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      icon: json['icon'] as String? ?? 'info',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}
