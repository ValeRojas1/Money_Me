import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/features/transactions/domain/entities/transaction_entity.dart';
import 'package:money_me/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:money_me/shared/widgets/money_card.dart';
import 'package:money_me/shared/widgets/money_form_field.dart';

class TransactionDetailPage extends StatefulWidget {
  final TransactionEntity? transaction;

  const TransactionDetailPage({super.key, this.transaction});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  String _type = 'expense';

  bool _isSaving = false;
  bool get _isCreate => widget.transaction == null;

  @override
  void initState() {
    super.initState();
    if (!_isCreate) {
      final t = widget.transaction!;
      _descCtrl.text = t.description;
      _amountCtrl.text = t.amount.toStringAsFixed(2);
      _dateCtrl.text = t.transactionDate;
      _notesCtrl.text = t.notes ?? '';
      _tagsCtrl.text = t.tags ?? '';
      _type = t.type;
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _notesCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final amountCents = (amount * 100).round();

    bool success;
    if (_isCreate) {
      final tx = await context.read<TransactionProvider>().create({
        'description': _descCtrl.text,
        'amount_cents': amountCents,
        'type': _type,
        'transaction_date': _dateCtrl.text.isNotEmpty
            ? _dateCtrl.text
            : DateTime.now().toIso8601String().split('T')[0],
        'notes': _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        'tags': _tagsCtrl.text.isNotEmpty ? _tagsCtrl.text : null,
      });
      success = tx != null;
    } else {
      success = await context.read<TransactionProvider>().update(
            widget.transaction!.id,
            {
              'description': _descCtrl.text,
              'amount_cents': amountCents,
              'type': _type,
              'transaction_date': _dateCtrl.text,
              'notes': _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
              'tags': _tagsCtrl.text.isNotEmpty ? _tagsCtrl.text : null,
            },
          );
    }

    setState(() => _isSaving = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isCreate ? 'Transaction created' : 'Transaction updated'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This action cannot be undone.'),
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
      final success = await context.read<TransactionProvider>().delete(widget.transaction!.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == 'expense';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreate ? 'New transaction' : 'Transaction'),
        actions: [
          if (!_isCreate)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _delete,
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isCreate) ...[
              MoneyCard(
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.md),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: (isExpense ? AppColors.expense : AppColors.income)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        isExpense ? Icons.trending_down : Icons.trending_up,
                        color: isExpense ? AppColors.expense : AppColors.income,
                        size: 28,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      '${isExpense ? '-' : '+'}\$${widget.transaction!.amount.toStringAsFixed(2)}',
                      style: AppTypography.amountLarge.copyWith(
                        color: isExpense ? AppColors.expense : AppColors.income,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(widget.transaction!.type.toUpperCase(), style: AppTypography.caption),
                    SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md),
            ],
            MoneyFormField(label: 'Description', controller: _descCtrl),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: MoneyFormField(
                    label: 'Amount (\$)',
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MoneyFormField(label: 'Date (YYYY-MM-DD)', controller: _dateCtrl),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text('Type', style: AppTypography.labelLarge),
            SizedBox(height: AppSpacing.xs),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense')),
                ButtonSegment(value: 'income', label: Text('Income')),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            SizedBox(height: AppSpacing.sm),
            MoneyFormField(label: 'Notes', controller: _notesCtrl, maxLines: 3),
            SizedBox(height: AppSpacing.sm),
            MoneyFormField(label: 'Tags (comma separated)', controller: _tagsCtrl),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}
