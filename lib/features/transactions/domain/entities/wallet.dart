enum WalletType { checking, savings, cash, creditCard, investment, digital }
enum WalletStatus { active, inactive }

class Wallet {
  final int id;
  final int userId;
  final String name;
  final WalletType type;
  final String currency;
  final int balanceCents;
  final int? creditLimitCents;
  final WalletStatus status;
  final bool isDefault;
  final String? color;
  final String? icon;
  final String? institution;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.currency = 'USD',
    this.balanceCents = 0,
    this.creditLimitCents,
    this.status = WalletStatus.active,
    this.isDefault = false,
    this.color,
    this.icon,
    this.institution,
    this.lastSyncedAt,
    required this.createdAt,
  });

  double get balance => balanceCents / 100;
}
