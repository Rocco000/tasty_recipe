import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/cart/models/entities/CartItem.dart';
import 'package:tasty_recipe/Services/DAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';

class CartItemDAO extends DAO<CartItem> {
  final _collection = FirebaseFirestore.instance.collection("CartItem");

  Future<DocumentReference> getRef(CartItem item) async {
    String id = await getId(item);

    return _collection.doc(id);
  }

  @override
  Future<void> delete(CartItem item) async {
    final querySnapshot = await _collection
        .where("userId", isEqualTo: item.userMail)
        .where("ingredientId", isEqualTo: item.ingredientId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException(
        "The input item doesn't exist in the user's cart",
        StackTrace.current,
      );
    }

    await _collection.doc(querySnapshot.docs[0].id).delete();
  }

  /// Add a delete operation of a CartItem in the input batch.
  /// - [itemRef] the DocumentReference of the CartItem to be deleted.
  /// - [batch] a WriteBatch.
  void deleteWithBatch(DocumentReference itemRef, WriteBatch batch) {
    batch.delete(itemRef);
  }

  @override
  Future<List<CartItem>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<String> getId(CartItem item) async {
    final querySnapshot = await _collection
        .where("userId", isEqualTo: item.userMail)
        .where("ingredientId", isEqualTo: item.ingredientId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException("CartItem not found", StackTrace.current);
    }

    return querySnapshot.docs.first.id;
  }

  @override
  Future<CartItem> retrieve(CartItem item) {
    // TODO: implement retrieve
    throw UnimplementedError();
  }

  /// Return all items in the user's cart
  /// - [userId] the user ID
  ///
  /// Return a list of CartItem
  ///
  /// Throw:
  /// - [ArgumentError] if the input [userId] is empty.
  /// - [DataNotFoundException] if there are no items in the user's cart.
  Future<List<CartItem>> getCartItemsByUser(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError("Invalid input. The user ID can't be empty.");
    }

    final querySnapshot = await _collection
        .where("userId", isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException("Empty cart", StackTrace.current);
    }

    return querySnapshot.docs.map((doc) {
      final itemData = doc.data();
      return CartItem(
        itemData["userId"] as String,
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
        .add({
          "ingredientId": newItem.ingredientId,
          "userId": newItem.userMail,
        });

    return newCartItemRef.id;
  }

  @override
  Future<bool> exists(CartItem item) async {
    if (item == null) throw ArgumentError("Invalid input");

    final querySnapshot = await FirebaseFirestore.instance
        .collection("CartItem")
        .where("userdId", isEqualTo: item.userMail)
        .where("ingredientId", isEqualTo: item.ingredientId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}
