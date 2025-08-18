import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/Models/CartItem.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Services/CartItemDAO.dart';
import 'package:tasty_recipe/Services/IngredientDAO.dart';
import 'package:tasty_recipe/Services/RecipeDAO.dart';
import 'package:tasty_recipe/Services/RecipeIngredientDAO.dart';
import 'package:tasty_recipe/Services/RecipeStepDAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';

class RecipeDetailsController {
  final RecipeDAO _recipeDAO = RecipeDAO();
  final RecipeStepDAO _recipeStepDAO = RecipeStepDAO();
  final IngredientDAO _ingredientDAO = IngredientDAO();
  final RecipeIngredientDAO _recipeIngredientDAO = RecipeIngredientDAO();
  final CartItemDAO _cartItemDAO = CartItemDAO();

  Future<(Recipe, List<RecipeIngredient>, List<Ingredient>, List<RecipeStep>)>
  loadFullRecipe(String recipeId) async {
    try {
      // 1) Get recipe general info
      final Recipe recipe = await getRecipeDetails(recipeId);

      // 2) Get ingredient info (quantity, etc.)
      final List<RecipeIngredient> recipeIngredientList =
          await getRecipeIngredients(recipeId);

      final List<String> ingredientIdList = [];
      for (RecipeIngredient item in recipeIngredientList) {
        ingredientIdList.add(item.ingredientId);
      }

      // 3) Get ingredient names
      final List<Ingredient> ingredientList = await getIngredients(
        ingredientIdList,
      );
      // 4) Get recipe steps
      final List<RecipeStep> recipeStepList = await getRecipeSteps(recipeId);

      return (recipe, recipeIngredientList, ingredientList, recipeStepList);
    } on ArgumentError catch (e) {
      throw Exception("Invalid input! Try again.");
    } on DataNotFoundException catch (e) {
      print(e.stackTrace);
      throw Exception("Data not found! Try again.");
    } on FirebaseException catch (e) {
      print(e.stackTrace);
      throw Exception("Something went wrong. Try again.");
    } catch (e) {
      print(e);
      throw Exception("Something went wrong. Try again.");
    }
  }

  Future<Recipe> getRecipeDetails(String id) async {
    if (id.isEmpty) {
      throw ArgumentError("Invalid input! The input string is empty.");
    }

    return await _recipeDAO.getRecipeById(id);
  }

  Future<List<Ingredient>> getIngredients(List<String> ingredientIds) async {
    if (ingredientIds.isEmpty) {
      throw ArgumentError("Invalid input! The input list is empty.");
    }

    final List<Ingredient> ingredients = [];

    for (String id in ingredientIds) {
      final Ingredient ingredient = await _ingredientDAO.getIngredientById(id);
      ingredients.add(ingredient);
    }

    return ingredients;
  }

  Future<List<RecipeIngredient>> getRecipeIngredients(String recipeId) async {
    if (recipeId.isEmpty) {
      throw ArgumentError("Invalid input! The input string is empty.");
    }

    return await _recipeIngredientDAO.getRecipeIngredientsByRecipeId(recipeId);
  }

  Future<List<RecipeStep>> getRecipeSteps(String recipeId) async {
    if (recipeId.isEmpty) {
      throw ArgumentError("Invalid input! The input string is empty.");
    }

    return await _recipeStepDAO.getAllRecipeStepById(recipeId);
  }

  Future<bool> updateRecipeFavoriteState(Recipe recipe) async {
    try {
      await _recipeDAO.updateFavoriteState(recipe, !recipe.isFavorite);
      return true;
    } on DataNotFoundException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addIngredientToCart(Ingredient ingredient) async {
    final bool ingredientExists = await _ingredientDAO.exists(ingredient);

    if (ingredientExists) {
      final newCartItem = CartItem(
        "prova@gmail.com",
        ingredient.id,
        10,
        "gr",
        false,
      );

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
      final batch = FirebaseFirestore.instance.batch();
      // Add delete operations to the transaction
      await _recipeStepDAO.deleteByRecipeId(recipe.id, batch);
      await _recipeIngredientDAO.deleteByRecipeId(recipe.id, batch);
      await _recipeDAO.deleteByRecipeId(recipe.id, batch);

      // Perform the transaction
      await batch.commit();

      return true;
    } on DataNotFoundException catch (e, st) {
      return false;
    } catch (e, st) {
      return false;
    }
  }
}
