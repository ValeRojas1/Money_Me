import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:money_me/features/dashboard/presentation/widgets/summary_cards.dart';
import 'package:money_me/features/dashboard/presentation/widgets/dashboard_charts.dart';
import 'package:money_me/features/dashboard/presentation/widgets/budget_list.dart';
import 'package:money_me/features/dashboard/presentation/pages/budget_management_page.dart';
import 'package:money_me/shared/widgets/money_button.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadAll(month: _selectedMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.monetization_on_outlined),
            tooltip: 'Budgets',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BudgetManagementPage()),
            ),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.summary == null) {
            return RefreshIndicator(
              onRefresh: () => provider.refresh(month: _selectedMonth),
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: const [
                  SummarySkeleton(),
                ],
              ),
            );
          }

          if (provider.error != null && provider.summary == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  SizedBox(height: AppSpacing.sm),
                  Text(provider.error!, style: AppTypography.bodyMedium),
                  SizedBox(height: AppSpacing.md),
                  MoneyButton(
                    label: 'Retry',
                    onPressed: () => provider.loadAll(month: _selectedMonth),
                  ),
                ],
              ),
            );
          }

          final summary = provider.summary;

          return RefreshIndicator(
            onRefresh: () => provider.refresh(month: _selectedMonth),
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.md),
              children: [
                if (summary != null) ...[
                  SummaryCards(summary: summary),
                  SizedBox(height: AppSpacing.lg),
                ],
                BudgetAlertBanner(alerts: provider.alerts),
                SizedBox(height: AppSpacing.sm),
                TrendChart(data: provider.monthlyTrend),
                SizedBox(height: AppSpacing.md),
                if (provider.categoryBreakdown.isNotEmpty) ...[
                  CategoryPieChart(data: provider.categoryBreakdown),
                  SizedBox(height: AppSpacing.md),
                ],
                TopCategoriesList(items: provider.topCategories),
                SizedBox(height: AppSpacing.md),
                if (provider.walletBreakdown.isNotEmpty) ...[
                  WalletBarChart(data: provider.walletBreakdown),
                  SizedBox(height: AppSpacing.md),
                ],
                BudgetList(
                  budgets: provider.budgets,
                  onTap: (b) => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BudgetManagementPage()),
                  ),
                ),
                SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
