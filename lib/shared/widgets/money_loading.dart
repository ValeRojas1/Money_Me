import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';

class MoneyLoading extends StatelessWidget {
  final String? message;

  const MoneyLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accent),
            ),
            if (message != null) ...[
              SizedBox(height: AppSpacing.md),
              Text(message!, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}

class MoneySkeleton extends StatelessWidget {
  final double width;
  final double height;

  const MoneySkeleton({super.key, this.width = double.infinity, this.height = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}
