import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/features/auth/presentation/providers/auth_provider.dart';
import 'package:money_me/features/reports/presentation/pages/export_page.dart';
import 'package:money_me/shared/widgets/money_alert.dart';
import 'package:money_me/shared/widgets/money_button.dart';
import 'package:money_me/shared/widgets/money_card.dart';
import 'package:money_me/shared/widgets/money_form_field.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedCurrency = 'USD';
  String _selectedTheme = 'System';
  String _selectedLocale = 'English';
  bool _notificationsEnabled = true;
  bool _budgetAlertsEnabled = true;

  final _currencies = ['USD - US Dollar', 'EUR - Euro', 'GBP - British Pound', 'MXN - Mexican Peso', 'COP - Colombian Peso'];
  final _themes = ['Light', 'Dark', 'System'];
  final _locales = ['English', 'Spanish', 'Portuguese'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Preferences', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          MoneyAlert(type: MoneyAlertType.info, title: 'Customize your experience', message: 'Changes are saved automatically'),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.monetization_on_outlined),
                  title: const Text('Preferred Currency'),
                  subtitle: Text(_selectedCurrency),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPicker('Currency', _currencies, _selectedCurrency, (v) => setState(() => _selectedCurrency = v)),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme'),
                  subtitle: Text(_selectedTheme),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPicker('Theme', _themes, _selectedTheme, (v) => setState(() => _selectedTheme = v)),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Language'),
                  subtitle: Text(_selectedLocale),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPicker('Language', _locales, _selectedLocale, (v) => setState(() => _selectedLocale = v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Notifications', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Push Notifications'),
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  secondary: const Icon(Icons.warning_amber_outlined),
                  title: const Text('Budget Alerts'),
                  subtitle: const Text('Get notified when nearing budget limits'),
                  value: _budgetAlertsEnabled,
                  onChanged: (v) => setState(() => _budgetAlertsEnabled = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Data', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Export transactions'),
                  subtitle: const Text('CSV or PDF'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportPage())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Account', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text('Delete account', style: TextStyle(color: AppColors.error)),
                  subtitle: const Text('Permanently remove all your data'),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete account?'),
                        content: const Text('This will permanently delete all your transactions, budgets, wallets, and personal data. This action cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          MoneyButton(
                            label: 'Delete permanently',
                            onPressed: () => Navigator.pop(ctx, true),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      try {
                        await context.read<AuthProvider>().deleteAccount();
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Account deleted')))),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error deleting account: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text('Money Me v0.1.0', style: AppTypography.caption),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showPicker(String title, List<String> items, String current, void Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.titleLarge),
            const SizedBox(height: 16),
            ...items.map((item) => ListTile(
              title: Text(item),
              trailing: item == current ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                onSelect(item);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }
}
