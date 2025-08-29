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

  /// Create a new recipe and its related items in the DB through DAO classes
  /// - [newRecipe]: the new recipe to store
  /// - [ingredientList]: the recipe ingredients
  /// - [recipeIngredientList]: a list of RecipeIngredient objects. Each object represent an item in the relation table between Recipe and Ingredient.
  /// - [stepList]: the recipe steps
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
}
