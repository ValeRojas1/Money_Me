import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_me/app/theme.dart';
import 'package:money_me/features/analysis/presentation/pages/analysis_page.dart';
import 'package:money_me/features/auth/presentation/pages/profile_page.dart';
import 'package:money_me/features/auth/presentation/pages/settings_page.dart';
import 'package:money_me/features/auth/presentation/providers/auth_provider.dart';
import 'package:money_me/features/ocr/presentation/pages/ocr_page.dart';
import 'package:money_me/features/predictions/presentation/pages/predictions_page.dart';
import 'package:money_me/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:money_me/features/reports/presentation/pages/export_page.dart';
import 'package:money_me/features/transactions/presentation/pages/transactions_page.dart';
import 'package:money_me/shared/widgets/money_button.dart';
import 'package:money_me/shared/widgets/money_nav_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  NavItem _current = NavItem.dashboard;
  final List<NavItem> _navHistory = [NavItem.dashboard];

  void _onNavTap(NavItem item) {
    if (item != _current) {
      setState(() {
        _navHistory.add(item);
        if (_navHistory.length > 10) _navHistory.removeAt(0);
        _current = item;
      });
    }
  }

  bool _onPopPage() {
    if (_navHistory.length <= 1) return false;
    setState(() {
      _navHistory.removeLast();
      _current = _navHistory.last;
    });
    return true;
  }

  Widget _buildPage(NavItem item) {
    return switch (item) {
      NavItem.dashboard => const DashboardPage(),
      NavItem.transactions => const TransactionsPage(),
      NavItem.analysis => const AnalysisPage(),
      NavItem.predictions => const PredictionsPage(),
      NavItem.ocr => const OcrPage(),
      NavItem.reports => const ExportPage(),
      NavItem.settings => const SettingsPage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppBreakpoints.tablet;
        final isTablet = constraints.maxWidth >= AppBreakpoints.tablet &&
            constraints.maxWidth < AppBreakpoints.laptop;

        if (isMobile) return _buildMobileLayout();
        if (isTablet) return _buildTabletLayout();
        return _buildDesktopLayout();
      },
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => _onPopPage(),
        child: IndexedStack(
          index: NavItem.values.take(5).toList().indexOf(_current),
          children: NavItem.values.take(5).map(_buildPage).toList(),
        ),
      ),
      bottomNavigationBar: MoneyBottomNav(current: _current, onTap: _onNavTap),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: NavItem.values.indexOf(_current),
            onDestinationSelected: (i) => _onNavTap(NavItem.values[i]),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white,
            indicatorColor: AppColors.primary.withAlpha(25),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 28),
            ),
            destinations: NavItem.values.take(6).map((item) {
              final isSelected = item == _current;
              return NavigationRailDestination(
                icon: Icon(item.outlineIcon),
                selectedIcon: Icon(item.filledIcon),
                label: Text(item.label, style: AppTypography.labelMedium),
              );
            }).toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildPage(_current)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final auth = context.watch<AuthProvider>();
    final userName = auth.user?.name.isNotEmpty == true ? auth.user!.name : 'User';
    final userEmail = auth.user?.email.isNotEmpty == true ? auth.user!.email : '';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 240,
            child: MoneyNavDrawer(
              current: _current,
              onTap: _onNavTap,
              userName: userName,
              userEmail: userEmail,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(_current.label),
                actions: [
                  IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    offset: const Offset(0, 48),
                    onSelected: (v) {
                      if (v == 'profile') _onNavTap(NavItem.settings);
                      if (v == 'logout') context.read<AuthProvider>().logout();
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withAlpha(25),
                      child: Text(userInitial, style: TextStyle(color: AppColors.primary, fontSize: 14)),
                    ),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'profile', child: Text('Profile & Settings')),
                      const PopupMenuDivider(),
                      const PopupMenuItem(value: 'logout', child: Text('Sign Out')),
                    ],
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              body: _buildPage(_current),
            ),
          ),
        ],
      ),
    );
  }
}


