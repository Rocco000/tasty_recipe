import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Services/IngredientDAO.dart';
import 'package:tasty_recipe/Services/RecipeDAO.dart';
import 'package:tasty_recipe/Services/RecipeIngredientDAO.dart';
import 'package:tasty_recipe/Services/RecipeStepDAO.dart';
import 'package:tasty_recipe/Utils/InvalidFieldException.dart';

class RecipeCreationController extends ChangeNotifier {
  final RecipeDAO _recipeDAO = RecipeDAO();
  final RecipeIngredientDAO _recipeIngredientDAO = RecipeIngredientDAO();
  final RecipeStepDAO _recipeStepDAO = RecipeStepDAO();
  final IngredientDAO _ingredientDAO = IngredientDAO();

  Recipe? _recipe;
  List<Ingredient> _ingredientList = [];
  List<RecipeStep> _recipeStepList = [];
  List<RecipeIngredient> _recipeIngredientList = [];

  /// Temporarly store the recipe general info
  /// - [recipeName]: the recipe name.
  /// - [duration]: the recipe duration in minutes.
  /// - [difficulty]: the recipe difficulty, range [0, 4].
  /// - [servings]: the recipe servings.
  /// - [category]: the recipe category (Breakfast, First Course, Second Course, Snack, Dessert).
  /// - [tags]: a list of tags (Vegan, Gluten Free, Lactose Free, Fit).
  ///
  /// Throws a [InvalidFieldException] if the input is not valid.
  void setGeneralInfo(
    String recipeName,
    int duration,
    int difficulty,
    int servings,
    String category,
    List<String> tags,
  ) {
    if (recipeName == null || recipeName.trim().isEmpty) {
      throw InvalidFieldException("recipeName", "Recipe name cannot be empty");
    }

    if (duration < 1) {
      throw InvalidFieldException(
        "recipeDuration",
        "Duration must be greater than zero.",
      );
    }

    if (difficulty < 0 || difficulty > 4) {
      throw InvalidFieldException(
        "recipeDifficulty",
        "Invalid recipe difficulty.",
      );
    }

    if (servings < 0) {
      throw InvalidFieldException(
        "recipeServing",
        "Recipe servings must be greater than zero.",
      );
    }

    if (category == null ||
        category.isEmpty ||
        !Recipe.categoryList.contains(category)) {
      throw InvalidFieldException(
        "recipeCategory",
        "Recipe category cannot be empty.",
      );
    }

    if (tags.isNotEmpty) {
      for (String tag in tags) {
        if (!Recipe.recipeTags.contains(tag))
          throw InvalidFieldException("recipeTag", "Invalid recipe tag.");
      }
    }

    _recipe = Recipe(
      null,
      "0",
      recipeName.trim(),
      difficulty,
      duration,
      servings,
      category,
      (tags.isNotEmpty) ? tags : [],
      false,
      "prova!!!!!",
    );
    print(
      "Name: ${_recipe!.name}, Difficulty: ${_recipe!.difficulty}, Duration: ${_recipe!.duration}, Servings: ${_recipe!.servings}, Category: ${_recipe!.category}, Tags: ${_recipe!.tags}",
    );
  }

  /// Clear the temporary recipe general info stored in Recipe object
  void clearRecipe() {
    _recipe = null;
  }

  /// Temporarly store an ingredient and its corresponding quantity for that recipe
  /// - [ingredientName]: the ingredient name.
  /// - [ingredientQuantity]: the ingredient quantity for that recipe.
  /// - [unitMeasurement]: the unit of ingredient quantity.
  ///
  /// Throws a [InvalidFieldException] if the input is not valid.
  void addIngredient(
    String ingredientName,
    double ingredientQuantity,
    String unitMeasurement,
  ) {
    if (ingredientName == null || ingredientName.trim().isEmpty) {
      clearIngredients();
      throw InvalidFieldException(
        "ingredientName",
        "Ingredient name cannot be empty.",
      );
    }

    if (ingredientQuantity <= 0) {
      clearIngredients();
      throw InvalidFieldException(
        "ingredientQuantity",
        "Quantity must be greater than zero.",
      );
    }

    if (unitMeasurement == null ||
        unitMeasurement.isEmpty ||
        !RecipeIngredient.units.contains(unitMeasurement)) {
      clearIngredients();
      throw InvalidFieldException(
        "unitMeasurement",
        "Invalid measurement unit.",
      );
    }

    _ingredientList.add(Ingredient("0", ingredientName.toLowerCase().trim()));

    _recipeIngredientList.add(
      RecipeIngredient("0", "0", ingredientQuantity, unitMeasurement),
    );
    print("Added $ingredientName");
  }

