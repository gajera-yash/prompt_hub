import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prompt_model.dart';
import '../models/category_model.dart';
import '../repositories/prompt_repository.dart';
import '../repositories/category_repository.dart';
import '../services/local_storage_service.dart';
import '../models/user_preferences_model.dart';

final promptRepositoryProvider = Provider<PromptRepository>((ref) {
  return HybridPromptRepository();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return HybridCategoryRepository();
});

// ─── Global App State ───
final bottomNavIndexProvider = NotifierProvider<BottomNavIndexNotifier, int>(
  BottomNavIndexNotifier.new,
);

class BottomNavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final featuredPromptsProvider = FutureProvider<List<PromptModel>>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  return repo.getFeaturedPrompts();
});

final trendingPromptsProvider = FutureProvider<List<PromptModel>>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  return repo.getTrendingPrompts();
});

final trendingPhotosProvider = FutureProvider<List<PromptModel>>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  return repo.getTrendingPhotos();
});

final recentPromptsProvider = FutureProvider<List<PromptModel>>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  return repo.getRecentPrompts();
});

final dailyPromptProvider = FutureProvider<PromptModel>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  return repo.getDailyPrompt();
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories();
});

final searchPromptsProvider = FutureProvider.family<List<PromptModel>, String>((ref, query) async {
  final repo = ref.watch(promptRepositoryProvider);
  return repo.searchPrompts(query);
});

final categoryPromptsProvider = FutureProvider.family<List<PromptModel>, String>((ref, category) async {
  final repo = ref.watch(promptRepositoryProvider);
  return repo.getPromptsByCategory(category);
});

final promptByIdProvider = FutureProvider.family<PromptModel?, String>((ref, id) async {
  final repo = ref.watch(promptRepositoryProvider);
  return repo.getPromptById(id);
});

// ─── User Preferences & Personalization ───
final userPreferencesProvider = NotifierProvider<UserPreferencesNotifier, UserPreferencesModel?>(
  UserPreferencesNotifier.new,
);

class UserPreferencesNotifier extends Notifier<UserPreferencesModel?> {
  @override
  UserPreferencesModel? build() {
    final storage = ref.watch(localStorageProvider);
    return storage?.getUserPreferences();
  }

  Future<void> savePreferences(UserPreferencesModel prefs) async {
    final storage = ref.read(localStorageProvider);
    await storage?.saveUserPreferences(prefs);
    state = prefs;
  }
}

