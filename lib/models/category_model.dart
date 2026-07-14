class CategoryModel {
  final String id;
  final String name;
  final String iconName;
  final int promptCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    this.promptCount = 0,
  });
}
