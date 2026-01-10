import 'package:tasty_recipe/recipe/models/entities/Ingredient.dart';
import 'package:tasty_recipe/recipe/models/entities/Recipe.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeIngredient.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeStep.dart';

class RecipeAggregate {
  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<RecipeIngredient> recipeIngredients;
  final List<RecipeStep> steps;

  RecipeAggregate({
    required this.recipe,
    required this.ingredients,
    required this.recipeIngredients,
    required this.steps,
  });
}
