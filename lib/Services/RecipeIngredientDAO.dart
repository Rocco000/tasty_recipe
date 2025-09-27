import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Services/DAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';
import 'package:tasty_recipe/Utils/UnknownDatabaseException.dart';

class RecipeIngredientDAO extends DAO<RecipeIngredient> {
  final _collection = FirebaseFirestore.instance.collection("RecipeIngredient");

  /// New document reference
  DocumentReference newRef() {
    return _collection.doc(); // auto-generates ID
  }

  Future<DocumentReference> getRef(RecipeIngredient item) async {
    if (item == null) {
      throw ArgumentError("Invalid input.");
    }

    String id = await getId(item);

    return _collection.doc(id);
  }

  @override
  Future<void> delete(RecipeIngredient item) async {
    final querySnapshot = await _collection
        .where("recipeId", isEqualTo: item.recipeId)
        .where("ingredientId", isEqualTo: item.ingredientId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException(
        "The RecipeIngredient input doesn't exist",
        StackTrace.current,
      );
    }

    try {
      final String id = querySnapshot.docs.first.id;

      await _collection.doc(id).delete();
    } on FirebaseException catch (e, st) {
      throw Exception("Failed to delete the RecipeIngredient entry");
    } catch (e, st) {
      throw Exception(
        "Unexpected error while deleting the RecipeIngredient entry",
      );
    }
  }

  /// Add a delete operation of a RecipeIngredient item in the input batch
  /// [itemRef] the DocumentReference of the RecipeIngredient item to be deleted
  /// [batch] a WriteBatch
  void deleteWithBatch(DocumentReference itemRef, WriteBatch batch) {
    batch.delete(itemRef);
  }

  Future<void> deleteByRecipeId(String recipeId, WriteBatch batch) async {
    // 1) Get all related ingredients
    final querySnapshot = await _collection
        .where("recipeId", isEqualTo: recipeId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException(
        "No ingredients found for this recipe ID",
        StackTrace.current,
      );
    }

    // 2) Add the delete operations to the transaction
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    return;
  }

  /// Update the input RecipeIngredient item using the input batch
  /// [item] the RecipeIngrediet object to be updated
  /// [itemRef] the DocumentReference of the input item
  /// [batch] a WriteBatch
  void updateWithBatch(
    RecipeIngredient item,
    DocumentReference itemRef,
    WriteBatch batch,
  ) {
    if (item == null || itemRef == null) {
      throw ArgumentError("Invalid input.");
    }

    batch.update(itemRef, {
      "quantity": item.quantity,
      "unitMeasurement": item.unitMeasurement,
    });
  }

  @override
  Future<List<RecipeIngredient>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<RecipeIngredient> retrieve(RecipeIngredient item) {
    // TODO: implement retrieve
    throw UnimplementedError();
  }

  @override
  Future<String> save(RecipeIngredient newItem) async {
    if (newItem == null) throw ArgumentError("Invalid input");

    final newRecipeIngredientRef = await _collection.add({
      "ingredientId": newItem.ingredientId,
      "recipeId": newItem.recipeId,
      "quantity": newItem.quantity,
      "unitMeasurement": newItem.unitMeasurement,
    });

    return newRecipeIngredientRef.id;
  }

  void saveWithBatch(
    DocumentReference ref,
    RecipeIngredient item,
    WriteBatch batch,
  ) {
    batch.set(ref, item.toJson());
  }

  @override
  Future<String> getId(RecipeIngredient item) async {
    final querySnapshot = await _collection
        .where("recipeId", isEqualTo: item.recipeId)
        .where("ingredientId", isEqualTo: item.ingredientId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException(
        "RecipeIngredient not found",
        StackTrace.current,
      );
    }

    return querySnapshot.docs.first.id;
  }

  Future<List<RecipeIngredient>> getRecipeIngredientsByRecipeId(
    String recipeId,
  ) async {
    if (recipeId.isEmpty) throw ArgumentError("Invalid input.");

    final querySnapshot = await _collection
        .where("recipeId", isEqualTo: recipeId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException(
        "No recipe ingredient found!",
        StackTrace.current,
      );
    } else {
      return querySnapshot.docs.map((doc) {
        final docData = doc.data();
        return RecipeIngredient(
          docData["recipeId"] as String,
          docData["ingredientId"] as String,
          docData["quantity"] as double,
          docData["unitMeasurement"] as String,
        );
      }).toList();
    }
  }

  @override
  Future<bool> exists(RecipeIngredient item) {
    // TODO: implement exists
    throw UnimplementedError();
  }
}
