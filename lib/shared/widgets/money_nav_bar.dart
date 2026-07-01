import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';

enum NavItem {
  dashboard(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
  transactions(Icons.swap_horiz_outlined, Icons.swap_horiz, 'Transactions'),
  analysis(Icons.analytics_outlined, Icons.analytics, 'Analysis'),
  predictions(Icons.trending_up_outlined, Icons.trending_up, 'Predictions'),
  ocr(Icons.document_scanner_outlined, Icons.document_scanner, 'Scan'),
  reports(Icons.description_outlined, Icons.description, 'Reports'),
  settings(Icons.settings_outlined, Icons.settings, 'Settings');

  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;

  const NavItem(this.outlineIcon, this.filledIcon, this.label);
}

class MoneyBottomNav extends StatelessWidget {
  final NavItem current;
  final void Function(NavItem) onTap;

  const MoneyBottomNav({super.key, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: NavItem.values.indexOf(current),
      onTap: (index) => onTap(NavItem.values[index]),
      items: NavItem.values.take(5).map((item) {
        final isSelected = item == current;
        return BottomNavigationBarItem(
          icon: Icon(item.outlineIcon),
          activeIcon: Icon(item.filledIcon),
          label: item.label,
        );
      }).toList(),
    );
  }
}

class MoneyNavDrawer extends StatelessWidget {
  final NavItem current;
  final void Function(NavItem) onTap;
  final String userName;
  final String userEmail;

  const MoneyNavDrawer({
    super.key,
    required this.current,
    required this.onTap,
    this.userName = 'User',
    this.userEmail = 'user@email.com',
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(AppSpacing.md, 48, AppSpacing.md, AppSpacing.md),
            color: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: Text(
                    userName[0].toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(userName, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text(userEmail, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              children: NavItem.values.map((item) {
                final isSelected = item == current;
                return Container(
                  height: 44,
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: isSelected
                        ? Border(left: BorderSide(color: AppColors.primary, width: 3))
                        : null,
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : null,
                    borderRadius: isSelected ? BorderRadius.only(
                      topRight: Radius.circular(AppRadius.sm),
                      bottomRight: Radius.circular(AppRadius.sm),
                    ) : null,
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      isSelected ? item.filledIcon : item.outlineIcon,
                      size: 20,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    title: Text(item.label, style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    )),
                    onTap: () => onTap(item),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
