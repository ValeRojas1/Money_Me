class Profile {
  final int id;
  final int userId;
  final String name;
  final String? avatarUrl;
  final String? phone;
  final DateTime? dateOfBirth;
  final String preferredCurrency;
  final String locale;
  final String timezone;
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.phone,
    this.dateOfBirth,
    this.preferredCurrency = 'USD',
    this.locale = 'en-US',
    this.timezone = 'UTC',
    required this.createdAt,
  });
}
