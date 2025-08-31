import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/Models/CartItem.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Services/CartItemDAO.dart';
import 'package:tasty_recipe/Services/IngredientDAO.dart';
import 'package:tasty_recipe/Services/RecipeService.dart';
import 'package:tasty_recipe/Utils/DatabaseOperationException.dart';
import 'package:tasty_recipe/Utils/RecipeDetailsResult.dart';
import 'package:tasty_recipe/Utils/UnknownDatabaseException.dart';

class RecipeDetailsController {
  final RecipeService _service = RecipeService();
  final IngredientDAO _ingredientDAO = IngredientDAO();
  final CartItemDAO _cartItemDAO = CartItemDAO();

  Future<RecipeDetailsResult> loadFullRecipe(String recipeId) async {
    if (recipeId.isEmpty) {
      return RecipeDetailsError("Invalid input. Try again.");
    }

    try {
      // 1) Get recipe general info
      final Recipe recipe = await _service.getRecipe(recipeId);

      // 2) Get ingredient info (quantity, etc.)
      final List<RecipeIngredient> recipeIngredientList = await _service
          .getRecipeIngredients(recipeId);

      final List<String> ingredientIdList = [];
      for (RecipeIngredient item in recipeIngredientList) {
        ingredientIdList.add(item.ingredientId);
      }

      // 3) Get ingredient names
      final List<Ingredient> ingredientList = await _service.getIngredients(
        ingredientIdList,
      );

      // 4) Get recipe steps
      final List<RecipeStep> recipeStepList = await _service.getRecipeSteps(
        recipeId,
      );

      return RecipeDetailsSuccess(
        recipe,
        recipeIngredientList,
        ingredientList,
        recipeStepList,
      );
    } on ArgumentError catch (e) {
      return RecipeDetailsError("Invalid input. Try again.");
    } on DatabaseOperationException catch (e) {
      return RecipeDetailsError("Unable to load that recipe. Try again.");
    } on UnknownDatabaseException catch (e) {
      return RecipeDetailsError("Something went wrong. Try again.");
    }
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
