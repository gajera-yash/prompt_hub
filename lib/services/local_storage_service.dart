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

  // ─── Daily Prompt Generation Limit ───
  static const int dailyFreePromptLimit = 3;

  int getDailyPromptCount() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = _prefs.getString('promptDate') ?? '';
    if (savedDate != today) {
      return 0;
    }
    return _prefs.getInt('promptCount') ?? 0;
  }

  Future<void> incrementDailyPromptCount() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = _prefs.getString('promptDate') ?? '';
    if (savedDate != today) {
      await _prefs.setString('promptDate', today);
      await _prefs.setInt('promptCount', 1);
    } else {
      final count = _prefs.getInt('promptCount') ?? 0;
      await _prefs.setInt('promptCount', count + 1);
    }
  }

  bool get hasReachedDailyPromptLimit =>
      getDailyPromptCount() >= dailyFreePromptLimit;

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
