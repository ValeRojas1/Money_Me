import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_me/app/theme.dart';
import 'package:money_me/features/auth/presentation/providers/auth_provider.dart';
import 'package:money_me/shared/widgets/money_button.dart';
import 'package:money_me/shared/widgets/money_form_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _showRegister = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().login(_emailCtrl.text.trim(), _passCtrl.text);
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().register(_emailCtrl.text.trim(), _passCtrl.text, _nameCtrl?.text.trim() ?? '');
  }

  TextEditingController? _nameCtrl;

  @override
  Widget build(BuildContext context) {
    if (_showRegister) return _buildRegisterForm();
    return _buildLoginForm();
  }

  Widget _buildLoginForm() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.account_balance_wallet, size: 56, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text('Money Me', style: AppTypography.displayMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('Your personal finance manager', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                    const SizedBox(height: 40),
                    MoneyFormField(label: 'Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress, validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) return 'Invalid email';
                      return null;
                    }),
                    const SizedBox(height: 20),
                    MoneyFormField(label: 'Password', controller: _passCtrl, obscureText: _obscurePass, validator: (v) => v == null || v.isEmpty ? 'Password is required' : null, suffix: IconButton(icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _obscurePass = !_obscurePass))),
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => _showForgotPassword(context), child: const Text('Forgot password?'))),
                    const SizedBox(height: 16),
                    Consumer<AuthProvider>(builder: (context, auth, _) => MoneyButton(label: 'Sign In', onPressed: auth.status == AuthStatus.loading ? null : _onLogin)),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Don't have an account?", style: AppTypography.bodyMedium),
                      TextButton(onPressed: () => setState(() { _showRegister = true; _nameCtrl = TextEditingController(); }), child: const Text('Sign Up')),
                    ]),
                    if (context.watch<AuthProvider>().errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(context.watch<AuthProvider>().errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13), textAlign: TextAlign.center),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.account_balance_wallet, size: 48, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text('Create Account', style: AppTypography.headlineLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    MoneyFormField(label: 'Full Name', controller: _nameCtrl!, validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
                    const SizedBox(height: 16),
                    MoneyFormField(label: 'Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress, validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) return 'Invalid email';
                      return null;
                    }),
                    const SizedBox(height: 16),
                    MoneyFormField(label: 'Password', controller: _passCtrl, obscureText: true, validator: (v) {
                      if (v == null || v.length < 8) return 'Min 8 characters';
                      if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Need uppercase letter';
                      if (!RegExp(r'[a-z]').hasMatch(v)) return 'Need lowercase letter';
                      if (!RegExp(r'\d').hasMatch(v)) return 'Need a number';
                      return null;
                    }),
                    const SizedBox(height: 24),
                    Consumer<AuthProvider>(builder: (context, auth, _) => MoneyButton(label: 'Create Account', onPressed: auth.status == AuthStatus.loading ? null : _onRegister)),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Already have an account?', style: AppTypography.bodyMedium),
                      TextButton(onPressed: () => setState(() => _showRegister = false), child: const Text('Sign In')),
                    ]),
                    if (context.watch<AuthProvider>().errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(context.watch<AuthProvider>().errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13), textAlign: TextAlign.center),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text('Enter your email to receive reset instructions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          MoneyButton(label: 'Send', onPressed: () => Navigator.pop(ctx)),
        ],
      ),
    );
  }
}
