import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Services/IngredientDAO.dart';
import 'package:tasty_recipe/Services/RecipeDAO.dart';
import 'package:tasty_recipe/Services/RecipeIngredientDAO.dart';
import 'package:tasty_recipe/Services/RecipeStepDAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';
import 'package:tasty_recipe/Utils/DatabaseOperationException.dart';
import 'package:tasty_recipe/Utils/UnknownDatabaseException.dart';
import 'package:tasty_recipe/Utils/ValidationException.dart';

class RecipeService {
  final RecipeDAO _recipeDAO = RecipeDAO();
  final RecipeIngredientDAO _recipeIngredientDAO = RecipeIngredientDAO();
  final RecipeStepDAO _recipeStepDAO = RecipeStepDAO();
  final IngredientDAO _ingredientDAO = IngredientDAO();

  /// Create a new recipe and its related items in the DB through a transaction
  /// - [newRecipe]: the new recipe to store
  /// - [ingredientList]: the recipe ingredients
  /// - [recipeIngredientList]: a list of RecipeIngredient objects. Each object represent an item in the relation table between Recipe and Ingredient.
  /// - [stepList]: the recipe steps
  ///
  /// Throw [DatabaseOperationException] if an error occurred during the transaction.
  /// Throw [ValidationException] if the total step duration doesn't match recipe duration.
  /// Throw [DatabaseOperationException] if an error occurred during the transaction.
  /// Throw [UnknownDatabaseException] if an unexpected error is thrown.
  Future<void> createRecipe(
    Recipe newRecipe,
    List<Ingredient> ingredientList,
    List<RecipeIngredient> recipeIngredientList,
    List<RecipeStep> stepList,
  ) async {
    // Check whether the temporary data is properly stored
    if (ingredientList.isEmpty ||
        recipeIngredientList.isEmpty ||
        stepList.isEmpty) {
      throw ArgumentError("Invalid input. Try again.");
    }

    // Check whether the total step duration match the recipe duration
    double totalStepDuration = 0.0;

    stepList.forEach((step) {
      if (step.duration != null) {
        double stepDuration = (step.durationUnit! == "hour")
            ? step.duration! * 60
            : (step.durationUnit! == "minute")
            ? step.duration!
            : step.duration! / 60;

        totalStepDuration += stepDuration;
      }
    });

    if (newRecipe.duration != totalStepDuration.toInt()) {
      throw ValidationException(
        "Total step duration doesn't match recipe duration!",
        StackTrace.current,
      );
    }

    // Define a batch to run a transaction
    final batch = FirebaseFirestore.instance.batch();

    // 1.1) Get the reference of the new document and its ID
    DocumentReference recipeRef = _recipeDAO.newRef();
    newRecipe.id = recipeRef.id;

    // 1.2) Store the new recipe
    _recipeDAO.saveWithBatch(recipeRef, newRecipe, batch);

    // 2.1) Get the ingredient ID or eventually create a new one
    for (int i = 0; i < ingredientList.length; i++) {
      String ingredientId;
      try {
        // Get the ID of an EXISTING ingredient
        ingredientId = await _ingredientDAO.getId(ingredientList[i]);
      } on DataNotFoundException {
        // Crete a NEW ingredient
        DocumentReference ingredientRef = _ingredientDAO.newRef();
        ingredientId = ingredientRef.id;
        _ingredientDAO.saveWithBatch(ingredientRef, ingredientList[i], batch);
      }

      // 2.2) Update the RecipeIngredient keys
      recipeIngredientList[i].recipeId = newRecipe.id;
      recipeIngredientList[i].ingredientId = ingredientId;

      // 2.3)  Store the RecipeIngredient items
      DocumentReference recipeIngredientRef = _recipeIngredientDAO.newRef();
      _recipeIngredientDAO.saveWithBatch(
        recipeIngredientRef,
        recipeIngredientList[i],
        batch,
      );
    }

    // 3) Store recipe steps
    for (RecipeStep step in stepList) {
      // Update foreign key
      step.recipeId = newRecipe.id;

      // Get step reference
      DocumentReference stepRef = _recipeStepDAO.newRef();

      _recipeStepDAO.saveWithBatch(stepRef, step, batch);
    }

    try {
      await batch.commit();
    } on FirebaseException catch (e, st) {
      throw DatabaseOperationException(
        "An error occurred during the transaction. Failed to save the new recipe",
        st,
      );
    } catch (e, st) {
      throw UnknownDatabaseException(
        "Unexpected error while saving the new recipe",
        st,
      );
    }
  }

  /// Return the recipe with the given ID
  /// - [id] the recipe ID.
  ///
  /// Throw [ArgumentError] if the input ID is empty.
  /// Throw [DatabaseOperationException] if the recipe doesn't exist.
  /// Throw [UnknownDatabaseException] if an unexpected error is thrown.
  Future<Recipe> getRecipe(String id) async {
    if (id.isEmpty) {
      throw ArgumentError("Invalid input! The input string is empty.");
    }

    try {
      return await _recipeDAO.getRecipeById(id);
    } on ArgumentError catch (e) {
      throw ArgumentError("Invalid input! The input string is empty.");
    } on DataNotFoundException catch (e) {
      throw DatabaseOperationException(e.message, e.stackTrace);
    } catch (e) {
      throw UnknownDatabaseException(
        "Unexpected error while fetching the recipe",
        StackTrace.current,
      );
    }
  }

