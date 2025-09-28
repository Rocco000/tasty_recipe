import 'package:tasty_recipe/Models/Recipe.dart';

sealed class RecipeListResult {}

class RecipeListSuccess extends RecipeListResult {
  final List<Recipe> recipeList;

  RecipeListSuccess(this.recipeList);
}

class RecipeListError extends RecipeListResult {
  final String message;

  RecipeListError(this.message);
}
