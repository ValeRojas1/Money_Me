class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String apiPrefix = '/api/v1';
  static const Duration timeout = Duration(seconds: 30);

  // Auth
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String refreshToken = '$apiPrefix/auth/refresh';
  static const String me = '$apiPrefix/auth/me';

  // Transactions
  static const String transactions = '$apiPrefix/transactions';

  // Analysis
  static const String analysisSpending = '$apiPrefix/analysis/spending';
  static const String analysisTrends = '$apiPrefix/analysis/trends';
  static const String analysisCategories = '$apiPrefix/analysis/categories';
  static const String analysisIncomeVsExpenses = '$apiPrefix/analysis/income-vs-expenses';

  // Predictions
  static const String predictionsMonthly = '$apiPrefix/predictions/monthly-spending';
  static const String predictionsBudget = '$apiPrefix/predictions/budget-recommendations';
  static const String predictionsSavings = '$apiPrefix/predictions/savings-goal';

  // Reports
  static const String reportsMonthly = '$apiPrefix/reports/monthly';
  static const String reportsAnnual = '$apiPrefix/reports/annual';
  static const String reportsExport = '$apiPrefix/reports/export';

  // OCR
  static const String ocrScanReceipt = '$apiPrefix/ocr/scan-receipt';
  static const String ocrScanInvoice = '$apiPrefix/ocr/scan-invoice';
  static const String ocrHistory = '$apiPrefix/ocr/history';
}
