import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/core/utils/error_messages.dart';

void main() {
  group('AppTypography', () {
    test('has all required text styles', () {
      expect(AppTypography.displayLarge, isNotNull);
      expect(AppTypography.displayMedium, isNotNull);
      expect(AppTypography.headlineLarge, isNotNull);
      expect(AppTypography.headlineMedium, isNotNull);
      expect(AppTypography.headlineSmall, isNotNull);
      expect(AppTypography.titleLarge, isNotNull);
      expect(AppTypography.titleMedium, isNotNull);
      expect(AppTypography.titleSmall, isNotNull);
      expect(AppTypography.bodyLarge, isNotNull);
      expect(AppTypography.bodyMedium, isNotNull);
      expect(AppTypography.bodySmall, isNotNull);
      expect(AppTypography.labelLarge, isNotNull);
      expect(AppTypography.labelMedium, isNotNull);
      expect(AppTypography.labelSmall, isNotNull);
    });

    test('caption style is defined', () {
      expect(AppTypography.caption, isNotNull);
    });
  });

  group('AppColors', () {
    test('has all required colors', () {
      expect(AppColors.primary, isNotNull);
      expect(AppColors.error, isNotNull);
      expect(AppColors.success, isNotNull);
      expect(AppColors.warning, isNotNull);
      expect(AppColors.info, isNotNull);
      expect(AppColors.background, isNotNull);
      expect(AppColors.surface, isNotNull);
      expect(AppColors.surfaceVariant, isNotNull);
      expect(AppColors.textPrimary, isNotNull);
      expect(AppColors.textSecondary, isNotNull);
    });

    test('primary color is set', () {
      expect(AppColors.primary, isNot(equals(Colors.transparent)));
    });
  });

  group('AppSpacing', () {
    test('has consistent spacing values', () {
      expect(AppSpacing.xs, lessThan(AppSpacing.sm));
      expect(AppSpacing.sm, lessThan(AppSpacing.md));
      expect(AppSpacing.md, lessThan(AppSpacing.lg));
      expect(AppSpacing.lg, lessThan(AppSpacing.xl));
      expect(AppSpacing.xl, lessThan(AppSpacing.xxl));
    });
  });

  group('AppRadius', () {
    test('has consistent radius values', () {
      expect(AppRadius.sm, lessThan(AppRadius.md));
      expect(AppRadius.md, lessThan(AppRadius.lg));
    });
    test('no full radius', () {
      expect(AppRadius.lg, lessThan(999));
    });
  });

  group('UserFriendlyError', () {
    test('returns appropriate message for 401', () {
      final error = UserFriendlyError.fromStatusCode(401, null);
      expect(error.title, 'Session expired');
      expect(error.message, contains('sign in again'));
    });

    test('returns appropriate message for 500', () {
      final error = UserFriendlyError.fromStatusCode(500, null);
      expect(error.title, 'Server error');
      expect(error.message, contains('try again later'));
    });

    test('returns appropriate message for 404', () {
      final error = UserFriendlyError.fromStatusCode(404, null);
      expect(error.title, 'Not found');
    });

    test('includes detail when provided', () {
      final error = UserFriendlyError.fromStatusCode(409, 'Email already in use');
      expect(error.message, contains('Email already in use'));
    });

    test('OCR error returns scan-friendly message', () {
      final error = UserFriendlyError.fromException(Exception('OCR failed'));
      expect(error.title, 'Scan failed');
      expect(error.message, contains('Try a clearer photo'));
    });

    test('prediction error returns friendly message', () {
      final error = UserFriendlyError.fromException(Exception('prediction error'));
      expect(error.title, 'Prediction unavailable');
      expect(error.message, contains('Not enough data'));
    });

    test('timeout error returns connection message', () {
      final error = UserFriendlyError.fromException(Exception('Request timed out'));
      expect(error.title, 'Connection timeout');
    });
  });
}