final personalizedPromptsProvider = FutureProvider<List<PromptModel>>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  final allPrompts = await repo.getRecentPrompts();
  final prefs = ref.watch(userPreferencesProvider);

  if (prefs == null) return [];

  // Map user preferences to category keywords for matching
  final Map<String, List<String>> goalCategoryMap = {
    'Content Creation': ['Content', 'Copywriting', 'Writing', 'Blog'],
    'Coding & Tech': ['Coding', 'React', 'Flutter', 'Tech', 'Development'],
    'Marketing & Sales': ['Marketing', 'SEO', 'Sales', 'Social Media', 'Email'],
    'Image Art': ['Image', 'Midjourney', 'Art', 'DALL'],
    'Productivity': ['Productivity', 'Workflow', 'Planning'],
    'Business': ['Business', 'Strategy', 'Startup', 'Plan'],
  };

  final Map<String, List<String>> toolCategoryMap = {
    'ChatGPT': ['ChatGPT', 'Content', 'Copywriting', 'SEO', 'Marketing'],
    'Gemini': ['Gemini', 'Content', 'Writing'],
    'Midjourney': ['Midjourney', 'Image', 'Art'],
    'Claude': ['Claude', 'Content', 'Writing', 'Coding'],
    'DeepSeek': ['DeepSeek', 'Coding', 'Tech'],
  };

  // Build a scoring system for prompts
  List<MapEntry<PromptModel, int>> scored = [];

  for (final prompt in allPrompts) {
    int score = 0;
    final promptCategory = prompt.category.toLowerCase();
    final promptTitle = prompt.title.toLowerCase();
    final promptContent = prompt.content.toLowerCase();

    // Score based on selected categories (highest weight)
    for (final cat in prefs.selectedCategories) {
      if (promptCategory.contains(cat.toLowerCase()) ||
          promptTitle.contains(cat.toLowerCase()) ||
          promptContent.contains(cat.toLowerCase())) {
        score += 3;
      }
    }

    // Score based on selected goal
    if (prefs.selectedGoal != null) {
      final goalKeywords = goalCategoryMap[prefs.selectedGoal] ?? [];
      for (final keyword in goalKeywords) {
        if (promptCategory.contains(keyword.toLowerCase()) ||
            promptTitle.contains(keyword.toLowerCase()) ||
            promptContent.contains(keyword.toLowerCase())) {
          score += 2;
          break;
        }
      }
    }

    // Score based on selected AI tool
    if (prefs.selectedTool != null) {
      final toolKeywords = toolCategoryMap[prefs.selectedTool] ?? [];
      for (final keyword in toolKeywords) {
        if (promptCategory.contains(keyword.toLowerCase()) ||
            promptTitle.contains(keyword.toLowerCase()) ||
            promptContent.contains(keyword.toLowerCase())) {
          score += 2;
          break;
        }
      }
    }

    // Score based on output preference
    if (prefs.outputPreference != null) {
      final output = prefs.outputPreference!.toLowerCase();
      if (output.contains('short') && prompt.content.length < 300) {
        score += 1;
      } else if (output.contains('pro') && prompt.content.length > 500) {
        score += 1;
      } else if (output.contains('template') && prompt.content.contains('[')) {
        score += 1;
      }
    }

    if (score > 0) {
      scored.add(MapEntry(prompt, score));
    }
  }

  // Sort by score (highest first)
  scored.sort((a, b) => b.value.compareTo(a.value));

  // If no matches, return top trending prompts
  if (scored.isEmpty) {
    return allPrompts.take(10).toList();
  }

  // Return top 10 personalized prompts
  return scored.take(10).map((e) => e.key).toList();
});

// ─── Local Storage ───
final localStorageProvider = Provider<LocalStorageService?>((ref) => null);

// ─── Saved Prompts (backed by device storage) ───
final savedPromptsProvider = NotifierProvider<SavedPromptsNotifier, Set<String>>(
  SavedPromptsNotifier.new,
);

class SavedPromptsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final storage = ref.watch(localStorageProvider);
    return (storage?.getSavedPromptIds() ?? []).toSet();
  }

  bool isSaved(String id) => state.contains(id);

  Future<void> toggleSave(String id) async {
    final storage = ref.read(localStorageProvider);
    if (state.contains(id)) {
      await storage?.removePromptId(id);
      state = Set<String>.from(state)..remove(id);
    } else {
      await storage?.savePromptId(id);
      state = Set<String>.from(state)..add(id);
    }
  }

  Future<void> clearAll() async {
    final storage = ref.read(localStorageProvider);
    await storage?.clearAllSavedPrompts();
    state = {};
  }
}

// ─── Theme Mode ───
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storage = ref.watch(localStorageProvider);
    return (storage?.isDarkMode() ?? true) ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark => state == ThemeMode.dark;

  Future<void> toggle() async {
    final storage = ref.read(localStorageProvider);
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await storage?.setDarkMode(false);
    } else {
      state = ThemeMode.dark;
      await storage?.setDarkMode(true);
    }
  }
}

// ─── Notifications ───
final notificationsProvider = NotifierProvider<NotificationsNotifier, bool>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends Notifier<bool> {
  @override
  bool build() {
    final storage = ref.watch(localStorageProvider);
    return storage?.isNotificationsEnabled() ?? true;
  }

  Future<void> toggle() async {
    final storage = ref.read(localStorageProvider);
    state = !state;
    await storage?.setNotificationsEnabled(state);
  }
}