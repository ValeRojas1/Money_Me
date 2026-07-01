class CategoryEntity {
  final int id;
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final int? parentId;
  final bool isSystem;
  final int? sortOrder;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.parentId,
    this.isSystem = false,
    this.sortOrder,
  });

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'expense',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      parentId: json['parent_id'] as int?,
      isSystem: json['is_system'] as bool? ?? false,
      sortOrder: json['sort_order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'parent_id': parentId,
      'sort_order': sortOrder ?? 0,
    };
  }
}
