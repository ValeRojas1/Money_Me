import 'package:money_me/features/transactions/domain/entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<TransactionListResponse> list({
    String? search,
    int? categoryId,
    String? type,
    int? walletId,
    String? status,
    String? startDate,
    String? endDate,
    String sortBy = 'date',
    String sortOrder = 'desc',
    int page = 1,
    int limit = 20,
  });

  Future<TransactionEntity> get(int id);

  Future<TransactionEntity> create(Map<String, dynamic> data);

  Future<TransactionEntity> update(int id, Map<String, dynamic> data);

  Future<void> delete(int id);

  Future<Map<String, dynamic>> categorizeSuggestion(int id);
}
