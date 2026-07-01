enum PredictionType {
  monthlySpending,
  categorySpending,
  savingsGoal,
  cashFlow,
  budgetRecommendation,
}

enum PredictionStatus { pending, completed, failed }

class Prediction {
  final int id;
  final int userId;
  final PredictionType type;
  final PredictionStatus status;
  final int? predictedAmountCents;
  final double? confidenceScore;
  final DateTime predictionDate;
  final DateTime? targetDate;
  final int? categoryId;
  final String? resultData;
  final String? modelVersion;
  final String? errorMessage;
  final DateTime createdAt;

  const Prediction({
    required this.id,
    required this.userId,
    required this.type,
    this.status = PredictionStatus.pending,
    this.predictedAmountCents,
    this.confidenceScore,
    required this.predictionDate,
    this.targetDate,
    this.categoryId,
    this.resultData,
    this.modelVersion,
    this.errorMessage,
    required this.createdAt,
  });

  double? get predictedAmount =>
      predictedAmountCents != null ? predictedAmountCents! / 100 : null;
}
