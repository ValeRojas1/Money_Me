import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_me/app/theme.dart';
import 'package:money_me/features/auth/presentation/providers/auth_provider.dart';
import 'package:money_me/shared/widgets/money_button.dart';
import 'package:money_me/shared/widgets/money_card.dart';
import 'package:money_me/shared/widgets/money_form_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isEditing = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _syncFromUser(AuthProvider auth) {
    final user = auth.user;
    if (user == null || _initialized) return;
    _nameCtrl.text = user.name;
    _emailCtrl.text = user.email;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _syncFromUser(auth);
    final userName = auth.user?.name ?? 'User';
    final userEmail = auth.user?.email ?? '';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(_isEditing ? 'Done' : 'Edit'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withAlpha(25),
                  child: Text(
                    userInitial,
                    style: TextStyle(fontSize: 36, color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                if (!_isEditing) Text(userName, style: AppTypography.headlineSmall),
                if (!_isEditing) Text(userEmail, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (_isEditing) ...[
            MoneyFormField(label: 'Full Name', controller: _nameCtrl),
            const SizedBox(height: 16),
            MoneyFormField(label: 'Phone', controller: _phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            MoneyFormField(label: 'Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
          ] else ...[
            _buildInfoTile(Icons.person_outline, 'Name', userName),
            _buildInfoTile(Icons.email_outlined, 'Email', userEmail),
            if (_phoneCtrl.text.isNotEmpty)
              _buildInfoTile(Icons.phone_outlined, 'Phone', _phoneCtrl.text),
          ],
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
            onTap: () => context.read<AuthProvider>().logout(),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: AppTypography.labelSmall),
      subtitle: Text(value, style: AppTypography.bodyMedium),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            MoneyFormField(label: 'Current Password', obscureText: true),
            SizedBox(height: 12),
            MoneyFormField(label: 'New Password', obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          MoneyButton(label: 'Update', onPressed: () => Navigator.pop(ctx)),
        ],
      ),
    );
  }
}
