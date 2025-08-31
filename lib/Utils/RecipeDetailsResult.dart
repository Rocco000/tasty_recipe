import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';

sealed class RecipeDetailsResult {}

class RecipeDetailsSuccess extends RecipeDetailsResult {
  final Recipe recipe;
  final List<RecipeIngredient> recipeIngredients;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;

  RecipeDetailsSuccess(
    this.recipe,
    this.recipeIngredients,
    this.ingredients,
    this.steps,
  );
}

class RecipeDetailsError extends RecipeDetailsResult {
  final String message;

  RecipeDetailsError(this.message);
}
