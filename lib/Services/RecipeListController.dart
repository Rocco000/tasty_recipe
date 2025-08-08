import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Services/RecipeDAO.dart';
import 'package:tasty_recipe/Utils/RecipeFilter.dart';

class RecipeListController{
  final RecipeDAO _recipeDAO = RecipeDAO();
  final RecipeFilter filter;

  RecipeListController(this.filter);

  Future<List<Recipe>> getRecipes() async{
    switch(filter.type){
      case RecipeFilterType.favorites:
        return await onFavoritePressed();
      case RecipeFilterType.breakfast:
        return await onBreakfastCardPressed();
      case RecipeFilterType.firstCourse:
        return await onFirstCourseCardPressed();
      case RecipeFilterType.secondCourse:
        return await onSecondCourseCardPressed();
      case RecipeFilterType.snack:
        return await onSnackCardPressed();
      case RecipeFilterType.dessert:
        return await onDessertCardPressed();
    }
  }
  
  Future<List<Recipe>> onFavoritePressed() async{
    return await _recipeDAO.getFavoriteRecipes();
  }

  Future<List<Recipe>> onBreakfastCardPressed() async{
    return await _recipeDAO.getRecipeByCategory("Breakfast");
  }

  Future<List<Recipe>> onFirstCourseCardPressed() async{
    return await _recipeDAO.getRecipeByCategory("First course");
  }

  Future<List<Recipe>> onSecondCourseCardPressed() async{
    return await _recipeDAO.getRecipeByCategory("Second course");
  }

  Future<List<Recipe>> onSnackCardPressed() async{
    return await _recipeDAO.getRecipeByCategory("Snack");
  }

  Future<List<Recipe>> onDessertCardPressed() async{
    return await _recipeDAO.getRecipeByCategory("Dessert");
  }
}