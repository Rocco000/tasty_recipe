import 'package:tasty_recipe/Models/CartItem.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Services/CartItemDAO.dart';
import 'package:tasty_recipe/Services/IngredientDAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';

class CartController {
  final CartItemDAO _cartItemDAO = CartItemDAO();
  final IngredientDAO _ingredientDAO = IngredientDAO();

  Future<(List<CartItem>, List<Ingredient>)> getAllCartItems() async {
    try {
      // 1) Get cart items
      final List<CartItem> items = await _cartItemDAO.getCartItemsByUser(
        "io-prova",
      );

      // 2) Get the ingredient names
      List<Ingredient> ingredients = [];
      for (CartItem item in items) {
        try {
          final Ingredient ingredient = await _ingredientDAO.getIngredientById(
            item.ingredientId,
          );
          ingredients.add(ingredient);
        } on DataNotFoundException catch (e) {
          // Unlikely event - the ingredient with this ID doesn't exist
          throw Exception("Something went wrong. Try again.");
        }
      }

      return (items, ingredients);
    } on DataNotFoundException catch (e) {
      throw Exception(e.message);
    } on Exception catch (e) {
      throw Exception("Something went wrong. Try again.");
    }
  }

  Future<bool> removeItemFromCart(CartItem item) async {
    try {
      await _cartItemDAO.delete(item);

      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<bool> removeItemsFromCart(List<CartItem> items) async {
    for (CartItem item in items) {
      bool result = await removeItemFromCart(item);
      if (!result) {
        print("Unable to remove item!");
        return false;
      }
    }

    return true;
  }
}
