enum UserStatus { active, inactive, suspended }

class User {
  final int id;
  final String email;
  final String name;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.status = UserStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });
}
