import 'package:flutter/foundation.dart';

import 'package:money_me/features/transactions/domain/entities/category_entity.dart';
import 'package:money_me/features/transactions/domain/entities/transaction_entity.dart';
import 'package:money_me/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository repository;

  TransactionProvider({required this.repository});

  List<TransactionEntity> _transactions = [];
  List<TransactionEntity> get transactions => _transactions;

  List<CategoryEntity> _categories = [];
  List<CategoryEntity> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _total = 0;
  int get total => _total;

  int _page = 1;
  int get page => _page;

  int _pages = 1;
  int get pages => _pages;

  String _sortBy = 'date';
  String get sortBy => _sortBy;

  String _sortOrder = 'desc';
  String get sortOrder => _sortOrder;

  String? _search;
  int? _categoryId;
  String? _typeFilter;
  int? _walletId;
  String? _statusFilter;
  String? _startDate;
  String? _endDate;

  void setSort(String by, String order) {
    _sortBy = by;
    _sortOrder = order;
    _page = 1;
    loadTransactions();
  }

  void setSearch(String? q) {
    _search = q;
    _page = 1;
    loadTransactions();
  }

  void setFilters({
    int? categoryId,
    String? type,
    int? walletId,
    String? status,
    String? startDate,
    String? endDate,
  }) {
    _categoryId = categoryId;
    _typeFilter = type;
    _walletId = walletId;
    _statusFilter = status;
    _startDate = startDate;
    _endDate = endDate;
    _page = 1;
    loadTransactions();
  }

  void clearFilters() {
    _categoryId = null;
    _typeFilter = null;
    _walletId = null;
    _statusFilter = null;
    _startDate = null;
    _endDate = null;
    _search = null;
    _page = 1;
    loadTransactions();
  }

  void nextPage() {
    if (_page < _pages) {
      _page++;
      loadTransactions();
    }
  }

  void previousPage() {
    if (_page > 1) {
      _page--;
      loadTransactions();
    }
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await repository.list(
        search: _search,
        categoryId: _categoryId,
        type: _typeFilter,
        walletId: _walletId,
        status: _statusFilter,
        startDate: _startDate,
        endDate: _endDate,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        page: _page,
        limit: 20,
      );
      _transactions = result.items;
      _total = result.total;
      _page = result.page;
      _pages = result.pages;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<TransactionEntity?> create(Map<String, dynamic> data) async {
    try {
      final tx = await repository.create(data);
      loadTransactions();
      return tx;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> update(int id, Map<String, dynamic> data) async {
    try {
      await repository.update(id, data);
      loadTransactions();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await repository.delete(id);
      loadTransactions();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> categorizeSuggestion(int id) async {
    try {
      return await repository.categorizeSuggestion(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> loadCategories({String? type}) async {
    try {
      final jsonList = await (repository as dynamic)
          .dataSource
          .categories(type: type);
      _categories = jsonList
          .map((j) => CategoryEntity.fromJson(j as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
