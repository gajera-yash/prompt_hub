import 'dart:convert';

class UserPreferencesModel {
  final String? selectedGoal;
  final String? selectedTool;
  final List<String> selectedCategories;
  final String? outputPreference;

  UserPreferencesModel({
    this.selectedGoal,
    this.selectedTool,
    this.selectedCategories = const [],
    this.outputPreference,
  });

  Map<String, dynamic> toMap() {
    return {
      'selectedGoal': selectedGoal,
      'selectedTool': selectedTool,
      'selectedCategories': selectedCategories,
      'outputPreference': outputPreference,
    };
  }

  factory UserPreferencesModel.fromMap(Map<String, dynamic> map) {
    return UserPreferencesModel(
      selectedGoal: map['selectedGoal'],
      selectedTool: map['selectedTool'],
      selectedCategories: List<String>.from(map['selectedCategories'] ?? []),
      outputPreference: map['outputPreference'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserPreferencesModel.fromJson(String source) =>
      UserPreferencesModel.fromMap(json.decode(source));

  UserPreferencesModel copyWith({
    String? selectedGoal,
    String? selectedTool,
    List<String>? selectedCategories,
    String? outputPreference,
  }) {
    return UserPreferencesModel(
      selectedGoal: selectedGoal ?? this.selectedGoal,
      selectedTool: selectedTool ?? this.selectedTool,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      outputPreference: outputPreference ?? this.outputPreference,
    );
  }
}
