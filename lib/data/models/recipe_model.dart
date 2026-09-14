import 'uploader_model.dart';

class Ingredient {
  final String name;
  final String amount;

  const Ingredient({
    required this.name,
    required this.amount,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      amount: json['amount'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }
}

class RecipeModel {
  final String id;
  final String name;
  final String image;
  final String category;
  final int cookingTimeMinutes;
  final double rating;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final UploaderModel uploader;

  const RecipeModel({
    required this.id,
    required this.name,
    required this.image,
    required this.category,
    required this.cookingTimeMinutes,
    required this.rating,
    required this.ingredients,
    required this.steps,
    required this.uploader,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      category: json['category'] as String,
      cookingTimeMinutes: json['cookingTimeMinutes'] as int,
      rating: (json['rating'] as num).toDouble(),
      ingredients: (json['ingredients'] as List)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List).map((e) => e as String).toList(),
      uploader: UploaderModel.fromJson(json['uploader'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'category': category,
      'cookingTimeMinutes': cookingTimeMinutes,
      'rating': rating,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps,
      'uploader': uploader.toJson(),
    };
  }
}
