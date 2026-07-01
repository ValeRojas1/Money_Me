import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';

class MoneyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final bool transparent;

  const MoneyAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBack = false,
    this.transparent = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppTypography.headlineSmall),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: showBack,
      backgroundColor: transparent ? Colors.transparent : Colors.white,
      elevation: transparent ? 0 : null,
      surfaceTintColor: transparent ? Colors.transparent : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
