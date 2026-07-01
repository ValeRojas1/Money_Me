enum AlertType {
  budgetThreshold,
  largeTransaction,
  unusualActivity,
  lowBalance,
  billReminder,
  savingsGoal,
  predictionAlert,
}

enum AlertSeverity { info, warning, critical }
enum AlertStatus { unread, read, dismissed, triggered }

class Alert {
  final int id;
  final int userId;
  final AlertType type;
  final AlertSeverity severity;
  final AlertStatus status;
  final String title;
  final String message;
  final String? referenceType;
  final int? referenceId;
  final double? thresholdValue;
  final double? currentValue;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const Alert({
    required this.id,
    required this.userId,
    required this.type,
    this.severity = AlertSeverity.info,
    this.status = AlertStatus.unread,
    required this.title,
    required this.message,
    this.referenceType,
    this.referenceId,
    this.thresholdValue,
    this.currentValue,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });
}
