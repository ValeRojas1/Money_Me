import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';

enum MoneyButtonSize { small, medium }

class MoneyButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expanded;
  final MoneyButtonSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const MoneyButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.expanded = false,
    this.size = MoneyButtonSize.medium,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final h = size == MoneyButtonSize.small ? 36.0 : 44.0;
    final hPad = size == MoneyButtonSize.small ? 18.0 : 24.0;

    final btn = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: Size(0, h),
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 0),
      ),
      child: _buildChild(),
    );

    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), SizedBox(width: AppSpacing.sm), Text(label)],
      );
    }
    return Text(label);
  }
}
