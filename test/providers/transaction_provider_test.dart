import 'package:flutter_test/flutter_test.dart';
import 'package:money_me/features/transactions/domain/entities/transaction_entity.dart';
import 'package:money_me/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:money_me/features/transactions/presentation/providers/transaction_provider.dart';

class MockTransactionRepository implements TransactionRepository {
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
    final items = [TransactionEntity(
      id: 1, walletId: 1, categoryId: 1, type: 'expense',
      amountCents: 5000, amount: 50.0, currency: 'USD',
      description: 'Test', transactionDate: '2026-07-01', status: 'completed',
    )];
    return TransactionListResponse(items: items, total: 1, page: page, pages: 1, limit: 20);
  }

  @override
  Future<TransactionEntity> get(int id) async {
    return TransactionEntity(
      id: id, walletId: 1, categoryId: 1, type: 'expense',
      amountCents: 5000, amount: 50.0, currency: 'USD',
      description: 'Test', transactionDate: '2026-07-01', status: 'completed',
    );
  }

  @override
  Future<TransactionEntity> create(Map<String, dynamic> data) async {
    return TransactionEntity(
      id: 1, walletId: 1, categoryId: 1, type: 'expense',
      amountCents: data['amount_cents'] as int? ?? 0,
      amount: (data['amount_cents'] as int? ?? 0) / 100.0,
      currency: data['currency'] as String? ?? 'USD',
      description: data['description'] as String? ?? '',
      transactionDate: data['transaction_date'] as String? ?? '',
      status: 'completed',
    );
  }

  @override
  Future<TransactionEntity> update(int id, Map<String, dynamic> data) async {
    return TransactionEntity(
      id: id, walletId: 1, categoryId: 1, type: 'expense',
      amountCents: 5000, amount: 50.0, currency: 'USD',
      description: data['description'] as String? ?? 'Updated',
      transactionDate: '2026-07-01', status: 'completed',
    );
  }

  @override
  Future<void> delete(int id) async {}

  @override
  Future<Map<String, dynamic>> categorizeSuggestion(int id) async {
    return {'suggested_category_name': 'Food', 'confidence': 0.85};
  }
}

void main() {
  late MockTransactionRepository repository;
  late TransactionProvider provider;

  setUp(() {
    repository = MockTransactionRepository();
    provider = TransactionProvider(repository: repository);
  });

  group('TransactionProvider', () {
    test('initial state is empty', () {
      expect(provider.transactions, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
      expect(provider.total, 0);
      expect(provider.page, 1);
    });

    test('loadTransactions populates list', () async {
      await provider.loadTransactions();
      expect(provider.transactions, isNotEmpty);
      expect(provider.transactions.length, 1);
      expect(provider.total, 1);
    });

    test('create adds transaction and reloads', () async {
      final tx = await provider.create({
        'amount_cents': 10000,
        'description': 'New transaction',
        'type': 'expense',
        'transaction_date': '2026-07-03',
      });
      expect(tx, isNotNull);
      expect(tx!.description, 'New transaction');
    });

    test('update returns true on success', () async {
      final result = await provider.update(1, {'description': 'Updated'});
      expect(result, isTrue);
    });

    test('delete returns true on success', () async {
      final result = await provider.delete(1);
      expect(result, isTrue);
    });

    test('setSort resets page and reloads', () async {
      provider.setSort('amount', 'asc');
      expect(provider.sortBy, 'amount');
      expect(provider.sortOrder, 'asc');
      expect(provider.page, 1);
    });

    test('setSearch triggers load', () async {
      await provider.loadTransactions();
      expect(provider.transactions, isNotEmpty);
      provider.setSearch('test');
      await Future.microtask(() {});
      expect(provider.transactions, isNotEmpty);
    });

    test('clearFilters resets filters', () async {
      await provider.loadTransactions();
      expect(provider.transactions, isNotEmpty);
      provider.clearFilters();
      await Future.microtask(() {});
      expect(provider.transactions, isNotEmpty);
    });

    test('nextPage increments page when not at end', () async {
      await provider.loadTransactions();
      final currentPage = provider.page;
      provider.nextPage();
      expect(provider.page, currentPage);
    });

    test('categorizeSuggestion returns suggestion', () async {
      final suggestion = await provider.categorizeSuggestion(1);
      expect(suggestion, isNotNull);
      expect(suggestion!['suggested_category_name'], 'Food');
    });
  });
}
