import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/recipe/models/entities/Ingredient.dart';
import 'package:tasty_recipe/recipe/models/entities/Recipe.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeAggregate.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeIngredient.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeStep.dart';
import 'package:tasty_recipe/recipe/models/dao/IngredientDAO.dart';
import 'package:tasty_recipe/recipe/models/dao/RecipeDAO.dart';
import 'package:tasty_recipe/recipe/models/dao/RecipeIngredientDAO.dart';
import 'package:tasty_recipe/recipe/models/dao/RecipeStepDAO.dart';
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
  /// Returns a [RecipeAggregate] that contains the created recipe with corresponding IDs
  ///
  /// Throw [DatabaseOperationException] if an error occurred during the transaction.
  /// Throw [ValidationException] if the total step duration doesn't match recipe duration.
  /// Throw [DatabaseOperationException] if an error occurred during the transaction.
  /// Throw [UnknownDatabaseException] if an unexpected error is thrown.
  Future<RecipeAggregate> createRecipe(
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

    // --- RECIPE ---
    // 1.1) Get the reference of the new document and its ID
    DocumentReference recipeRef = _recipeDAO.newRef();
    newRecipe.id = recipeRef.id;

    // 1.2) Store the new recipe
    _recipeDAO.saveWithBatch(recipeRef, newRecipe, batch);

    // --- INGREDIENT ---

    List<Ingredient> ingredientsWithID = [];
    List<RecipeIngredient> recipeIngredientWithID = [];

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

      // Set the right ID and store it in aggregate
      ingredientList[i].id = ingredientId;
      ingredientsWithID.add(ingredientList[i]);

      // --- RECIPE INGREDIENTS (N:N) ---
      // 2.2) Update the RecipeIngredient keys
      recipeIngredientList[i].recipeId = newRecipe.id;
      recipeIngredientList[i].ingredientId = ingredientId;

      recipeIngredientWithID.add(recipeIngredientList[i]);

      // 2.3)  Store the RecipeIngredient items
      DocumentReference recipeIngredientRef = _recipeIngredientDAO.newRef();
      _recipeIngredientDAO.saveWithBatch(
        recipeIngredientRef,
        recipeIngredientList[i],
        batch,
      );
    }

    // --- STEPS ---
    List<RecipeStep> stepsWithID = [];

    // 3) Store recipe steps
    for (RecipeStep step in stepList) {
      // Update foreign key
      step.recipeId = newRecipe.id;

      // Get step reference
      DocumentReference stepRef = _recipeStepDAO.newRef();

      _recipeStepDAO.saveWithBatch(stepRef, step, batch);

      stepsWithID.add(step);
    }

    try {
      await batch.commit();
      return RecipeAggregate(
        recipe: newRecipe,
        ingredients: ingredientsWithID,
        recipeIngredients: recipeIngredientWithID,
        steps: stepsWithID,
      );
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

  /// Return a list of favourite recipes
  ///
  /// Throw [DatabaseOperationException] if a FirebaseException is thrown while fetching the list of favourite recipes.
  /// Throw [UnknownDatabaseException] if an unexpected error occurs while fetching the list of favourite recipes.
  Future<List<Recipe>> getFavoriteRecipeList() async {
    try {
      return await _recipeDAO.getFavoriteRecipes();
    } on DataNotFoundException catch (e) {
      // There are no recipes in the favourite list
      return [];
    } on FirebaseException catch (e) {
      throw DatabaseOperationException(
        "An error occurred while fetching the list of favourite recipes.",
        StackTrace.current,
      );
    } catch (e) {
      throw UnknownDatabaseException(
        "Unexpected error occurs while fetching the list of favourite recipes.",
        StackTrace.current,
      );
    }
  }

  /// Return a list of recipes of a given category
  /// - [category] a recipe category
  ///
  /// Throw [ArgumentError] if the input category is empty.
  /// Throw [ValidationException] if the input category doesn't exist.
  /// Throw [DatabaseOperationException] if a FirebaseException is thrown while fetching a recipe list by category
  /// Throw [UnknownDatabaseException] if an unexpected error occurs while fetching a recipe list by category
  Future<List<Recipe>> getRecipeListByCategory(String category) async {
    if (category.isEmpty) {
      throw ArgumentError("Invalid input. The input category is empty.");
    }

    if (!Recipe.categoryList.contains(category)) {
      throw ValidationException(
        "The required category doesn't exist.",
        StackTrace.current,
      );
    }

    try {
      return await _recipeDAO.getRecipeByCategory(category);
    } on DataNotFoundException catch (e) {
      // There are no recipes for this category
      return [];
    } on FirebaseException catch (e) {
      throw DatabaseOperationException(
        "An error occurred while fetching a recipe list by category.",
        StackTrace.current,
      );
    } catch (e) {
      throw UnknownDatabaseException(
        "Unexpected error occurs while fetching a recipe list by category.",
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

  /// Add the create, update, and delete operations for RecipeIngredient table to the input transaction.
  /// [oldRecipeIngredientList] a list of old RecipeIngredient items.
  /// [newRecipeIngredientList] a list of new RecipeIngredient items.
  /// [oldIngredients] a list of old Ingredient items.
  /// [newIngredients] a list of new Ingredient items
  /// [batch] a WriteBatch to add CRUD operations
  ///
  /// Returns two List objects, the first one contains the updated Ingredient while the second one contains the updated RecipeIngredient.
  ///
  /// Throw [ArgumentError] if any of the input list is empty or if the lenght of the Ingredient list doesn't match the corresponsind RecipeIngredient list
  /// Throw [ValidationException] if the new recipe's ingredient list contains duplicates.
  /// Throw [DatabaseOperationException] if the item to be deleted or updated doesn't exist in the database
  /// Throw [UnknownDatabaseException] if an unexpected error occurs during the retriving of the DocumentReference of a certain item.
  Future<(List<Ingredient>, List<RecipeIngredient>)> _updateRecipeIngredient(
    List<RecipeIngredient> oldRecipeIngredientList,
    List<RecipeIngredient> newRecipeIngredientList,
    List<Ingredient> oldIngredients,
    List<Ingredient> newIngredients,
    WriteBatch batch,
  ) async {
    if (oldRecipeIngredientList.isEmpty ||
        newRecipeIngredientList.isEmpty ||
        oldIngredients.isEmpty ||
        newIngredients.isEmpty ||
        oldIngredients.length != oldRecipeIngredientList.length ||
        newIngredients.length != newRecipeIngredientList.length) {
      throw ArgumentError(
        "Invalid input. The input contains empty lists or the lenght of the Ingredient list doesn't match the RecipeIngredient list.",
      );
    }

    Set<String> ingredientNames = {};
    for (Ingredient item in newIngredients) {
      if (ingredientNames.contains(item.name)) {
        throw ValidationException(
          "Each ingredient can only appear once in the recipe.",
          StackTrace.current,
        );
      }

      ingredientNames.add(item.name);
    }

    // Store ingredient names of the old recipe version
    List<String> oldIngredietNames = [];

    for (Ingredient item in oldIngredients) {
      oldIngredietNames.add(item.name);
    }

    List<RecipeIngredient> recipeingredientToDelete = [];
    List<RecipeIngredient> recipeingredientToUpdate = [];
    List<RecipeIngredient> recipeingredietToAdd = [];
    List<Ingredient> ingredientsToCreate = [];

    // ------- CHECK FOR CREATE OPERATIONS -------
    for (int i = 0; i < newRecipeIngredientList.length; i++) {
      if (newRecipeIngredientList[i].ingredientId.startsWith("tempID")) {
        if (oldIngredietNames.contains(newIngredients[i].name)) {
          // 1.1) If the ingredient is present in the old version of ingredient list --> Update its ID
          int ingredientIndex = oldIngredietNames.indexOf(
            newIngredients[i].name,
          );
          newRecipeIngredientList[i].ingredientId =
              oldIngredients[ingredientIndex].id;

          newIngredients[i].id = oldIngredients[ingredientIndex].id;
        } else {
          // 1.2) If the ingredient is not present in the old list --> CREATE RecipeIngredient

          try {
            // 1.3) If the new ingredients exist in the DB --> Update the ingredientId in the RecipeIngredient object
            final String id = await _ingredientDAO.getId(newIngredients[i]);
            newRecipeIngredientList[i].ingredientId = id;
            newIngredients[i].id = id;
          } on DataNotFoundException catch (e) {
            // 1.4) If the new ingredients doesn't exist in the DB --> CREATE INGREDIENT
            ingredientsToCreate.add(newIngredients[i]);
          }

          recipeingredietToAdd.add(newRecipeIngredientList[i]);
        }
      }
    }

    print("Old ingredient version:");
    for (int i = 0; i < oldRecipeIngredientList.length; i++) {
      print(
        "Ingredient ${oldIngredients[i].name}; ID: ${oldIngredients[i].id}; Quantity: ${oldRecipeIngredientList[i].quantity}; Unit: ${oldRecipeIngredientList[i].unitMeasurement}",
      );
    }

    print("New ingredient version:");
    for (int i = 0; i < newRecipeIngredientList.length; i++) {
      print(
        "Ingredient: ${newIngredients[i].name}; ID: ${newIngredients[i].id}; Quantity: ${newRecipeIngredientList[i].quantity}; Unit: ${newRecipeIngredientList[i].unitMeasurement}",
      );
    }

    // 2) ------- CHECK FOR UPDATE/DELETE OPERATIONS -------
    for (int i = 0; i < oldRecipeIngredientList.length; i++) {
      // Get old ingredient info
      RecipeIngredient oldItem = oldRecipeIngredientList[i];
      bool flag = false;

      for (int j = 0; j < newRecipeIngredientList.length; j++) {
        // Get new ingredient info
        RecipeIngredient newItem = newRecipeIngredientList[j];

        // If they ARE THE SAME ingredient check for any updates
        if (oldItem.ingredientId == newItem.ingredientId) {
          flag = true;

          // 2.1) If the ingredient quantity or unit measurement have been updated --> UPDATE
          if (oldItem.quantity != newItem.quantity ||
              oldItem.unitMeasurement != newItem.unitMeasurement) {
            recipeingredientToUpdate.add(newItem);
          }
          break;
        }
      }

      // 2.2) The old ingredient doesn't exist in the new recipe ingredient list --> DELETE
      if (!flag) {
        print(
          "Trovato RecipeIngredient da eliminare: Quantity: ${oldItem.quantity}, Unit: ${oldItem.unitMeasurement}",
        );
        recipeingredientToDelete.add(oldItem);
      }
    }

    // ------- PERFORME DELETE of RecipeIngredient -------
    for (RecipeIngredient item in recipeingredientToDelete) {
      try {
        DocumentReference itemRef = await _recipeIngredientDAO.getRef(item);
        _recipeIngredientDAO.deleteWithBatch(itemRef, batch);

        print(
          "Cancello RecipeIngredient: ID: ${itemRef.id}, Quantity: ${item.quantity}, Unit: ${item.unitMeasurement}",
        );
      } on DataNotFoundException catch (e) {
        throw DatabaseOperationException(e.message, e.stackTrace);
      } catch (e) {
        throw UnknownDatabaseException(
          "Unexpected error while deleting the RecipeIngredient item.",
          StackTrace.current,
        );
      }
    }

    // ------- PERFORME UPDATE of RecipeIngredient -------
    for (RecipeIngredient item in recipeingredientToUpdate) {
      try {
        DocumentReference itemRef = await _recipeIngredientDAO.getRef(item);
        _recipeIngredientDAO.updateWithBatch(item, itemRef, batch);
      } on DataNotFoundException catch (e) {
        throw DatabaseOperationException(e.message, e.stackTrace);
      } catch (e) {
        throw UnknownDatabaseException(
          "Unexpected error while updating the RecipeIngredient item",
          StackTrace.current,
        );
      }
    }

    // ------- PERFORME CREATE of Ingredient -------
    for (Ingredient item in ingredientsToCreate) {
      DocumentReference newIngredientRef = _ingredientDAO.newRef();

      // Update the corresponding RecipeIngredient (in create list)
      for (RecipeIngredient recipeIngredient in recipeingredietToAdd) {
        if (recipeIngredient.ingredientId == item.id) {
          recipeIngredient.ingredientId = newIngredientRef.id;
          item.id = newIngredientRef.id;
          break;
        }
      }

      print("Saving ${item.name}, ID: ${item.id}");
      _ingredientDAO.saveWithBatch(newIngredientRef, item, batch);
    }

    // ------- PERFORME CREATE of RecipeIngredient -------
    for (RecipeIngredient item in recipeingredietToAdd) {
      DocumentReference newRecipeIngredientRef = _recipeIngredientDAO.newRef();
      _recipeIngredientDAO.saveWithBatch(newRecipeIngredientRef, item, batch);
    }

    // ------- DEFINE UPDATED LISTS (to avoid other calls to the DB) -------
    List<Ingredient> updatedIngredients = [];
    List<RecipeIngredient> updatedRecipeIngredient = [];

    // 1) Insert all new items (create operations)
    for (RecipeIngredient newItem in recipeingredietToAdd) {
      bool flag = false;
      for (Ingredient createdIngredient in ingredientsToCreate) {
        // Add new Ingredient and new RecipeIngredient
        if (newItem.ingredientId == createdIngredient.id) {
          flag = true;
          updatedIngredients.add(createdIngredient);
          updatedRecipeIngredient.add(newItem);

          ingredientNames.remove(createdIngredient.name);
          break;
        }
      }

      if (!flag) {
        // 2) Add existing Ingredient (but a NEW ENTRY in RecipeIngredient)
        for (Ingredient existingIngredient in newIngredients) {
          if (newItem.ingredientId == existingIngredient.id) {
            updatedIngredients.add(existingIngredient);
            updatedRecipeIngredient.add(newItem);

            ingredientNames.remove(existingIngredient.name);
            break;
          }
        }
      }
    }

    // 3) Insert all updated items (update operations)
    for (RecipeIngredient updatedItem in recipeingredientToUpdate) {
      for (Ingredient updatedIngredient in newIngredients) {
        if (updatedItem.ingredientId == updatedIngredient.id) {
          updatedIngredients.add(updatedIngredient);
          updatedRecipeIngredient.add(updatedItem);

          ingredientNames.remove(updatedIngredient.name);
          break;
        }
      }
    }

    // 4) Insert unchanged items
    for (String item in ingredientNames) {
      for (int i = 0; i < newIngredients.length; i++) {
        if (item == newIngredients[i].name) {
          updatedIngredients.add(newIngredients[i]);
          updatedRecipeIngredient.add(newRecipeIngredientList[i]);
          break;
        }
      }
    }

    return (updatedIngredients, updatedRecipeIngredient);
  }

  /// Add CRUD operations to the input batch to update, delete or create a RecipeStep based on oldStepList and newStepList.
  /// [oldStepList] a list of old RecipeStep objects.
  /// [newStepList] a list of new RecipeStep objects.
  /// [batch] a WriteBatch to add CRUD operations.
  ///
  /// Throw [ArgumentError] if any of the input list is empty.
  /// Throw [DatabaseOperationException] if the item to be deleted or updated doesn't exist in the database.
  /// Throw [UnknownDatabaseException] if an unexpected error occurs during the retriving of the DocumentReference of a certain item.
  Future<void> _updateStep(
    double recipeDuration,
    List<RecipeStep> oldStepList,
    List<RecipeStep> newStepList,
    WriteBatch batch,
  ) async {
    if (oldStepList.isEmpty || newStepList.isEmpty) {
      throw ArgumentError("Invalid input. The input lists can't be empty.");
    }

    // Check whether the total step duration match the recipe duration --> ERROR
    double totalStepDuration = 0.0;

    newStepList.forEach((step) {
      if (step.duration != null) {
        double stepDuration = (step.durationUnit! == "hour")
            ? step.duration! * 60
            : (step.durationUnit! == "minute")
            ? step.duration!
            : step.duration! / 60;

        totalStepDuration += stepDuration;
      }
    });

    if (recipeDuration != totalStepDuration) {
      throw ValidationException(
        "Total step duration doesn't match recipe duration!",
        StackTrace.current,
      );
    }

    List<RecipeStep> stepToDelete = [];
    // Map old step order - new RecipeStep e.g.: {0:new_object, 5:new_object}
    Map<int, RecipeStep> stepToUpdate = {};
    List<RecipeStep> stepToAdd = [];

    final int numStepDiff = newStepList.length - oldStepList.length;

    // 1) Check for UPDATE operations (explore only the common part of the two lists)
    int i = 0;
    while (i < newStepList.length && i < oldStepList.length) {
      bool flag = oldStepList[i] == newStepList[i];
      if (!flag) {
        stepToUpdate[oldStepList[i].stepOrder] = newStepList[i];
      }
      i++;
    }

    if (numStepDiff > 0) {
      // 2) If the newStepList has more steps --> CREATE
      for (i = oldStepList.length; i < newStepList.length; i++) {
        stepToAdd.add(newStepList[i]);
      }
    } else if (numStepDiff < 0) {
      // 3) If the newStepList has less steps --> DELETE the old steps
      for (i = newStepList.length; i < oldStepList.length; i++) {
        stepToDelete.add(oldStepList[i]);
      }
    }

    print("Old recipe step version:");
    for (RecipeStep step in oldStepList) {
      print(
        "Step Order: ${step.stepOrder}; Description: ${step.description}; Duration: ${step.duration}; Unit: ${step.durationUnit}",
      );
    }

    print("New recipe step list");
    for (RecipeStep step in newStepList) {
      print(
        "Step Order: ${step.stepOrder}; Description: ${step.description}; Duration: ${step.duration}; Unit: ${step.durationUnit}",
      );
    }

    // 4) DELETE operations
    for (RecipeStep step in stepToDelete) {
      try {
        DocumentReference ref = await _recipeStepDAO.getRef(step);
        _recipeStepDAO.deleteWithBatch(ref, batch);
      } on DataNotFoundException catch (e) {
        throw DatabaseOperationException(e.message, e.stackTrace);
      } catch (e) {
        throw UnknownDatabaseException(
          "Unexpected error while deleting the RecipeStep item.",
          StackTrace.current,
        );
      }
    }

    // 5) UPDATE operations
    for (MapEntry<int, RecipeStep> entry in stepToUpdate.entries) {
      try {
        // Get the reference of the old version
        //RecipeStep oldVersion = entry.value.clone();
        //oldVersion.stepOrder = entry.key;
        DocumentReference ref = await _recipeStepDAO.getRef(entry.value);

        // Add the update operation for this RecipeStep to the WriteBatch
        _recipeStepDAO.updateWithBatch(entry.value, ref, batch);
      } on DataNotFoundException catch (e) {
        throw DatabaseOperationException(e.message, e.stackTrace);
      } catch (e) {
        throw UnknownDatabaseException(
          "Unexpected error while updating the RecipeStep item",
          StackTrace.current,
        );
      }
    }

    // 6) CRETE operations
    for (RecipeStep step in stepToAdd) {
      DocumentReference ref = _recipeStepDAO.newRef();
      _recipeStepDAO.saveWithBatch(ref, step, batch);
    }
  }

  /// Update the input Recipe using a WriteBatch to performe a transaction.
  /// [newRecipe] the Recipe to be updated.
  /// [oldRecipeIngredientList] a list of old RecipeIngredient objects.
  /// [newRecipeIngredientList] a list of new RecipeIngredient objects.
  /// [oldIngredients] a list of old Ingredient objects.
  /// [newIngredients] a list of new Ingredient objects.
  /// [oldStepList] a list of old RecipeStep objects.
  /// [newStepList] a list of new RecipeStep objects.
  ///
  /// Throw [ArgumentError] if any of the input list is empty or the length of Ingredient list doesn't match the length of the corresponding RecipeIngredient list.
  /// Throw [ValidationException] if the new recipe's duration doesn't match the total step duration, or if the new recipe's ingredient list contains duplicates.
  /// Throw [DatabaseOperationException] if an error occurs during the update of the input recipe.
  /// Throw [UnknownDatabaseException] if an unexpected error occurs during the update of the input recipe.
  Future<RecipeAggregate> updateRecipe(
    Recipe newRecipe,
    List<RecipeIngredient> oldRecipeIngredientList,
    List<RecipeIngredient> newRecipeIngredientList,
    List<Ingredient> oldIngredients,
    List<Ingredient> newIngredients,
    List<RecipeStep> oldStepList,
    List<RecipeStep> newStepList,
  ) async {
    // Check for empty list --> ERROR
    if (oldRecipeIngredientList.isEmpty ||
        newRecipeIngredientList.isEmpty ||
        oldIngredients.isEmpty ||
        oldIngredients.length != oldRecipeIngredientList.length ||
        newIngredients.length != newRecipeIngredientList.length ||
        newIngredients.isEmpty ||
        oldStepList.isEmpty ||
        newStepList.isEmpty) {
      throw ArgumentError(
        "Invalid input. The input contains empty lists or the lenght of the Ingredient list doesn't match the corresponding RecipeIngredient list.",
      );
    }

    // Get the Firestore bacth to perform a transaction
    final WriteBatch batch = FirebaseFirestore.instance.batch();

    // --------------------- RECIPE ---------------------
    DocumentReference recipeRef = _recipeDAO.getRef(newRecipe);
    _recipeDAO.updateWithBatch(recipeRef, newRecipe, batch);

    // --------------------- INGREDIENT ---------------------
    final (
      updatedIngredients,
      updatedRecipeIngredient,
    ) = await _updateRecipeIngredient(
      oldRecipeIngredientList,
      newRecipeIngredientList,
      oldIngredients,
      newIngredients,
      batch,
    );

    // --------------------- STEP ---------------------
    await _updateStep(
      newRecipe.duration.toDouble(),
      oldStepList,
      newStepList,
      batch,
    );

    try {
      await batch.commit();

      return RecipeAggregate(
        recipe: newRecipe,
        ingredients: updatedIngredients,
        recipeIngredients: updatedRecipeIngredient,
        steps: newStepList,
      );
    } on FirebaseException catch (e, st) {
      throw DatabaseOperationException(
        "An error occurred during the transaction. Failed to update the input recipe.",
        st,
      );
    } catch (e, st) {
      throw UnknownDatabaseException(
        "Unexpected error while updating the input recipe.",
        st,
      );
    }
  }
}
