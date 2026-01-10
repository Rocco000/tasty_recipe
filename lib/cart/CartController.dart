import 'package:tasty_recipe/cart/models/entities/CartItem.dart';
import 'package:tasty_recipe/cart/services/CartService.dart';
import 'package:tasty_recipe/cart/CartItemListResult.dart';
import 'package:tasty_recipe/Utils/DatabaseOperationException.dart';

class CartController {
  final CartService _service = CartService();

  /// Return all the ingredients in the user's cart
  Future<CartItemListResult> getAllCartItems(String user) async {
    if (user.isEmpty) {
      return CartItemListError("Something went wrong. Try again.");
    }

    try {
      final (items, ingredients) = await _service.getAllCartItemsByUser(user);

      return CartItemListSuccess(items, ingredients);
    } on ArgumentError catch (e) {
      return CartItemListError("Something went wrong. Try again.");
    } on DatabaseOperationException catch (e) {
      String msg = "";
      if (e.message == "Empty cart") {
        msg = "You cart is empty. Start adding ingredients!";
      } else {
        msg = "We couldn't load your cart right now. Please try again later.";
      }

      return CartItemListError(msg);
    }
  }

  /// Remove the input [item] using the Service object.
  /// - [item] a CartItem object to be deleted.
  ///
  /// Return true if the input [item] is deleted, false otherwise.
  Future<bool> removeItemFromCart(CartItem item) async {
    try {
      await _service.removeItemFromCart(item);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove the input [items] using the Service object.
  /// - [items] a list of CartItem objects to be deleted.
  ///
  /// Return true if the input [items] is deleted, false otherwise.
  Future<bool> removeItemsFromCart(List<CartItem> items) async {
    try {
      await _service.removeItemsFromCart(items);

      return true;
    } catch (e) {
      return false;
    }
  }
}
