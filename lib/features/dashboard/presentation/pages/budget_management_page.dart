import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:money_me/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:money_me/shared/widgets/money_button.dart';
import 'package:money_me/shared/widgets/money_form_field.dart';

class BudgetManagementPage extends StatefulWidget {
  const BudgetManagementPage({super.key});

  @override
  State<BudgetManagementPage> createState() => _BudgetManagementPageState();
}

class _BudgetManagementPageState extends State<BudgetManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadAll();
    });
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final limitCtrl = TextEditingController();
    final notifyCtrl = TextEditingController(text: '80');
    String period = 'monthly';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New budget'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MoneyFormField(label: 'Name', controller: nameCtrl),
                SizedBox(height: AppSpacing.sm),
                MoneyFormField(label: 'Limit (\$)', controller: limitCtrl, keyboardType: TextInputType.number),
                SizedBox(height: AppSpacing.sm),
                Text('Period', style: AppTypography.labelMedium),
                SizedBox(height: AppSpacing.xs),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'weekly', label: Text('Week')),
                    ButtonSegment(value: 'monthly', label: Text('Month')),
                    ButtonSegment(value: 'annual', label: Text('Year')),
                  ],
                  selected: {period},
                  onSelectionChanged: (v) => setDialogState(() => period = v.first),
                ),
                SizedBox(height: AppSpacing.sm),
                MoneyFormField(label: 'Alert at %', controller: notifyCtrl, keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            MoneyButton(
              label: 'Create',
              onPressed: () async {
                final limit = double.tryParse(limitCtrl.text) ?? 0;
                if (nameCtrl.text.isNotEmpty && limit > 0) {
                  await context.read<DashboardProvider>().createBudget({
                    'name': nameCtrl.text,
                    'category_id': 1,
                    'period': period,
                    'limit_cents': (limit * 100).round(),
                    'notify_at_percentage': int.tryParse(notifyCtrl.text) ?? 80,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteBudget(BudgetEntity budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete budget?'),
        content: Text('Delete "${budget.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      context.read<DashboardProvider>().deleteBudget(budget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget management')),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.budgets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.md),
              children: [
                ...provider.alerts
                    .map((a) => _AlertTile(alert: a)),
                SizedBox(height: AppSpacing.md),
                if (provider.budgets.isEmpty)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 60),
                        Icon(Icons.monetization_on_outlined, size: 64, color: AppColors.textSecondary),
                        SizedBox(height: AppSpacing.md),
                        Text('No budgets yet', style: AppTypography.titleMedium),
                        Text('Create your first budget to track spending', style: AppTypography.caption),
                      ],
                    ),
                  )
                else
                  ...provider.budgets.map((b) => _BudgetEditTile(
                    budget: b,
                    provider: provider,
                    onDelete: () => _deleteBudget(b),
                  )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final dynamic alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isDanger = alert.severity == 'danger';
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: (isDanger ? AppColors.error : AppColors.warning).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (isDanger ? AppColors.error : AppColors.warning).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(isDanger ? Icons.error : Icons.warning_amber, color: isDanger ? AppColors.error : AppColors.warning, size: 20),
          SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(alert.message, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}

class _BudgetEditTile extends StatelessWidget {
  final BudgetEntity budget;
  final DashboardProvider provider;
  final VoidCallback onDelete;

  const _BudgetEditTile({required this.budget, required this.provider, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isOver = budget.percentage >= 100;
    final isWarning = budget.percentage >= budget.notifyAtPercentage && !isOver;
    final progressColor = isOver ? AppColors.error : (isWarning ? AppColors.warning : AppColors.success);

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(budget.name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600))),
                Text(budget.period, style: AppTypography.caption),
                SizedBox(width: AppSpacing.sm),
                IconButton(icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error), onPressed: onDelete, visualDensity: VisualDensity.compact),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (budget.percentage / 100).clamp(0.0, 1.0),
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(progressColor),
                minHeight: 10,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Text('\$${budget.spent.toStringAsFixed(2)} spent', style: AppTypography.bodySmall),
                Spacer(),
                Text('of \$${budget.limit.toStringAsFixed(2)}', style: AppTypography.caption),
                SizedBox(width: AppSpacing.sm),
                Text('${budget.percentage.toStringAsFixed(1)}%', style: AppTypography.bodySmall.copyWith(color: progressColor, fontWeight: FontWeight.w600)),
              ],
            ),
            if (budget.remaining > 0 && !isOver)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('\$${budget.remaining.toStringAsFixed(2)} remaining', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              ),
          ],
        ),
      ),
    );
  }
}
