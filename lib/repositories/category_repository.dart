import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/mock_categories.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
  List<CategoryModel> getLocalCategories();
}

class HybridCategoryRepository implements CategoryRepository {
  late final List<CategoryModel> _localCategories;

  // ─── In-memory cache for remote merged result ───
  List<CategoryModel>? _cachedCategories;

  // Callback fired when remote data is ready (updates UI silently)
  void Function(List<CategoryModel>)? onRemoteUpdated;

  HybridCategoryRepository() {
    _localCategories = [];
    int id = 1;
    AppCategories.categoryGroups.forEach((group, items) {
      final icon = AppCategories.getIconForGroup(group);
      for (var item in items) {
        int count = 0;
        if (item == 'Image Generation') {
          count = 129;
        } else {
          count = 12 + (item.length * 3 % 73);
        }
        _localCategories.add(CategoryModel(
          id: id.toString(),
          name: item,
          iconName: icon,
          promptCount: count,
          groupName: group,
        ));
        id++;
      }
    });
  }

  /// Returns local static categories — INSTANT, no network
  @override
  List<CategoryModel> getLocalCategories() => List.unmodifiable(_localCategories);

  /// Returns cached result if available, otherwise fetches from Firestore.
  /// On first call: returns local immediately, fires Firestore in background.
  @override
  Future<List<CategoryModel>> getCategories() async {
    if (_cachedCategories != null) return _cachedCategories!;
    // First call: set cache to local immediately
    _cachedCategories = _mergeCategories([], _localCategories);
    // Fetch remote in background without blocking
    _fetchRemoteAndUpdate();
    return _cachedCategories!;
  }

  /// Background Firestore fetch — updates cache and notifies listeners
  Future<void> _fetchRemoteAndUpdate() async {
    List<CategoryModel> remoteCats = [];
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('createdAt', descending: true)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final groupName = data['name']?.toString() ?? 'Others';
        final iconName = data['iconName']?.toString() ?? 'folder';
        final subcategories = data['subcategories'] as List<dynamic>? ?? [];

        for (var sub in subcategories) {
          int count = 0;
          try {
            final countSnapshot = await FirebaseFirestore.instance
                .collection('prompts')
                .where('subcategory', isEqualTo: sub.toString())
                .count()
                .get();
            count = countSnapshot.count ?? 0;

            if (count == 0) {
              final fallback = await FirebaseFirestore.instance
                  .collection('prompts')
                  .where('category', isEqualTo: sub.toString())
                  .count()
                  .get();
              count = fallback.count ?? 0;
            }
          } catch (e) {
            debugPrint('Error fetching count for ${sub.toString()}: $e');
          }

          remoteCats.add(CategoryModel(
            id: '${doc.id}_${sub.toString()}',
            name: sub.toString(),
            iconName: iconName,
            promptCount: count,
            groupName: groupName,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error fetching remote categories: $e');
      return;
    }

    if (remoteCats.isNotEmpty) {
      _cachedCategories = _mergeCategories(remoteCats, _localCategories);
      onRemoteUpdated?.call(_cachedCategories!);
    }
  }

  List<CategoryModel> _mergeCategories(
      List<CategoryModel> remote, List<CategoryModel> local) {
    final Map<String, CategoryModel> unique = {};
    String norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    for (var cat in remote) {
      unique['${norm(cat.groupName)}_${norm(cat.name)}'] = cat;
    }
    for (var cat in local) {
      final key = '${norm(cat.groupName)}_${norm(cat.name)}';
      if (!unique.containsKey(key)) unique[key] = cat;
    }
    return unique.values.toList();
  }

  void clearCache() => _cachedCategories = null;
}