  /// Clear the temporary ingredient lists: [_ingredientList] and [_recipeIngredientList]
  void clearIngredients() {
    _ingredientList.clear();
    _recipeIngredientList.clear();
  }

  /// Temporarly store a recipe step
  /// - [stepOrder]: the step order in the sequence.
  /// - [stepDescription]: the step description.
  /// - [stepDuration]: the step duration expressed in [stepDurationUnit]. It is an optional parameter.
  /// - [stepDurationUnit]: the unit of the step duration (hours, minutes, seconds). It is an optional parameter.
  ///
  /// Throws a [InvalidFieldException] if the input is not valid.
  void addStep(
    int stepOrder,
    String stepDescription, {
    double? stepDuration,
    String? stepDurationUnit,
  }) {
    if (stepOrder < 0) throw ArgumentError("Invalid input");

    if (stepDescription == null || stepDescription.trim().isEmpty) {
      throw InvalidFieldException(
        "stepDescription",
        "Step description cannot be empty.",
      );
    }

    if ((stepDuration == null && stepDurationUnit != null) ||
        (stepDuration != null && stepDurationUnit == null)) {
      throw Exception("Invalid input");
    }

    if (stepDuration != null && stepDuration < 1) {
      throw InvalidFieldException(
        "stepDuration",
        "Step duration must be greater than 0.",
      );
    }

    if (stepDurationUnit != null &&
        (stepDurationUnit.isEmpty ||
            !RecipeStep.timeUnits.contains(stepDurationUnit))) {
      throw InvalidFieldException(
        "stepDurationUnit",
        "Invalid step duration unit.",
      );
    }

    _recipeStepList.add(
      RecipeStep(
        "0",
        stepOrder,
        stepDescription.trim(),
        stepDuration,
        stepDurationUnit,
      ),
    );
  }

  /// Clear the temporary step list [_recipeStepList].
  void clearSteps() {
    _recipeStepList.clear();
  }

  /// Create a new recipe in the DB
  Future<void> createNewRecipe() async {
    // Check whether the temporary data is properly stored
    if (_recipe == null ||
        _ingredientList.isEmpty ||
        _recipeIngredientList.isEmpty ||
        _recipeStepList.isEmpty) {
      clearSteps();
      throw Exception("Something went wrong. Try again");
    }

    // Check whether the total step duration match the recipe duration
    double totalStepDuration = 0.0;

    _recipeStepList.forEach((step) {
      if (step.duration != null) {
        double stepDuration = (step.durationUnit! == "hour")
            ? step.duration! * 60
            : (step.durationUnit! == "minute")
            ? step.duration!
            : step.duration! / 60;

        totalStepDuration += stepDuration;
      }
    });

    if (_recipe!.duration != totalStepDuration.toInt()) {
      clearSteps();
      throw Exception("Total step duration doesn't match recipe duration");
    }

    try {
      // 1) Store the new recipe
      String recipeId = await _recipeDAO.save(_recipe!);

      // 2.1) Get the ingredient ID or eventually create a new one
      for (int i = 0; i < _ingredientList.length; i++) {
        String ingredientId;
        try {
          // Get the ID of an EXISTING ingredient
          ingredientId = await _ingredientDAO.getId(_ingredientList[i]);
        } on Exception catch (e) {
          // Crete a NEW ingredient
          ingredientId = await _ingredientDAO.save(_ingredientList[i]);
        }

        // 2.2) Update the RecipeIngredient keys
        _recipeIngredientList[i].recipeId = recipeId;
        _recipeIngredientList[i].ingredientId = ingredientId;

        // 2.3)  Store the RecipeIngredient items
        _recipeIngredientDAO.save(_recipeIngredientList[i]);
      }

      // 3) Store recipe steps
      for (RecipeStep step in _recipeStepList) {
        // Update foreign key
        step.recipeId = recipeId;
        _recipeStepDAO.save(step);
      }
    } on ArgumentError catch (e) {
      clearSteps();
      throw Exception("Provide a valid input");
    } on FirebaseException catch (e) {
      clearSteps();
      throw Exception("Something went wrong. Try again.");
    }

    print("Stored all data!");
    notifyListeners();
  }

  /// Clear all temporary data
  void clear() {
    _recipe = null;
    _ingredientList.clear();
    _recipeIngredientList.clear();
    _recipeStepList.clear();
  }
}
