import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Services/RecipeService.dart';
import 'package:tasty_recipe/Utils/DatabaseOperationException.dart';
import 'package:tasty_recipe/Utils/UnknownDatabaseException.dart';
import 'package:tasty_recipe/Utils/ValidationException.dart';

class RecipeEditController extends ChangeNotifier {
  final RecipeService _service = RecipeService();
  final Recipe _oldRecipe;
  final List<RecipeIngredient> _oldRecipeIngredient;
  final List<Ingredient> _oldIngredients;
  final List<RecipeStep> _oldRecipeSteps;

  late Recipe _editedRecipe;
  late List<Ingredient> _editedIngredientList;
  late List<RecipeIngredient> _editedRecipeIngredientList;
  late List<RecipeStep> _editedRecipeStepList;

  RecipeEditController(
    this._oldRecipe,
    this._oldRecipeIngredient,
    this._oldIngredients,
    this._oldRecipeSteps,
  );

  Recipe get oldRecipe => _oldRecipe;

  Recipe get newRecipe => _editedRecipe;

  List<RecipeIngredient> get oldRecipeIngredientList => _oldRecipeIngredient;

  List<RecipeIngredient> get newRecipeIngredientList =>
      _editedRecipeIngredientList;

  List<Ingredient> get oldIngredients => _oldIngredients;

  List<Ingredient> get newIngredients => _editedIngredientList;

  List<RecipeStep> get oldRecipeSteps => _oldRecipeSteps;

  List<RecipeStep> get newRecipeSteps => _editedRecipeStepList;

  /// Temporary store changes on recipe general info
  /// [recipe] a Recipe object with some changes
  void updateGeneralInfo(Recipe recipe) {
    _editedRecipe = recipe;
  }

  /// Temporary store the recipe ingredients
  /// [ingredients] a List of Ingredient objects
  void updateIngredients(List<Ingredient> ingredients) {
    _editedIngredientList = ingredients;
  }

  /// Temporary store changes on RecipeIngredient objects related to that recipe
  /// [recipeIngredientList] a List of RecipeIngredient objects
  void updateRecipeIngredient(List<RecipeIngredient> recipeIngredientList) {
    _editedRecipeIngredientList = recipeIngredientList;
  }

  /// Temporary stoe changes on recipe steps
  /// [recipeSteps] a List of RecipeStep objects
  void updateRecipeSteps(List<RecipeStep> recipeSteps) {
    _editedRecipeStepList = recipeSteps;
  }

  /// clear the ingredient list
  void clearIngredients() {
    _editedIngredientList.clear();
  }

  /// Clear the RecipeIngredient list
  void clearRecipeIngredientList() {
    _editedRecipeIngredientList.clear();
  }

  /// Clear the RecipeStep list
  void clearRecipeSteps() {
    _editedRecipeStepList.clear();
  }

  /// Store the changes to the input recipe using the RecipeService class
  ///
  /// Return true if changes are correctly stored in the database, otherwise return false and an error message to explain the error.
  Future<(bool, String)> saveChanges() async {
    try {
      await _service.updateRecipe(
        _editedRecipe,
        _oldRecipeIngredient,
        _editedRecipeIngredientList,
        _oldIngredients,
        _editedIngredientList,
        _oldRecipeSteps,
        _editedRecipeStepList,
      );

      return (true, "");
    } on ArgumentError catch (e) {
      return (false, "Invalid input. Try again.");
    } on ValidationException catch (e) {
      return (false, e.message);
    } on DatabaseOperationException catch (e) {
      return (false, "Something went wrong. Try again.");
    } on UnknownDatabaseException catch (e) {
      return (false, "Something went wrong. Try again.");
    }
  }
}
