import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Services/RecipeService.dart';
import 'package:tasty_recipe/Utils/DatabaseOperationException.dart';
import 'package:tasty_recipe/Utils/RecipeFilter.dart';
import 'package:tasty_recipe/Utils/RecipeListResult.dart';
import 'package:tasty_recipe/Utils/UnknownDatabaseException.dart';

class RecipeListController {
  final RecipeService _service = RecipeService();
  final RecipeFilter filter;

  RecipeListController(this.filter);

  Future<RecipeListResult> getRecipes() async {
    try {
      List<Recipe> recipeList = [];
      switch (filter.type) {
        case RecipeFilterType.favorites:
          recipeList = await _onFavoritePressed();
        case RecipeFilterType.breakfast:
          recipeList = await _onBreakfastCardPressed();
        case RecipeFilterType.firstCourse:
          recipeList = await _onFirstCourseCardPressed();
        case RecipeFilterType.secondCourse:
          recipeList = await _onSecondCourseCardPressed();
        case RecipeFilterType.snack:
          recipeList = await _onSnackCardPressed();
        case RecipeFilterType.dessert:
          recipeList = await _onDessertCardPressed();
      }
      return RecipeListSuccess(recipeList);
    } on DatabaseOperationException catch (e) {
      return RecipeListError("Unable to load the recipe list. Try again.");
    } on UnknownDatabaseException catch (e) {
      return RecipeListError("Something went wrong. Try again.");
    }
  }

  Future<List<Recipe>> _onFavoritePressed() async {
    return await _service.getFavoriteRecipeList();
  }

  Future<List<Recipe>> _onBreakfastCardPressed() async {
    return await _service.getRecipeListByCategory("Breakfast");
  }

  Future<List<Recipe>> _onFirstCourseCardPressed() async {
    return await _service.getRecipeListByCategory("First Course");
  }

  Future<List<Recipe>> _onSecondCourseCardPressed() async {
    return await _service.getRecipeListByCategory("Second Course");
  }

  Future<List<Recipe>> _onSnackCardPressed() async {
    return await _service.getRecipeListByCategory("Snack");
  }

  Future<List<Recipe>> _onDessertCardPressed() async {
    return await _service.getRecipeListByCategory("Dessert");
  }
}
