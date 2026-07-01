import 'package:flutter/material.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:money_me/shared/widgets/money_card.dart';

class BudgetList extends StatelessWidget {
  final List<BudgetEntity> budgets;
  final void Function(BudgetEntity)? onTap;
  final void Function(BudgetEntity)? onDelete;

  const BudgetList({super.key, required this.budgets, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) {
      return MoneyCard(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.monetization_on_outlined, size: 32, color: AppColors.textSecondary),
                SizedBox(height: AppSpacing.sm),
                Text('No budgets set', style: AppTypography.bodyMedium),
                Text('Create budgets to track your spending', style: AppTypography.caption),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
          child: Text('Budgets', style: AppTypography.titleSmall),
        ),
        ...budgets.map((b) => _BudgetTile(budget: b, onTap: onTap, onDelete: onDelete)),
      ],
    );
  }
}

class _BudgetTile extends StatelessWidget {
  final BudgetEntity budget;
  final void Function(BudgetEntity)? onTap;
  final void Function(BudgetEntity)? onDelete;

  const _BudgetTile({required this.budget, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isOver = budget.percentage >= 100;
    final isWarning = budget.percentage >= budget.notifyAtPercentage && !isOver;
    final progressColor = isOver ? AppColors.error : (isWarning ? AppColors.warning : AppColors.success);

    return MoneyCard(
      onTap: onTap != null ? () => onTap!(budget) : null,
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(budget.name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              ),
              if (isOver)
                Icon(Icons.error, color: AppColors.error, size: 18)
              else if (isWarning)
                Icon(Icons.warning_amber, color: AppColors.warning, size: 18),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: AppColors.textSecondary),
                  onPressed: () => onDelete!(budget),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (budget.percentage / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(progressColor),
              minHeight: 8,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text('\$${budget.spent.toStringAsFixed(0)}', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              Text(' / \$${budget.limit.toStringAsFixed(0)}', style: AppTypography.caption),
              Spacer(),
              Text('${budget.percentage.toStringAsFixed(1)}%', style: AppTypography.caption.copyWith(color: progressColor, fontWeight: FontWeight.w600)),
            ],
          ),
          if (budget.remaining > 0 && !isOver)
            Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text('\$${budget.remaining.toStringAsFixed(2)} remaining', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
            ),
        ],
      ),
    );
  }
}

class BudgetAlertBanner extends StatelessWidget {
  final List<BudgetAlert> alerts;

  const BudgetAlertBanner({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final active = alerts.where((a) => a.percentage >= 80).toList();
    if (active.isEmpty) return SizedBox.shrink();

    return Column(
      children: active.map((a) {
        final isDanger = a.severity == 'danger';
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: AppSpacing.sm),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: (isDanger ? AppColors.error : AppColors.warning).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (isDanger ? AppColors.error : AppColors.warning).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                isDanger ? Icons.error : Icons.warning_amber,
                color: isDanger ? AppColors.error : AppColors.warning,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(a.message, style: AppTypography.bodySmall)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
