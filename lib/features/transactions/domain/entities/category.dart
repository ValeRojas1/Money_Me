enum CategoryType { income, expense, transfer, savings }

class Category {
  final int id;
  final String name;
  final CategoryType type;
  final String? icon;
  final String? color;
  final int? parentId;
  final bool isSystem;
  final bool isActive;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.parentId,
    this.isSystem = false,
    this.isActive = true,
    this.sortOrder = 0,
  });
}
