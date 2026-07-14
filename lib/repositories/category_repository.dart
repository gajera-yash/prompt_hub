import '../models/category_model.dart';
import 'dart:async';
import '../data/mock_categories.dart';

import 'prompt_repository.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
}

class MockCategoryRepository implements CategoryRepository {
  final PromptRepository _promptRepo;

  MockCategoryRepository({PromptRepository? promptRepo})
      : _promptRepo = promptRepo ?? MockPromptRepository();

  @override
  Future<List<CategoryModel>> getCategories() async {
    final List<CategoryModel> categories = [];
    int id = 1;

    for (var entry in AppCategories.categoryGroups.entries) {
      final group = entry.key;
      final items = entry.value;
      final icon = AppCategories.getIconForGroup(group);

      for (var item in items) {
        final prompts = await _promptRepo.getPromptsByCategory(item);
        final realCount = prompts.isNotEmpty ? prompts.length : 8 + (item.length * 2 % 15);

        categories.add(CategoryModel(
          id: id.toString(),
          name: item,
          iconName: icon,
          promptCount: realCount,
        ));
        id++;
      }
    }
    return categories;
  }
}

