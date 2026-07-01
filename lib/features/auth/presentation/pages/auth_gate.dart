import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_me/app/theme.dart';
import 'package:money_me/features/auth/presentation/pages/login_page.dart';
import 'package:money_me/features/auth/presentation/providers/auth_provider.dart';
import 'package:money_me/shared/widgets/app_shell.dart';
import 'package:money_me/shared/widgets/money_loading.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return switch (auth.status) {
          AuthStatus.initial => const MoneyLoading(message: 'Loading...'),
          AuthStatus.loading => const MoneyLoading(message: 'Signing in...'),
          AuthStatus.authenticated => const AppShell(),
          AuthStatus.unauthenticated => const LoginPage(),
          AuthStatus.error => _buildError(context, auth),
        };
      },
    );
  }

  Widget _buildError(BuildContext context, AuthProvider auth) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(auth.errorMessage ?? 'Authentication error', style: AppTypography.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => auth.logout(), child: const Text('Try Again')),
            ],
          ),
        ),
      ),
    );
  }
}
