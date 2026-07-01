import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/features/transactions/domain/entities/category_entity.dart';
import 'package:money_me/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:money_me/shared/widgets/money_button.dart';
import 'package:money_me/shared/widgets/money_card.dart';
import 'package:money_me/shared/widgets/money_form_field.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String _type = 'expense';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadCategories(type: _type);
    });
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final iconCtrl = TextEditingController(text: 'category');
    final colorCtrl = TextEditingController(text: '#4A90D9');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MoneyFormField(
              label: 'Name',
              controller: nameCtrl,
            ),
            SizedBox(height: AppSpacing.sm),
            MoneyFormField(
              label: 'Icon name (Material)',
              controller: iconCtrl,
            ),
            SizedBox(height: AppSpacing.sm),
            MoneyFormField(
              label: 'Color (hex)',
              controller: colorCtrl,
              hintText: '#RRGGBB',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          MoneyButton(
            label: 'Create',
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await (context.read<TransactionProvider>() as dynamic)
                    .repository
                    .dataSource
                    .createCategory({
                  'name': nameCtrl.text,
                  'type': _type,
                  'icon': iconCtrl.text,
                  'color': colorCtrl.text,
                  'sort_order': 0,
                });
                Navigator.pop(ctx);
                context.read<TransactionProvider>().loadCategories(type: _type);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(int id, bool isSystem) async {
    if (isSystem) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete system categories')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category?'),
        content: const Text('Transactions using this category will be uncategorized.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await (context.read<TransactionProvider>() as dynamic)
            .repository
            .dataSource
            .deleteCategory(id);
        context.read<TransactionProvider>().loadCategories(type: _type);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense')),
                ButtonSegment(value: 'income', label: Text('Income')),
              ],
              selected: {_type},
              onSelectionChanged: (v) {
                setState(() => _type = v.first);
                context.read<TransactionProvider>().loadCategories(type: _type);
              },
            ),
          ),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, _) {
                final cats = provider.categories
                    .where((c) => c.type == _type)
                    .toList();
                if (cats.isEmpty) {
                  return Center(
                    child: Text('No categories yet',
                        style: AppTypography.bodyMedium),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: cats.length,
                  itemBuilder: (_, i) {
                    final c = cats[i];
                    final color = c.color != null
                        ? Color(int.parse(c.color!.replaceFirst('#', '0xFF')))
                        : AppColors.primary;
                    return MoneyCard(
                      margin: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.category,
                            color: color,
                            size: 20,
                          ),
                        ),
                        title: Text(c.name),
                        subtitle: c.isSystem
                            ? Text('System', style: AppTypography.caption)
                            : null,
                        trailing: c.isSystem
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.error),
                                onPressed: () =>
                                    _deleteCategory(c.id, c.isSystem),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
