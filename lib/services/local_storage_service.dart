import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prompt_model.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  late SharedPreferences _prefs;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // ─── Dark Mode ───
  bool isDarkMode() => _prefs.getBool('isDarkMode') ?? true;
  Future<void> setDarkMode(bool value) => _prefs.setBool('isDarkMode', value);

  // ─── Notifications ───
  bool isNotificationsEnabled() => _prefs.getBool('notifications') ?? true;
  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool('notifications', value);

  // ─── Onboarding ───
  bool hasSeenOnboarding() => _prefs.getBool('hasSeenOnboarding') ?? false;
  Future<void> setHasSeenOnboarding(bool value) =>
      _prefs.setBool('hasSeenOnboarding', value);

  // ─── Saved Prompts ───
  List<String> getSavedPromptIds() =>
      _prefs.getStringList('savedPrompts') ?? [];

  Future<void> savePromptId(String id) async {
    final list = getSavedPromptIds();
    if (!list.contains(id)) {
      list.add(id);
      await _prefs.setStringList('savedPrompts', list);
    }
  }

  Future<void> removePromptId(String id) async {
    final list = getSavedPromptIds();
    list.remove(id);
    await _prefs.setStringList('savedPrompts', list);
  }

  Future<void> clearAllSavedPrompts() async {
    await _prefs.remove('savedPrompts');
  }

  // ─── Generated / Custom Prompts ───
  List<PromptModel> getCustomPrompts() {
    final rawList = _prefs.getStringList('customPrompts') ?? [];
    final List<PromptModel> list = [];
    for (final str in rawList) {
      try {
        final map = json.decode(str) as Map<String, dynamic>;
        list.add(PromptModel.fromJson(map));
      } catch (_) {}
    }
    return list;
  }

  Future<void> saveCustomPrompt(PromptModel prompt) async {
    final list = getCustomPrompts();
    list.removeWhere((p) => p.id == prompt.id);
    list.insert(0, prompt); // add latest to front
    final rawList = list.map((p) => json.encode(p.toJson())).toList();
    await _prefs.setStringList('customPrompts', rawList);
  }

  Future<void> removeCustomPrompt(String id) async {
    final list = getCustomPrompts();
    list.removeWhere((p) => p.id == id);
    final rawList = list.map((p) => json.encode(p.toJson())).toList();
    await _prefs.setStringList('customPrompts', rawList);
  }

  Future<void> clearAllCustomPrompts() async {
    await _prefs.remove('customPrompts');
  }

  // ─── Folders & Collections ───
  List<String> getCustomFolders() {
    final list = _prefs.getStringList('customFolders');
    if (list != null && list.isNotEmpty) return list;
    return ['All', 'Marketing', 'Coding', 'Image Prompts', 'Writing', 'Personal'];
  }

  Future<void> addCustomFolder(String folderName) async {
    final list = getCustomFolders();
    if (!list.contains(folderName)) {
      list.add(folderName);
      await _prefs.setStringList('customFolders', list);
    }
  }

  Future<void> removeCustomFolder(String folderName) async {
    final list = getCustomFolders();
    list.remove(folderName);
    await _prefs.setStringList('customFolders', list);
  }

  // ─── Prompt Ratings & Personal Notes ───
  double getPromptRating(String promptId) =>
      _prefs.getDouble('rating_$promptId') ?? 0.0;

  Future<void> setPromptRating(String promptId, double rating) =>
      _prefs.setDouble('rating_$promptId', rating);

  String getPromptNote(String promptId) =>
      _prefs.getString('note_$promptId') ?? '';

  Future<void> setPromptNote(String promptId, String note) =>
      _prefs.setString('note_$promptId', note);

  // ─── Saved Prompt Folder Mappings ───
  String getSavedPromptFolder(String promptId) =>
      _prefs.getString('folder_$promptId') ?? '';

  Future<void> setSavedPromptFolder(String promptId, String folder) =>
      _prefs.setString('folder_$promptId', folder);
}
