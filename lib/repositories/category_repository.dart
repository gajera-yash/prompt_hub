import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/mock_categories.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
}

class HybridCategoryRepository implements CategoryRepository {
  late List<CategoryModel> _dummyCategories;

  HybridCategoryRepository() {
    _dummyCategories = [];
    int id = 1;
    AppCategories.categoryGroups.forEach((group, items) {
      final icon = AppCategories.getIconForGroup(group);
      for (var item in items) {
        int count = 0;
        if (item == 'Image Generation') {
          count = 129; // We loaded exactly 129 from JSON
        } else {
          count = 12 + (item.length * 3 % 73); 
        }

        _dummyCategories.add(CategoryModel(
          id: id.toString(),
          name: item,
          iconName: icon,
          promptCount: count,
        ));
        id++;
      }
    });
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    // 1. Local Mock Categories
    final localCats = _dummyCategories;
    
    // 2. Fetch Supabase Categories
    List<CategoryModel> remoteCats = [];
    try {
      final response = await Supabase.instance.client.from('categories').select();
      final data = response as List<dynamic>;
      remoteCats = data.map((item) {
        return CategoryModel(
          id: item['id'].toString(),
          name: item['title'].toString(),
          iconName: item['icon']?.toString() ?? 'folder',
          promptCount: 0, // Could fetch prompt count or leave 0
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching categories from Supabase: $e');
    }

    // Merge them: Remote first, then Local
    return [...remoteCats, ...localCats];
  }
}

