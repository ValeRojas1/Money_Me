import 'package:flutter/material.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/shared/widgets/money_button.dart';
import 'package:money_me/shared/widgets/money_form_field.dart';

class TransactionFilters extends StatefulWidget {
  final void Function({
    int? categoryId,
    String? type,
    int? walletId,
    String? status,
    String? startDate,
    String? endDate,
  }) onApply;
  final VoidCallback onClear;

  const TransactionFilters({
    super.key,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<TransactionFilters> createState() => _TransactionFiltersState();
}

class _TransactionFiltersState extends State<TransactionFilters> {
  String? _type;
  String _startDate = '';
  String _endDate = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filters', style: AppTypography.titleMedium),
          SizedBox(height: AppSpacing.md),
          Text('Type', style: AppTypography.labelMedium),
          SizedBox(height: AppSpacing.xs),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('All')),
              ButtonSegment(value: 'expense', label: Text('Expense')),
              ButtonSegment(value: 'income', label: Text('Income')),
            ],
            selected: {_type ?? 'all'},
            onSelectionChanged: (v) => setState(() => _type = v.first == 'all' ? null : v.first),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: MoneyFormField(
                  label: 'Start date',
                  hintText: 'YYYY-MM-DD',
                  controller: TextEditingController(text: _startDate),
                  onChanged: (v) => _startDate = v,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: MoneyFormField(
                  label: 'End date',
                  hintText: 'YYYY-MM-DD',
                  controller: TextEditingController(text: _endDate),
                  onChanged: (v) => _endDate = v,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  child: Text('Clear'),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: MoneyButton(
                  label: 'Apply',
                  onPressed: () {
                    widget.onApply(
                      type: _type,
                      startDate: _startDate.isNotEmpty ? _startDate : null,
                      endDate: _endDate.isNotEmpty ? _endDate : null,
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SortBottomSheet extends StatelessWidget {
  final String sortBy;
  final String sortOrder;
  final void Function(String by, String order) onApply;

  const SortBottomSheet({
    super.key,
    required this.sortBy,
    required this.sortOrder,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    String selected = '${sortBy}_$sortOrder';
    final options = [
      ('date_desc', 'Newest first'),
      ('date_asc', 'Oldest first'),
      ('amount_desc', 'Highest amount'),
      ('amount_asc', 'Lowest amount'),
      ('description_asc', 'Description A-Z'),
      ('description_desc', 'Description Z-A'),
    ];

    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort by', style: AppTypography.titleMedium),
          SizedBox(height: AppSpacing.md),
          ...options.map(
            (o) => RadioListTile<String>(
              title: Text(o.$2),
              value: o.$1,
              groupValue: selected,
              onChanged: (v) {
                if (v != null) {
                  final parts = v.split('_');
                  onApply(parts[0], parts[1]);
                  Navigator.pop(context);
                }
              },
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
