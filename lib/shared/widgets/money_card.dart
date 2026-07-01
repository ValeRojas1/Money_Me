import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';

class MoneyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final Color? color;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const MoneyCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.color,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: height,
      margin: margin,
      padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: card,
        ),
      );
    }

    return card;
  }
}
