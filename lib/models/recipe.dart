class Recipe {
  final int? id;
  final String title;
  final String category;
  final String difficulty;
  final int prepMinutes;
  final int cookMinutes;
  final int servings;
  final String ingredients;
  final String steps;
  final String tips;
  final String notes;
  final String? imagePath;
  final int isFavorite;

  Recipe({
    this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.servings,
    required this.ingredients,
    required this.steps,
    required this.tips,
    required this.notes,
    this.imagePath,
    this.isFavorite = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'difficulty': difficulty,
      'prepMinutes': prepMinutes,
      'cookMinutes': cookMinutes,
      'servings': servings,
      'ingredients': ingredients,
      'steps': steps,
      'tips': tips,
      'notes': notes,
      'imagePath': imagePath,
      'isFavorite': isFavorite,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      difficulty: map['difficulty'] ?? 'Kolay',
      prepMinutes: map['prepMinutes'],
      cookMinutes: map['cookMinutes'],
      servings: map['servings'],
      ingredients: map['ingredients'],
      steps: map['steps'],
      tips: map['tips'],
      notes: map['notes'],
      imagePath: map['imagePath'],
      isFavorite: map['isFavorite'],
    );
  }

  Recipe copyWith({
    int? id,
    String? title,
    String? category,
    String? difficulty,
    int? prepMinutes,
    int? cookMinutes,
    int? servings,
    String? ingredients,
    String? steps,
    String? tips,
    String? notes,
    String? imagePath,
    int? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      prepMinutes: prepMinutes ?? this.prepMinutes,
      cookMinutes: cookMinutes ?? this.cookMinutes,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      tips: tips ?? this.tips,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}