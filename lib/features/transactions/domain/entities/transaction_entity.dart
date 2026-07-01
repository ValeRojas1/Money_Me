class TransactionEntity {
  final int id;
  final int walletId;
  final int categoryId;
  final String type;
  final int amountCents;
  final double amount;
  final String currency;
  final String description;
  final String? notes;
  final String transactionDate;
  final String status;
  final bool isRecurring;
  final String? recurringFrequency;
  final String? tags;
  final int? captureId;
  final String? createdAt;

  TransactionEntity({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.type,
    required this.amountCents,
    required this.amount,
    required this.currency,
    required this.description,
    this.notes,
    required this.transactionDate,
    required this.status,
    this.isRecurring = false,
    this.recurringFrequency,
    this.tags,
    this.captureId,
    this.createdAt,
  });

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json['id'] as int,
      walletId: json['wallet_id'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 0,
      type: json['type'] as String? ?? 'expense',
      amountCents: json['amount_cents'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      description: json['description'] as String? ?? '',
      notes: json['notes'] as String?,
      transactionDate: json['transaction_date'] as String? ?? '',
      status: json['status'] as String? ?? 'completed',
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringFrequency: json['recurring_frequency'] as String?,
      tags: json['tags'] as String?,
      captureId: json['capture_id'] as int?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'category_id': categoryId,
      'type': type,
      'amount_cents': amountCents,
      'description': description,
      'notes': notes,
      'transaction_date': transactionDate,
      'tags': tags,
    };
  }
}

class TransactionListResponse {
  final List<TransactionEntity> items;
  final int total;
  final int page;
  final int limit;
  final int pages;

  TransactionListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    return TransactionListResponse(
      items: (json['items'] as List)
          .map((e) => TransactionEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      pages: json['pages'] as int? ?? 1,
    );
  }
}
