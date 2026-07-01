import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:money_me/features/transactions/presentation/widgets/transaction_filters.dart';
import 'package:money_me/features/transactions/presentation/widgets/transaction_tile.dart';
import 'package:money_me/features/transactions/presentation/pages/transaction_detail_page.dart';
import 'package:money_me/features/transactions/presentation/pages/categories_page.dart';
import 'package:money_me/shared/widgets/money_button.dart';
import 'package:money_me/shared/widgets/money_form_field.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters({
    int? categoryId,
    String? type,
    int? walletId,
    String? status,
    String? startDate,
    String? endDate,
  }) {
    context.read<TransactionProvider>().setFilters(
          categoryId: categoryId,
          type: type,
          walletId: walletId,
          status: status,
          startDate: startDate,
          endDate: endDate,
        );
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TransactionFilters(
        onApply: _applyFilters,
        onClear: () => context.read<TransactionProvider>().clearFilters(),
      ),
    );
  }

  void _openSort() {
    final p = context.read<TransactionProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SortBottomSheet(
        sortBy: p.sortBy,
        sortOrder: p.sortOrder,
        onApply: p.setSort,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: MoneyFormField(
                    hintText: 'Search transactions...',
                    prefixIcon: Icons.search,
                    controller: _searchCtrl,
                    onSubmitted: (v) => context
                        .read<TransactionProvider>()
                        .setSearch(v),
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _openFilters,
                  tooltip: 'Filters',
                ),
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: _openSort,
                  tooltip: 'Sort',
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.transactions.isEmpty) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: 8,
                    itemBuilder: (_, __) => Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: TransactionSkeleton(),
                    ),
                  );
                }

                if (provider.error != null && provider.transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: AppColors.error),
                        SizedBox(height: AppSpacing.sm),
                        Text(provider.error!, style: AppTypography.bodyMedium),
                        SizedBox(height: AppSpacing.md),
                        MoneyButton(
                          label: 'Retry',
                          onPressed: provider.loadTransactions,
                        ),
                      ],
                    ),
                  );
                }

                if (provider.transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            size: 48, color: AppColors.textSecondary),
                        SizedBox(height: AppSpacing.sm),
                        Text('No transactions found',
                            style: AppTypography.bodyMedium),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'Add your first transaction or adjust filters.',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadTransactions(),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: provider.transactions.length + 1,
                    itemBuilder: (context, index) {
                      if (index == provider.transactions.length) {
                        return _PaginationBar(provider: provider);
                      }
                      final tx = provider.transactions[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: TransactionTile(
                          transaction: tx,
                          onTap: () async {
                            final changed = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TransactionDetailPage(transaction: tx),
                              ),
                            );
                            if (changed == true) {
                              provider.loadTransactions();
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'categories',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesPage()),
            ),
            child: const Icon(Icons.category_outlined),
          ),
          SizedBox(height: AppSpacing.sm),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TransactionDetailPage(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final TransactionProvider provider;
  const _PaginationBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: provider.page > 1 ? provider.previousPage : null,
          ),
          Text(
            'Page ${provider.page} of ${provider.pages}',
            style: AppTypography.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                provider.page < provider.pages ? provider.nextPage : null,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            '(${provider.total} total)',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}
