import 'package:flutter/material.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:money_me/shared/widgets/money_card.dart';

class SummaryCards extends StatelessWidget {
  final DashboardSummary summary;

  const SummaryCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildCard('Income', summary.income, summary.incomeVariation, AppColors.success, Icons.trending_up)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildCard('Expenses', summary.expense, summary.expenseVariation, AppColors.error, Icons.trending_down)),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        _buildBalanceCard(),
      ],
    );
  }

  Widget _buildCard(String label, double amount, double? variation, Color color, IconData icon) {
    final isPositive = variation != null && variation >= 0;
    return MoneyCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: AppSpacing.xs),
              Text(label, style: AppTypography.caption),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text('\$${amount.toStringAsFixed(2)}', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
          if (variation != null)
            Row(
              children: [
                Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: isPositive ? AppColors.error : AppColors.success),
                SizedBox(width: 2),
                Text('${isPositive ? '+' : ''}$variation% vs last month', style: AppTypography.caption.copyWith(color: isPositive ? AppColors.error : AppColors.success)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final isPositive = summary.balance >= 0;
    return MoneyCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: isPositive ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(isPositive ? Icons.account_balance_wallet : Icons.warning_amber, color: isPositive ? AppColors.success : AppColors.error, size: 24),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estimated balance', style: AppTypography.caption),
                Text(
                  '\$${summary.balance.toStringAsFixed(2)}',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPositive ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          Text('${summary.transactionCount} txns', style: AppTypography.caption),
        ],
      ),
    );
  }
}

class SummarySkeleton extends StatelessWidget {
  const SummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _cardSkeleton()),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _cardSkeleton()),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        _cardSkeleton(higher: true),
      ],
    );
  }

  Widget _cardSkeleton({bool higher = false}) {
    return MoneyCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 12, width: 60, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(4))),
          SizedBox(height: AppSpacing.sm),
          Container(height: 20, width: 100, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(4))),
          if (higher) SizedBox(height: 6),
          if (higher) Container(height: 10, width: 120, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(4))),
        ],
      ),
    );
  }
}
