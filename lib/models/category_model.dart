class CategoryModel {
  final String id;
  final String name;
  final String iconName;
  final int promptCount;
  final String groupName;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    this.promptCount = 0,
    required this.groupName,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconName,
    int? promptCount,
    String? groupName,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      promptCount: promptCount ?? this.promptCount,
      groupName: groupName ?? this.groupName,
    );
  }
}
