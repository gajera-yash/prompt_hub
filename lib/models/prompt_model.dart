class PromptModel {
  final String id;
  final String title;
  final String description;
  final String content;
  final String aiTool;
  final String category;
  final String difficulty;
  final int copyCount;
  final bool isFavorite;
  final String? imageUrl; // Added for Trending Photos

  PromptModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.aiTool,
    required this.category,
    this.difficulty = 'Intermediate',
    this.copyCount = 0,
    this.isFavorite = false,
    this.imageUrl,
  });

  PromptModel copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? aiTool,
    String? category,
    String? difficulty,
    int? copyCount,
    bool? isFavorite,
    String? imageUrl,
  }) {
    return PromptModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      aiTool: aiTool ?? this.aiTool,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      copyCount: copyCount ?? this.copyCount,
      isFavorite: isFavorite ?? this.isFavorite,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'aiTool': aiTool,
      'category': category,
      'difficulty': difficulty,
      'copyCount': copyCount,
      'isFavorite': isFavorite,
      'imageUrl': imageUrl,
    };
  }

  factory PromptModel.fromJson(Map<String, dynamic> json) {
    return PromptModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      content: json['content'],
      aiTool: json['aiTool'],
      category: json['category'],
      difficulty: json['difficulty'] ?? 'Intermediate',
      copyCount: json['copyCount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }
}
