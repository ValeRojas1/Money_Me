import 'package:flutter/material.dart';

class UserFriendlyError {
  final String title;
  final String message;
  final IconData icon;

  const UserFriendlyError({
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
  });

  static UserFriendlyError fromStatusCode(int statusCode, String? detail) {
    switch (statusCode) {
      case 400:
        return UserFriendlyError(
          title: 'Invalid request',
          message: detail ?? 'Please check the information provided and try again.',
          icon: Icons.info_outline,
        );
      case 401:
        return UserFriendlyError(
          title: 'Session expired',
          message: 'Your session has expired. Please sign in again to continue.',
          icon: Icons.lock_outline,
        );
      case 403:
        return UserFriendlyError(
          title: 'Access denied',
          message: "You don't have permission to perform this action.",
          icon: Icons.block,
        );
      case 404:
        return UserFriendlyError(
          title: 'Not found',
          message: 'The requested information could not be found. It may have been deleted.',
          icon: Icons.search_off,
        );
      case 409:
        return UserFriendlyError(
          title: 'Already exists',
          message: detail ?? 'This information already exists in the system.',
          icon: Icons.info_outline,
        );
      case 422:
        return UserFriendlyError(
          title: 'Invalid data',
          message: detail ?? 'Some fields have invalid values. Please review and correct them.',
          icon: Icons.edit_note,
        );
      case 429:
        return UserFriendlyError(
          title: 'Too many requests',
          message: 'Please wait a moment before trying again.',
          icon: Icons.timer_outlined,
        );
      case 500:
        return UserFriendlyError(
          title: 'Server error',
          message: 'Something went wrong on our end. Please try again later.',
          icon: Icons.cloud_off,
        );
      default:
        return UserFriendlyError(
          title: 'Something went wrong',
          message: detail ?? 'An unexpected error occurred. Please try again.',
          icon: Icons.error_outline,
        );
    }
  }

  static UserFriendlyError fromException(dynamic e) {
    final str = e.toString().toLowerCase();
    if (str.contains('timeout') || str.contains('timed out')) {
      return UserFriendlyError(
        title: 'Connection timeout',
        message: 'The request took too long. Please check your internet connection and try again.',
        icon: Icons.wifi_off,
      );
    }
    if (str.contains('socket') || str.contains('connection') || str.contains('network')) {
      return UserFriendlyError(
        title: 'No connection',
        message: 'Unable to connect to the server. Please check your internet connection.',
        icon: Icons.wifi_off,
      );
    }
    if (str.contains('ocr') || str.contains('scan')) {
      return UserFriendlyError(
        title: 'Scan failed',
        message: 'We could not read this receipt. Try a clearer photo or enter the data manually.',
        icon: Icons.document_scanner_outlined,
      );
    }
    if (str.contains('predict') || str.contains('forecast')) {
      return UserFriendlyError(
        title: 'Prediction unavailable',
        message: 'Not enough data for predictions yet. Keep tracking your transactions.',
        icon: Icons.trending_up,
      );
    }
    return UserFriendlyError(
      title: 'Error',
      message: str,
      icon: Icons.error_outline,
    );
  }
}
