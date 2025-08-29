import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/Models/CartItem.dart';
import 'package:tasty_recipe/Services/DAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';

class CartItemDAO extends DAO<CartItem> {
  @override
  Future<void> delete(CartItem item) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("CartItem")
        .where("userId", isEqualTo: "io-prova")
        .where("ingredientId", isEqualTo: item.ingredientId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException(
        "The item is not in the cart",
        StackTrace.current,
      );
    }

    await FirebaseFirestore.instance
        .collection("CartItem")
        .doc(querySnapshot.docs[0].id)
        .delete();
  }

  @override
  Future<List<CartItem>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<String> getId(CartItem item) {
    // TODO: implement getId
    throw UnimplementedError();
  }

  @override
  Future<CartItem> retrieve(CartItem item) {
    // TODO: implement retrieve
    throw UnimplementedError();
  }

  Future<List<CartItem>> getCartItemsByUser(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError("Invalid input");
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection("CartItem")
        .where("userId", isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException("Empty cart", StackTrace.current);
    }

    return querySnapshot.docs.map((doc) {
      final itemData = doc.data();
      return CartItem(
        "prova@gmail.com",
        itemData["ingredientId"] as String,
        false,
      );
    }).toList();
  }

  @override
  Future<String> save(CartItem newItem) async {
    if (newItem == null) throw ArgumentError("Invalid input");

    final newCartItemRef = await FirebaseFirestore.instance
        .collection("CartItem")
        .add({"ingredientId": newItem.ingredientId, "userId": "io-prova"});

    return newCartItemRef.id;
  }

  @override
  Future<bool> exists(CartItem item) async {
    if (item == null) throw ArgumentError("Invalid input");

    final querySnapshot = await FirebaseFirestore.instance
        .collection("CartItem")
        .where("userdId", isEqualTo: "io-prova")
        .where("ingredientId", isEqualTo: item.ingredientId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}
