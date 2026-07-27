import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prompt_model.dart';
import '../models/category_model.dart';
import '../repositories/prompt_repository.dart';
import '../repositories/hybrid_prompt_repository.dart';
import '../repositories/category_repository.dart';
import '../services/local_storage_service.dart';

final promptRepositoryProvider = Provider<PromptRepository>((ref) {
  return HybridPromptRepository();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final promptRepo = ref.watch(promptRepositoryProvider);
  return MockCategoryRepository(promptRepo: promptRepo);
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
  final repoPrompt = await repo.getPromptById(id);
  if (repoPrompt != null) return repoPrompt;

  final customPrompts = ref.watch(customPromptsProvider);
  try {
    return customPrompts.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});

// ─── Local Storage ───
final localStorageProvider = Provider<LocalStorageService?>((ref) => null);

// ─── Custom / Generated Prompts (backed by device storage) ───
final customPromptsProvider = NotifierProvider<CustomPromptsNotifier, List<PromptModel>>(
  CustomPromptsNotifier.new,
);

class CustomPromptsNotifier extends Notifier<List<PromptModel>> {
  @override
  List<PromptModel> build() {
    final storage = ref.watch(localStorageProvider);
    return storage?.getCustomPrompts() ?? [];
  }

  Future<void> saveCustomPrompt(PromptModel prompt) async {
    final storage = ref.read(localStorageProvider);
    await storage?.saveCustomPrompt(prompt);
    final current = List<PromptModel>.from(state);
    current.removeWhere((p) => p.id == prompt.id);
    current.insert(0, prompt);
    state = current;
  }

  Future<void> deleteCustomPrompt(String id) async {
    final storage = ref.read(localStorageProvider);
    await storage?.removeCustomPrompt(id);
    state = state.where((p) => p.id != id).toList();
  }

  Future<void> clearAll() async {
    final storage = ref.read(localStorageProvider);
    await storage?.clearAllCustomPrompts();
    state = [];
  }
}

// ─── Folders / Collections Provider ───
final customFoldersProvider = NotifierProvider<CustomFoldersNotifier, List<String>>(
  CustomFoldersNotifier.new,
);

class CustomFoldersNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final storage = ref.watch(localStorageProvider);
    return storage?.getCustomFolders() ?? ['All', 'Marketing', 'Coding', 'Image Prompts', 'Writing', 'Personal'];
  }

  Future<void> addFolder(String folderName) async {
    final storage = ref.read(localStorageProvider);
    await storage?.addCustomFolder(folderName);
    if (!state.contains(folderName)) {
      state = [...state, folderName];
    }
  }

  Future<void> removeFolder(String folderName) async {
    if (folderName == 'All') return;
    final storage = ref.read(localStorageProvider);
    await storage?.removeCustomFolder(folderName);
    state = state.where((f) => f != folderName).toList();
  }
}

final selectedFolderFilterProvider = NotifierProvider<SelectedFolderNotifier, String>(
  SelectedFolderNotifier.new,
);

class SelectedFolderNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setFolder(String folder) {
    state = folder;
  }
}

// ─── AI Tool Model Filter ───
final selectedAIToolFilterProvider = NotifierProvider<SelectedAIToolNotifier, String>(
  SelectedAIToolNotifier.new,
);

class SelectedAIToolNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setFilter(String aiTool) {
    state = aiTool;
  }
}

// ─── Ratings & Personal Notes ───
final promptRatingsProvider = NotifierProvider<PromptRatingsNotifier, Map<String, double>>(
  PromptRatingsNotifier.new,
);

class PromptRatingsNotifier extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() {
    return {};
  }

  double getRating(String id) {
    if (state.containsKey(id) && state[id] != null) return state[id]!;
    final storage = ref.read(localStorageProvider);
    return storage?.getPromptRating(id) ?? 0.0;
  }

  Future<void> setRating(String id, double rating) async {
    final storage = ref.read(localStorageProvider);
    await storage?.setPromptRating(id, rating);
    state = {...state, id: rating};
  }
}

final promptNotesProvider = NotifierProvider<PromptNotesNotifier, Map<String, String>>(
  PromptNotesNotifier.new,
);

class PromptNotesNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() {
    return {};
  }

  String getNote(String id) {
    if (state.containsKey(id) && state[id] != null) return state[id]!;
    final storage = ref.read(localStorageProvider);
    return storage?.getPromptNote(id) ?? '';
  }

  Future<void> saveNote(String id, String note) async {
    final storage = ref.read(localStorageProvider);
    await storage?.setPromptNote(id, note);
    state = {...state, id: note};
  }
}

// ─── Saved Prompt Folder Mappings ───
final savedPromptFoldersProvider = NotifierProvider<SavedPromptFoldersNotifier, Map<String, String>>(
  SavedPromptFoldersNotifier.new,
);

class SavedPromptFoldersNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {};

  String getFolder(String id, String defaultCategory) {
    if (state.containsKey(id) && state[id] != null) return state[id]!;
    final storage = ref.read(localStorageProvider);
    final folder = storage?.getSavedPromptFolder(id);
    return (folder != null && folder.isNotEmpty) ? folder : defaultCategory;
  }

  Future<void> setFolder(String id, String folder) async {
    final storage = ref.read(localStorageProvider);
    await storage?.setSavedPromptFolder(id, folder);
    state = {...state, id: folder};
  }
}

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

