import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';

class MoneyEmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  const MoneyEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textTertiary),
            SizedBox(height: AppSpacing.md),
            Text(title, style: AppTypography.titleMedium),
            if (message != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(message!, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