  /// Return all RecipeIngredient items of the given recipe
  /// - [recipeId] the recipe ID.
  ///
  /// Throw [ArgumentError] if the input ID is empty.
  /// Throw [DatabaseOperationException] if the recipe doesn't exist.
  /// Throw [UnknownDatabaseException] if an unexpected error is thrown.
  Future<List<RecipeIngredient>> getRecipeIngredients(String recipeId) async {
    if (recipeId.isEmpty) {
      throw ArgumentError("Invalid input! The input string is empty.");
    }

    try {
      return await _recipeIngredientDAO.getRecipeIngredientsByRecipeId(
        recipeId,
      );
    } on ArgumentError catch (e) {
      throw ArgumentError("Invalid input! The input string is empty.");
    } on DataNotFoundException catch (e) {
      throw DatabaseOperationException(e.message, e.stackTrace);
    } catch (e) {
      throw UnknownDatabaseException(
        "Unexpected error while fetching the RecipeIngredient items",
        StackTrace.current,
      );
    }
  }

  /// Return all ingredients that have a match with the input IDs.
  /// - [ingredientIds] a list of ingredient ID
  ///
  /// Throw [ArgumentError] if the input list or an ID is empty.
  /// Throw [DatabaseOperationException] if one of the IDs does not correspond to any ingredient.
  /// Throw [UnknownDatabaseException] if an unexpected error is thrown.
  Future<List<Ingredient>> getIngredients(List<String> ingredientIds) async {
    if (ingredientIds.isEmpty) {
      throw ArgumentError("Invalid input! The input list is empty.");
    }

    List<Ingredient> ingredients = [];

    for (String id in ingredientIds) {
      try {
        final Ingredient ingredient = await _ingredientDAO.getIngredientById(
          id,
        );
        ingredients.add(ingredient);
      } on ArgumentError catch (e) {
        throw ArgumentError(e.message);
      } on DataNotFoundException catch (e) {
        throw DatabaseOperationException(e.message, e.stackTrace);
      } catch (e) {
        throw UnknownDatabaseException(
          "Unexpected error while fetching the Ingredient items",
          StackTrace.current,
        );
      }
    }

    return ingredients;
  }

  /// Return all steps of the given recipe using the DAO class
  /// - [recipeId] the recipe ID
  ///
  /// Throw [ArgumentError] if the the input string is empty.
  /// Throw [DatabaseOperationException] if the recipe doesn't exist.
  /// Throw [UnknownDatabaseException] if an unexpected error is thrown.
  Future<List<RecipeStep>> getRecipeSteps(String recipeId) async {
    if (recipeId.isEmpty) {
      throw ArgumentError("Invalid input! The input string is empty.");
    }

    try {
      return await _recipeStepDAO.getAllRecipeStepById(recipeId);
    } on ArgumentError catch (e) {
      throw ArgumentError(e.message);
    } on DataNotFoundException catch (e) {
      throw DatabaseOperationException(e.message, e.stackTrace);
    } catch (e) {
      throw UnknownDatabaseException(
        "Unexpected error while fetching the RecipeStep items",
        StackTrace.current,
      );
    }
  }

  /// Update the favorite state of the given Recipe using the DAO class
  /// - [recipe] the recipe to be deleted.
  ///
  /// Throw [DatabaseOperationException] if the recipe doesn't exist or an error occurred during the update.
  /// Throw [UnknownDatabaseException] if an unexpected error is thrown.
  Future<void> updateFavoriteState(Recipe recipe) async {
    try {
      await _recipeDAO.updateFavoriteState(recipe, !recipe.isFavorite);
      return;
    } on DataNotFoundException catch (e) {
      throw DatabaseOperationException(e.message, e.stackTrace);
    } on DatabaseOperationException catch (e) {
      throw DatabaseOperationException(e.message, e.stackTrace);
    } on UnknownDatabaseException catch (e) {
      throw UnknownDatabaseException(e.message, e.stackTrace);
    }
  }

  /// Delete the input recipe and its related items from the database using a transaction and the DAO classes
  /// - [recipe] the recipe to be deleted.
  ///
  /// Throw a [DatabaseOperationException] if the recipe or its items do not exist in the database.
  /// Throw a [UnknownDatabaseException] if an unexpected error is thrown.
  Future<void> deleteRecipe(Recipe recipe) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      // Add delete operations to the transaction
      await _recipeStepDAO.deleteByRecipeId(recipe.id, batch);
      await _recipeIngredientDAO.deleteByRecipeId(recipe.id, batch);
      _recipeDAO.deleteByRecipeId(recipe.id, batch);

      // Perform the transaction
      await batch.commit();

      return;
    } on DataNotFoundException catch (e, st) {
      throw DatabaseOperationException(e.message, st);
    } catch (e) {
      throw UnknownDatabaseException(
        "Unexpected error while deleting the recipe",
        StackTrace.current,
      );
    }
  }
}
