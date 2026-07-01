import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF1B2A4A);
  static const accent = Color(0xFF4A7CF7);

  static const success = Color(0xFF2E7D6F);
  static const error = Color(0xFFC0392B);
  static const warning = Color(0xFFD4891D);
  static const info = Color(0xFF4A7CF7);

  static const background = Color(0xFFF4F5F7);
  static const surface = Colors.white;
  static const surfaceVariant = Color(0xFFF0F1F3);

  static const textPrimary = Color(0xFF1E2028);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textOnPrimary = Colors.white;
  static const textOnAccent = Colors.white;

  static const border = Color(0xFFE2E4E8);
  static const divider = Color(0xFFF0F1F3);

  static const income = Color(0xFF2E7D6F);
  static const expense = Color(0xFFC0392B);
  static const transfer = Color(0xFF4A7CF7);
}

class AppTypography {
  AppTypography._();

  static const _sans = 'Inter';
  static const _mono = 'JetBrains Mono';

  static const displayLarge = TextStyle(
    fontFamily: _sans,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const displayMedium = TextStyle(
    fontFamily: _sans,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const headlineLarge = TextStyle(
    fontFamily: _sans,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const headlineMedium = TextStyle(
    fontFamily: _sans,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const headlineSmall = TextStyle(
    fontFamily: _sans,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const titleLarge = TextStyle(
    fontFamily: _sans,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const titleSmall = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const titleMedium = TextStyle(
    fontFamily: _sans,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const labelLarge = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const labelMedium = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const labelSmall = TextStyle(
    fontFamily: _sans,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const caption = TextStyle(
    fontFamily: _sans,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  static const amountLarge = TextStyle(
    fontFamily: _mono,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const amountSmall = TextStyle(
    fontFamily: _mono,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const button = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.2,
    color: AppColors.textOnPrimary,
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double pageHorizontal = 16;
  static const double pageVertical = 24;
  static const double cardPadding = 16;
  static const double sectionGap = 24;
  static const double itemGap = 12;
  static const double inputGap = 16;
}

class AppRadius {
  AppRadius._();

  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
}

class AppShadows {
  AppShadows._();

  static const card = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const elevated = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
}

class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 480;
  static const double tablet = 768;
  static const double laptop = 1024;
  static const double desktop = 1280;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < laptop;
  static bool isLaptop(double width) => width >= laptop && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
}

final appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Inter',
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    secondary: AppColors.accent,
    onSecondary: AppColors.textOnAccent,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
  ),
  scaffoldBackgroundColor: AppColors.background,
  textTheme: const TextTheme(
    displayLarge: AppTypography.displayLarge,
    headlineMedium: AppTypography.headlineMedium,
    titleLarge: AppTypography.titleLarge,
    titleMedium: AppTypography.titleMedium,
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,
    labelLarge: AppTypography.labelLarge,
    labelSmall: AppTypography.labelSmall,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: BorderSide(color: AppColors.border, width: 0.5),
    ),
    color: AppColors.surface,
    margin: EdgeInsets.zero,
    surfaceTintColor: Colors.transparent,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: AppColors.accent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
    labelStyle: AppTypography.labelLarge,
    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
    floatingLabelStyle: AppTypography.labelLarge.copyWith(color: AppColors.accent),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 14,
      ),
      minimumSize: Size(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      textStyle: AppTypography.button,
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.accent,
      side: BorderSide(color: AppColors.accent, width: 1.5),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 14,
      ),
      minimumSize: Size(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      textStyle: AppTypography.button.copyWith(color: AppColors.accent),
      elevation: 0,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.accent,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      minimumSize: Size(0, 36),
      textStyle: AppTypography.labelLarge.copyWith(color: AppColors.accent),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
  ),
  appBarTheme: AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    titleTextStyle: AppTypography.titleLarge,
    shape: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textTertiary,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
    unselectedLabelStyle: AppTypography.labelSmall,
  ),
  chipTheme: ChipThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      side: BorderSide(color: AppColors.border),
    ),
    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    labelStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
    backgroundColor: AppColors.surfaceVariant,
  ),
  dialogTheme: DialogThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    titleTextStyle: AppTypography.titleMedium,
    contentTextStyle: AppTypography.bodyMedium,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
  ),
);
