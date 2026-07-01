enum MovementType { income, expense, transfer }
enum MovementStatus { pending, completed, cancelled, reconciled }

class Movement {
  final int id;
  final int walletId;
  final int categoryId;
  final int userId;
  final MovementType type;
  final MovementStatus status;
  final int amountCents;
  final String currency;
  final String description;
  final String? notes;
  final DateTime transactionDate;
  final bool isRecurring;
  final String? recurringFrequency;
  final String? tags;
  final String? receiptUrl;
  final int? captureId;
  final int? transferToWalletId;
  final double? exchangeRate;
  final int? originalAmountCents;
  final String? originalCurrency;
  final DateTime createdAt;

  const Movement({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.userId,
    required this.type,
    this.status = MovementStatus.completed,
    required this.amountCents,
    this.currency = 'USD',
    required this.description,
    this.notes,
    required this.transactionDate,
    this.isRecurring = false,
    this.recurringFrequency,
    this.tags,
    this.receiptUrl,
    this.captureId,
    this.transferToWalletId,
    this.exchangeRate,
    this.originalAmountCents,
    this.originalCurrency,
    required this.createdAt,
  });

  double get amount => amountCents / 100;
}
