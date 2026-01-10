import 'package:flutter/material.dart';
import 'package:tasty_recipe/recipe/models/entities/Ingredient.dart';
import 'package:tasty_recipe/recipe/models/entities/Recipe.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeAggregate.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeIngredient.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeStep.dart';
import 'package:tasty_recipe/recipe/services/RecipeService.dart';
import 'package:tasty_recipe/cart/services/CartService.dart';
import 'package:tasty_recipe/Utils/DatabaseOperationException.dart';
import 'package:tasty_recipe/Utils/UnknownDatabaseException.dart';

class RecipeDetailsController extends ChangeNotifier {
  // RecipeService to handle delete operation
  final RecipeService _recipeService = RecipeService();

  // CartService to handle cart operations
  final CartService _cartService = CartService();

  // All recipe data
  final RecipeAggregate _recipeData;

  bool _isLoading = false;
  String? _error;

  RecipeDetailsController(this._recipeData);

  Recipe get recipe => _recipeData.recipe;

  List<RecipeIngredient> get recipeIngredientList =>
      _recipeData.recipeIngredients;

  List<Ingredient> get ingredients => _recipeData.ingredients;

  List<RecipeStep> get recipeSteps => _recipeData.steps;

  bool get isLoading => _isLoading;

  bool get hasError => _error != null;

  String? get errorMessage => _error;

  /*Future<void> loadFullRecipe() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (_recipeIngredientList.isEmpty ||
        _ingredients.isEmpty ||
        _recipeStepList.isEmpty) {
      // LOAD DATA FROM DB if no cached data is present
      try {
        // 1) Get ingredient info (quantity, etc.)
        _recipeIngredientList = await _recipeService.getRecipeIngredients(
          _recipe.id,
        );

        final List<String> ingredientIdList = [];
        for (RecipeIngredient item in _recipeIngredientList) {
          ingredientIdList.add(item.ingredientId);
        }

        // 2) Get ingredient names
        _ingredients = await _recipeService.getIngredients(ingredientIdList);

        // 3) Get recipe steps
        _recipeStepList = await _recipeService.getRecipeSteps(_recipe.id);
      } on ArgumentError catch (e) {
        _error = "Invalid input. Try again.";
      } on DatabaseOperationException catch (e) {
        _error = "Unable to load that recipe. Try again.";
      } on UnknownDatabaseException catch (e) {
        _error = "Something went wrong. Try again.";
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }*/

  /// Update the favorite state of the current recipe.
  ///
  /// Returns true if the update is successful, false otherwise.
  Future<bool> updateRecipeFavoriteState(Recipe recipe) async {
    try {
      await _recipeService.updateFavoriteState(recipe);
      return true;
    } on DatabaseOperationException catch (e) {
      return false;
    } on UnknownDatabaseException catch (e) {
      return false;
    }
  }

  /// Add the input ingredient to the user's cart using the CartService.
  /// - [ingredient] the Ingredient to add to the user's cart.
  ///
  /// Return true if the ingredient is added to the user's cart, false otherwise.
  Future<bool> addIngredientToCart(Ingredient ingredient) async {
    try {
      await _cartService.addIngredientToCart("prova@gmail.com", ingredient);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRecipe(Recipe recipe) async {
    try {
      await _recipeService.deleteRecipe(recipe);

      return true;
    } on DatabaseOperationException catch (e) {
      return false;
    } on UnknownDatabaseException catch (e) {
      return false;
    }
  }
}
