class Validators {
  Validators._();

  static const int amountMinCents = 1;
  static const int amountMaxCents = 9999999999;
  static const Set<String> supportedCurrencies = {
    'USD', 'EUR', 'GBP', 'MXN', 'COP', 'ARS', 'CLP', 'JPY', 'KRW',
  };

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (value.length > 255) return 'Email too long';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value)) return 'Invalid email format';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (value.length > 128) return 'Password too long';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Must contain an uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Must contain a lowercase letter';
    if (!RegExp(r'\d').hasMatch(value)) return 'Must contain a number';
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? amountCents(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final parsed = int.tryParse(value);
    if (parsed == null) return 'Amount must be a whole number (cents)';
    if (parsed < amountMinCents) return 'Minimum amount is \$${(amountMinCents / 100).toStringAsFixed(2)}';
    if (parsed > amountMaxCents) return 'Amount exceeds maximum allowed';
    return null;
  }

  static String? amountDecimal(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Invalid amount';
    if (parsed <= 0) return 'Amount must be positive';
    if (parsed > 99999999.99) return 'Amount exceeds maximum allowed';
    return null;
  }

  static String? currencyCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Currency is required';
    final code = value.trim().toUpperCase();
    if (code.length != 3) return 'Currency must be 3-letter ISO 4217 code';
    if (!supportedCurrencies.contains(code)) return 'Unsupported currency: $code';
    return null;
  }

  static String? transactionDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Date is required';
    final date = DateTime.tryParse(value);
    if (date == null) return 'Invalid date format';
    if (date.isAfter(DateTime.now())) return 'Transaction date cannot be in the future';
    return null;
  }

  static String? description(String? value) {
    if (value == null || value.trim().isEmpty) return 'Description is required';
    if (value.length > 500) return 'Description too long (max 500 characters)';
    return null;
  }

  static String? notifyPercentage(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value);
    if (parsed == null) return 'Must be a number';
    if (parsed < 0 || parsed > 100) return 'Must be between 0 and 100';
    return null;
  }

  static String? walletName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wallet name is required';
    if (value.length > 255) return 'Name too long';
    return null;
  }

  static String? hexColor(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value)) return 'Must be hex color (#RRGGBB)';
    return null;
  }

  static String? positiveInt(String? value, [String field = 'Value']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    final parsed = int.tryParse(value);
    if (parsed == null) return '$field must be a whole number';
    if (parsed <= 0) return '$field must be positive';
    return null;
  }

  static String? positiveDouble(String? value, [String field = 'Value']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    final parsed = double.tryParse(value);
    if (parsed == null) return '$field must be a number';
    if (parsed <= 0) return '$field must be positive';
    return null;
  }
}
