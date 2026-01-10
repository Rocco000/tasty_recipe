import 'package:tasty_recipe/cart/models/entities/CartItem.dart';
import 'package:tasty_recipe/recipe/models/entities/Ingredient.dart';

sealed class CartItemListResult {}

class CartItemListSuccess extends CartItemListResult {
  final List<CartItem> items;
  final List<Ingredient> ingredients;

  CartItemListSuccess(this.items, this.ingredients);
}

class CartItemListError extends CartItemListResult {
  final String message;

  CartItemListError(this.message);
}
