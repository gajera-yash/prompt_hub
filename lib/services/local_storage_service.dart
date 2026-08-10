import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences_model.dart';

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

  // ─── Onboarding & Preferences ───
  bool hasSeenOnboarding() => _prefs.getBool('hasSeenOnboarding') ?? false;
  Future<void> setHasSeenOnboarding(bool value) =>
      _prefs.setBool('hasSeenOnboarding', value);

  UserPreferencesModel? getUserPreferences() {
    final str = _prefs.getString('userPreferences');
    if (str != null && str.isNotEmpty) {
      try {
        return UserPreferencesModel.fromJson(str);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> saveUserPreferences(UserPreferencesModel prefs) =>
      _prefs.setString('userPreferences', prefs.toJson());

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
}
