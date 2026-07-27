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
  final double rating;
  final int ratingCount;
  final String? imageUrl;

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
    this.rating = 4.8,
    this.ratingCount = 142,
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
    double? rating,
    int? ratingCount,
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
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'content': content,
        'aiTool': aiTool,
        'category': category,
        'difficulty': difficulty,
        'copyCount': copyCount,
        'isFavorite': isFavorite,
        'rating': rating,
        'ratingCount': ratingCount,
        'imageUrl': imageUrl,
      };

  factory PromptModel.fromJson(Map<String, dynamic> json) => PromptModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        content: json['content'] as String,
        aiTool: json['aiTool'] as String? ?? 'ChatGPT',
        category: json['category'] as String? ?? 'Custom',
        difficulty: json['difficulty'] as String? ?? 'Intermediate',
        copyCount: json['copyCount'] as int? ?? 0,
        isFavorite: json['isFavorite'] as bool? ?? false,
        rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
        ratingCount: json['ratingCount'] as int? ?? 142,
        imageUrl: json['imageUrl'] as String?,
      );
}
