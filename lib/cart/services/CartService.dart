import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/cart/models/entities/CartItem.dart';
import 'package:tasty_recipe/recipe/models/entities/Ingredient.dart';
import 'package:tasty_recipe/cart/models/dao/CartItemDAO.dart';
import 'package:tasty_recipe/recipe/models/dao/IngredientDAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';
import 'package:tasty_recipe/Utils/DatabaseOperationException.dart';
import 'package:tasty_recipe/Utils/UnknownDatabaseException.dart';
import 'package:tasty_recipe/Utils/ValidationException.dart';

class CartService {
  final CartItemDAO _cartDAO = CartItemDAO();
  final IngredientDAO _ingredientDAO = IngredientDAO();

  /// Add the input ingredient to the user's cart.
  /// - [user] the user ID
  /// - [item] an Ingredient to add to the user's cart.
  ///
  /// Throw an [ArgumentError] if the user ID is empty.
  /// Throw a [ValidationException] if the input Ingredient doesn't exist or it is already in the user's cart.
  /// Throw a [DatabaseOperationException] if a FirebaseException is detected.
  /// Throw a [UnknownDatabaseException] if an unexpected error  is detected.
  Future<void> addIngredientToCart(String user, Ingredient item) async {
    if (user.isEmpty) {
      throw ArgumentError("Invalid input. The user can't be empty.");
    }

    try {
      // 1) Check if the ingredient exists
      final bool ingredientExists = await _ingredientDAO.exists(item);
      if (!ingredientExists) {
        throw ValidationException(
          "The input ingredient doesn't exist!",
          StackTrace.current,
        );
      }

      // 2) Check if the ingredient is already added to the cart
      final newCartItem = CartItem(user, item.id, false);
      final bool isPresent = await _cartDAO.exists(newCartItem);
      if (isPresent) {
        throw ValidationException(
          "The input ingredient is already in the user's cart.",
          StackTrace.current,
        );
      }

      // 3) Add the input ingredient in the user's cart
      await _cartDAO.save(newCartItem);
    } on FirebaseException catch (e) {
      throw DatabaseOperationException(
        "An error occurred while adding an ingredient to the user's cart.",
        StackTrace.current,
      );
    } catch (e) {
      throw UnknownDatabaseException(
        "Unexpected error occurred while adding an ingredient to the user's cart.",
        StackTrace.current,
      );
    }
  }

  /// Return all items in the user's cart from the database using the DAO class.
  /// - [user] the user ID.
  ///
  /// Return a tuple containing a List of CartItem and a List of Ingredient.
  ///
  /// Throw:
  /// - [ArgumentError] if the input [user] is empty.
  /// - [DatabaseOperationException] if the user's cart is empty or get an empty document.
  Future<(List<CartItem>, List<Ingredient>)> getAllCartItemsByUser(
    String user,
  ) async {
    if (user.isEmpty) {
      throw ArgumentError("Invalid input. The user ID can't be empty!");
    }

    try {
      // 1) Get cart items
      final List<CartItem> items = await _cartDAO.getCartItemsByUser(user);

      // 2) Get the ingredient names
      List<Ingredient> ingredients = [];
      for (CartItem item in items) {
        final Ingredient ingredient = await _ingredientDAO.getIngredientById(
          item.ingredientId,
        );
        ingredients.add(ingredient);
      }

      return (items, ingredients);
    } on ArgumentError catch (e) {
      // Unlikely event
      rethrow;
    } on DataNotFoundException catch (e) {
      throw DatabaseOperationException(e.message, e.stackTrace);
    } on DatabaseOperationException catch (e) {
      rethrow;
    }
  }

  /// Delete the input [item] from the user's cart in the database using the DAO class.
  /// - [item] a CartItem object to be deleted.
  ///
  /// Throw:
  /// - [DatabaseOperationException] if the input [item] doesn't exist or a FirebaseException is detected.
  /// - [UnknownDatabaseException] if an unexpected error occurs while deletig the input [item].
  Future<void> removeItemFromCart(CartItem item) async {
    try {
      await _cartDAO.delete(item);
    } on DataNotFoundException catch (e) {
      throw DatabaseOperationException(e.message, e.stackTrace);
    } on FirebaseException catch (e) {
      throw DatabaseOperationException(
        "An error occurs while deleting a CartItem from user's cart.",
        StackTrace.current,
      );
    } catch (e) {
      throw UnknownDatabaseException(
        "Unexpected error occurs while deleting a CartItem from the user's cart.",
        StackTrace.current,
      );
    }
  }

  /// Remove the input [items] from the user's cart in the database using the DAO class.
  /// - [items] a list of CartItem to be removed from the user's cart.
  ///
  /// Throw:
  /// - [DatabaseOperationException] if an item doesn't exist or an error occurs during the transaction.
  /// - [UnknownDatabaseException] if an unexpected error occurs during the transaction.
  Future<void> removeItemsFromCart(List<CartItem> items) async {
    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      for (CartItem item in items) {
        // Get document reference
        final DocumentReference itemRef = await _cartDAO.getRef(item);

        // Add the delete operation to the transaction
        _cartDAO.deleteWithBatch(itemRef, batch);
      }

      // Perform the transaction
      await batch.commit();
    } on DataNotFoundException catch (e) {
      throw DatabaseOperationException(e.message, StackTrace.current);
    } on FirebaseException catch (e, st) {
      throw DatabaseOperationException(
        "An error occurred during the transaction. Failed to delete items from the user's cart.",
        st,
      );
    } catch (e, st) {
      throw UnknownDatabaseException(
        "Unexpected error while deleting items from the user's cart.",
        st,
      );
    }
  }
}
