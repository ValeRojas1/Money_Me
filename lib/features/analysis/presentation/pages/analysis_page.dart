import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/features/analysis/domain/entities/analysis_data.dart';
import 'package:money_me/features/analysis/presentation/providers/analysis_provider.dart';
import 'package:money_me/shared/widgets/money_card.dart';
import 'package:money_me/shared/widgets/money_alert.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis')),
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, _) {
          if (provider.status == AnalysisStatus.initial) {
            provider.loadAll();
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.status == AnalysisStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.status == AnalysisStatus.error) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    SizedBox(height: AppSpacing.md),
                    Text(provider.errorMessage ?? 'Unable to load analysis',
                        style: AppTypography.bodyMedium),
                    SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: provider.loadAll,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadAll(),
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.md),
              children: [
                _IncomeExpenseCard(provider),
                SizedBox(height: AppSpacing.md),
                _SpendingTrendCard(provider),
                SizedBox(height: AppSpacing.md),
                _CategoryCard(provider),
                SizedBox(height: AppSpacing.md),
                _AlertsCard(provider),
                SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IncomeExpenseCard extends StatelessWidget {
  final AnalysisProvider provider;
  const _IncomeExpenseCard(this.provider);

  @override
  Widget build(BuildContext context) {
    final ive = provider.incomeVsExpenses;
    if (ive == null) return const SizedBox.shrink();

    return MoneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Income vs Expenses', style: AppTypography.titleMedium),
          SizedBox(height: AppSpacing.md),
          _row('Income', '\$${ive.totalIncome.toStringAsFixed(2)}', AppColors.income),
          _row('Expenses', '\$${ive.totalExpenses.toStringAsFixed(2)}', AppColors.expense),
          Divider(color: AppColors.divider),
          _row('Balance', '\$${ive.balance.toStringAsFixed(2)}',
              ive.balance >= 0 ? AppColors.income : AppColors.expense),
          SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (ive.expenseRatio / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(
                ive.expenseRatio > 90 ? AppColors.error : AppColors.warning),
              minHeight: 8,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text('${ive.expenseRatio.toStringAsFixed(0)}% of income spent',
              style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(value, style: AppTypography.amountSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _SpendingTrendCard extends StatelessWidget {
  final AnalysisProvider provider;
  const _SpendingTrendCard(this.provider);

  @override
  Widget build(BuildContext context) {
    final trends = provider.spendingTrends;
    if (trends.isEmpty) return const SizedBox.shrink();

    return MoneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending Trend', style: AppTypography.titleMedium),
          SizedBox(height: AppSpacing.sm),
          ...trends.reversed.take(6).map((t) => Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.month, style: AppTypography.bodySmall),
                Text('\$${t.total.toStringAsFixed(2)}',
                    style: AppTypography.amountSmall),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AnalysisProvider provider;
  const _CategoryCard(this.provider);

  @override
  Widget build(BuildContext context) {
    final cats = provider.categoryTrends;
    if (cats.isEmpty) return const SizedBox.shrink();

    final total = cats.fold<double>(0, (s, c) => s + c.total);

    return MoneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Categories', style: AppTypography.titleMedium),
          SizedBox(height: AppSpacing.sm),
          ...cats.take(5).map((c) {
            final pct = total > 0 ? c.total / total * 100 : 0.0;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Category #${c.categoryId}', style: AppTypography.bodyMedium),
                      Text('\$${c.total.toStringAsFixed(2)}',
                          style: AppTypography.amountSmall),
                    ],
                  ),
                  SizedBox(height: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (pct / 100).clamp(0.0, 1.0),
                      backgroundColor: AppColors.surfaceVariant,
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  final AnalysisProvider provider;
  const _AlertsCard(this.provider);

  @override
  Widget build(BuildContext context) {
    final alerts = provider.alerts;
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Alerts', style: AppTypography.titleMedium),
        SizedBox(height: AppSpacing.sm),
        ...alerts.map((a) => Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: MoneyAlert(
            type: a.severity == 'critical' ? MoneyAlertType.error : MoneyAlertType.warning,
            title: a.title,
            message: a.message,
          ),
        )),
      ],
    );
  }
}
