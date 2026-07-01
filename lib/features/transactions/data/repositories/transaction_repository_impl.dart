import 'package:money_me/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:money_me/features/transactions/domain/entities/transaction_entity.dart';
import 'package:money_me/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource dataSource;

  TransactionRepositoryImpl({required this.dataSource});

  @override
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
  }) async {
    final json = await dataSource.list(
      search: search,
      categoryId: categoryId,
      type: type,
      walletId: walletId,
      status: status,
      startDate: startDate,
      endDate: endDate,
      sortBy: sortBy,
      sortOrder: sortOrder,
      page: page,
      limit: limit,
    );
    return TransactionListResponse.fromJson(json);
  }

  @override
  Future<TransactionEntity> get(int id) async {
    final json = await dataSource.get(id);
    return TransactionEntity.fromJson(json);
  }

  @override
  Future<TransactionEntity> create(Map<String, dynamic> data) async {
    final json = await dataSource.create(data);
    return TransactionEntity.fromJson(json);
  }

  @override
  Future<TransactionEntity> update(int id, Map<String, dynamic> data) async {
    final json = await dataSource.update(id, data);
    return TransactionEntity.fromJson(json);
  }

  @override
  Future<void> delete(int id) async {
    await dataSource.delete(id);
  }

  @override
  Future<Map<String, dynamic>> categorizeSuggestion(int id) async {
    return await dataSource.categorizeSuggestion(id);
  }
}
