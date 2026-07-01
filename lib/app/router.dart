import 'package:flutter/material.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';
  static const String analysis = '/analysis';
  static const String predictions = '/predictions';
  static const String reports = '/reports';
  static const String ocr = '/ocr';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    return MaterialPageRoute(builder: (_) => const Placeholder());
  }
}
