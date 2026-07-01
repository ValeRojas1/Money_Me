import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';

enum MoneyAlertType { success, warning, error, info }

class MoneyAlert extends StatelessWidget {
  final MoneyAlertType type;
  final String title;
  final String? message;
  final VoidCallback? onDismiss;

  const MoneyAlert({
    super.key,
    required this.type,
    required this.title,
    this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _bgColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: _bgColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _bgColor, size: 18),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (message != null) ...[
                  SizedBox(height: 2),
                  Text(message!, style: AppTypography.bodySmall),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 16, color: AppColors.textTertiary),
            ),
        ],
      ),
    );
  }

  Color get _bgColor => switch (type) {
    MoneyAlertType.success => AppColors.success,
    MoneyAlertType.warning => AppColors.warning,
    MoneyAlertType.error => AppColors.error,
    MoneyAlertType.info => AppColors.info,
  };

  IconData get _icon => switch (type) {
    MoneyAlertType.success => Icons.check_circle_outline,
    MoneyAlertType.warning => Icons.warning_amber_outlined,
    MoneyAlertType.error => Icons.error_outline,
    MoneyAlertType.info => Icons.info_outlined,
  };
}
