import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';
import 'package:money_me/features/transactions/domain/entities/wallet.dart';
import 'package:money_me/shared/widgets/money_button.dart';
import 'package:money_me/shared/widgets/money_card.dart';
import 'package:money_me/shared/widgets/money_empty_state.dart';
import 'package:money_me/shared/widgets/money_form_field.dart';

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  final _wallets = [
    _WalletData('Main Checking', 'checking', 452080, '\$4,520.80', Colors.blue, true),
    _WalletData('Savings', 'savings', 785000, '\$7,850.00', Colors.green, false),
    _WalletData('Credit Card', 'credit_card', -120000, '-\$1,200.00', Colors.red, false),
    _WalletData('Cash', 'cash', 32000, '\$320.00', Colors.orange, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWalletDialog(context),
          ),
        ],
      ),
      body: _wallets.isEmpty
          ? MoneyEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No wallets yet',
              message: 'Add your first wallet to start tracking',
              action: TextButton(
                onPressed: () => _showAddWalletDialog(context),
                child: const Text('Add Wallet'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _wallets.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: MoneyCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Balance', style: AppTypography.titleSmall),
                          const SizedBox(height: 8),
                          Text('\$11,490.80', style: AppTypography.amountLarge),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text('Income: \$5,200.00', style: AppTypography.bodySmall.copyWith(color: AppColors.income)),
                              ),
                              Expanded(
                                child: Text('Expense: \$3,840.00', style: AppTypography.bodySmall.copyWith(color: AppColors.expense)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final w = _wallets[index - 1];
                return _buildWalletCard(w);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWalletDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildWalletCard(_WalletData w) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => _showWalletOptions(w),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: w.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_typeIcon(w.type), color: w.color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(w.name, style: AppTypography.titleMedium),
                        if (w.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(4)),
                            child: Text('Default', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(w.type.replaceAll('_', ' ').toUpperCase(), style: AppTypography.caption),
                  ],
                ),
              ),
              Text(w.balance, style: AppTypography.amountSmall.copyWith(color: w.balanceCents >= 0 ? AppColors.textPrimary : AppColors.error)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'checking': return Icons.account_balance;
      case 'savings': return Icons.savings;
      case 'credit_card': return Icons.credit_card;
      case 'cash': return Icons.money;
      case 'investment': return Icons.trending_up;
      case 'digital': return Icons.account_balance_wallet;
      default: return Icons.wallet;
    }
  }

  void _showAddWalletDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MoneyFormField(label: 'Wallet Name', controller: nameCtrl),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: 'checking',
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'checking', child: Text('CHECKING')),
                DropdownMenuItem(value: 'savings', child: Text('SAVINGS')),
                DropdownMenuItem(value: 'credit_card', child: Text('CREDIT CARD')),
                DropdownMenuItem(value: 'cash', child: Text('CASH')),
                DropdownMenuItem(value: 'investment', child: Text('INVESTMENT')),
                DropdownMenuItem(value: 'digital', child: Text('DIGITAL')),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            MoneyFormField(label: 'Initial Balance'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          MoneyButton(label: 'Add', onPressed: () => Navigator.pop(ctx)),
        ],
      ),
    );
  }

  void _showWalletOptions(_WalletData w) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(w.name, style: AppTypography.titleLarge),
            const SizedBox(height: 8),
            Text(w.balance, style: AppTypography.displayMedium),
            const SizedBox(height: 24),
            ListTile(leading: const Icon(Icons.edit), title: const Text('Edit Wallet'), onTap: () { Navigator.pop(ctx); }),
            ListTile(leading: const Icon(Icons.star_border), title: const Text('Set as Default'), onTap: () { Navigator.pop(ctx); }),
            ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.error), title: const Text('Delete', style: TextStyle(color: AppColors.error)), onTap: () { Navigator.pop(ctx); }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _WalletData {
  final String name;
  final String type;
  final int balanceCents;
  final String balance;
  final Color color;
  final bool isDefault;
  const _WalletData(this.name, this.type, this.balanceCents, this.balance, this.color, this.isDefault);
}
