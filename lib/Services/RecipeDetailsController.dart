import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/CartItem.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Services/CartItemDAO.dart';
import 'package:tasty_recipe/Services/IngredientDAO.dart';
import 'package:tasty_recipe/Services/RecipeService.dart';
import 'package:tasty_recipe/Utils/DatabaseOperationException.dart';
import 'package:tasty_recipe/Utils/UnknownDatabaseException.dart';

class RecipeDetailsController extends ChangeNotifier {
  final RecipeService _service = RecipeService();
  final IngredientDAO _ingredientDAO = IngredientDAO();
  final CartItemDAO _cartItemDAO = CartItemDAO();

  bool _isLoading = false;
  String? _error;

  Recipe _recipe;
  List<RecipeIngredient> _recipeIngredientList = [];
  List<Ingredient> _ingredients = [];
  List<RecipeStep> _recipeStepList = [];

  RecipeDetailsController(this._recipe);

  Recipe get recipe => _recipe;

  List<RecipeIngredient> get recipeIngredientList => _recipeIngredientList;

  List<Ingredient> get ingredients => _ingredients;

  List<RecipeStep> get recipeSteps => _recipeStepList;

  bool get isLoading => _isLoading;

  bool get hasError => _error != null;

  String? get errorMessage => _error;

  Future<void> loadFullRecipe() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (_recipeIngredientList.isEmpty ||
        _ingredients.isEmpty ||
        _recipeStepList.isEmpty) {
      // LOAD DATA FROM DB if no cached data is present
      try {
        // 1) Get ingredient info (quantity, etc.)
        _recipeIngredientList = await _service.getRecipeIngredients(_recipe.id);

        final List<String> ingredientIdList = [];
        for (RecipeIngredient item in _recipeIngredientList) {
          ingredientIdList.add(item.ingredientId);
        }

        // 2) Get ingredient names
        _ingredients = await _service.getIngredients(ingredientIdList);

        // 3) Get recipe steps
        _recipeStepList = await _service.getRecipeSteps(_recipe.id);
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
  }

  void updateRecipeInfoWithNewVersion(
    Recipe newRecipe,
    List<RecipeIngredient> newRecipeIngredientList,
    List<Ingredient> newIngredients,
    List<RecipeStep> newRecipeStepList,
  ) {
    _recipe = newRecipe;
    _recipeIngredientList = newRecipeIngredientList;
    _ingredients = newIngredients;
    _recipeStepList = newRecipeStepList;

    // Rebuild the UI
    notifyListeners();
  }

  Future<bool> updateRecipeFavoriteState(Recipe recipe) async {
    try {
      await _service.updateFavoriteState(recipe);
      return true;
    } on DatabaseOperationException catch (e) {
      return false;
    } on UnknownDatabaseException catch (e) {
      return false;
    }
  }

  Future<bool> addIngredientToCart(Ingredient ingredient) async {
    final bool ingredientExists = await _ingredientDAO.exists(ingredient);

    if (ingredientExists) {
      final newCartItem = CartItem("prova@gmail.com", ingredient.id, false);

      final bool cartCheck = await _cartItemDAO.exists(newCartItem);

      if (cartCheck) {
        // The ingredient is already added to the cart
        return false;
      } else {
        String cartItemId = await _cartItemDAO.save(newCartItem);

        return true;
      }
    } else {
      // The ingredient doesn't exist
      return false;
    }
  }

  Future<bool> deleteRecipe(Recipe recipe) async {
    try {
      await _service.deleteRecipe(recipe);

      return true;
    } on DatabaseOperationException catch (e) {
      return false;
    } on UnknownDatabaseException catch (e) {
      return false;
    }
  }
}
