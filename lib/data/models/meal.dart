// lib/data/models/meal.dart

class Meal {
  final String id;
  final String name;
  final String? category;
  final String? area;
  final String? instructions;
  final String? thumbnail;
  final String? tags;
  final String? youtubeUrl;
  final String? sourceUrl;

  // Ingredients (up to 20)
  final List<MealIngredient> ingredients;

  // Favourited locally
  bool isFavourite;

  Meal({
    required this.id,
    required this.name,
    this.category,
    this.area,
    this.instructions,
    this.thumbnail,
    this.tags,
    this.youtubeUrl,
    this.sourceUrl,
    this.ingredients = const [],
    this.isFavourite = false,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final ingredients = <MealIngredient>[];
    
    // Handle the new API format where ingredients is a list of objects
    if (json['ingredients'] is List) {
      for (var item in (json['ingredients'] as List)) {
        final ing = item['ingredient']?.toString().trim();
        final measure = item['measure']?.toString().trim();
        if (ing != null && ing.isNotEmpty) {
          ingredients.add(MealIngredient(name: ing, measure: measure ?? ''));
        }
      }
    } else {
      // Fallback for TheMealDB classic format
      for (int i = 1; i <= 20; i++) {
        final ing = json['strIngredient$i']?.toString().trim();
        final measure = json['strMeasure$i']?.toString().trim();
        if (ing != null && ing.isNotEmpty) {
          ingredients.add(MealIngredient(name: ing, measure: measure ?? ''));
        }
      }
    }

    return Meal(
      id: json['idMeal']?.toString() ?? json['id']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? json['meal']?.toString() ?? json['name']?.toString() ?? 'Unknown',
      category: json['strCategory']?.toString() ?? json['category']?.toString(),
      area: json['strArea']?.toString() ?? json['area']?.toString(),
      instructions: json['strInstructions']?.toString() ?? json['instructions']?.toString(),
      thumbnail: json['strMealThumb']?.toString() ?? json['meal_thumb']?.toString() ?? json['thumbnail']?.toString(),
      tags: json['strTags']?.toString() ?? json['tags']?.toString(),
      youtubeUrl: json['strYoutube']?.toString() ?? json['youtube']?.toString() ?? json['youtubeUrl']?.toString(),
      sourceUrl: json['strSource']?.toString() ?? json['source_url']?.toString() ?? json['sourceUrl']?.toString(),
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': thumbnail,
      'strTags': tags,
      'strYoutube': youtubeUrl,
      'strSource': sourceUrl,
    };
    for (int i = 0; i < ingredients.length && i < 20; i++) {
      map['strIngredient${i + 1}'] = ingredients[i].name;
      map['strMeasure${i + 1}'] = ingredients[i].measure;
    }
    return map;
  }

  // For SQLite
  Map<String, dynamic> toDbMap() => {
        'id': id,
        'name': name,
        'category': category,
        'area': area,
        'instructions': instructions,
        'thumbnail': thumbnail,
        'tags': tags,
        'youtubeUrl': youtubeUrl,
        'sourceUrl': sourceUrl,
        'ingredients': ingredients.map((e) => '${e.name}|${e.measure}').join(';;'),
      };

  factory Meal.fromDbMap(Map<String, dynamic> map) {
    final ingStr = map['ingredients'] as String? ?? '';
    final ingredients = ingStr.isEmpty
        ? <MealIngredient>[]
        : ingStr
            .split(';;')
            .map((e) {
              final parts = e.split('|');
              return MealIngredient(
                name: parts.isNotEmpty ? parts[0] : '',
                measure: parts.length > 1 ? parts[1] : '',
              );
            })
            .toList();

    return Meal(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString(),
      area: map['area']?.toString(),
      instructions: map['instructions']?.toString(),
      thumbnail: map['thumbnail']?.toString(),
      tags: map['tags']?.toString(),
      youtubeUrl: map['youtubeUrl']?.toString(),
      sourceUrl: map['sourceUrl']?.toString(),
      ingredients: ingredients,
      isFavourite: true,
    );
  }

  Meal copyWith({
    String? id,
    String? name,
    String? category,
    String? area,
    String? instructions,
    String? thumbnail,
    String? tags,
    String? youtubeUrl,
    String? sourceUrl,
    List<MealIngredient>? ingredients,
    bool? isFavourite,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      area: area ?? this.area,
      instructions: instructions ?? this.instructions,
      thumbnail: thumbnail ?? this.thumbnail,
      tags: tags ?? this.tags,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      ingredients: ingredients ?? this.ingredients,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
}

class MealIngredient {
  final String name;
  final String measure;

  const MealIngredient({required this.name, required this.measure});
}
