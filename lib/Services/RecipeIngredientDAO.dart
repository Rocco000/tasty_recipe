import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Services/DAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';

class RecipeIngredientDAO extends DAO<RecipeIngredient> {
  @override
  Future<void> delete(RecipeIngredient item) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("RecipeIngredient")
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

      await FirebaseFirestore.instance
          .collection("RecipeIngredient")
          .doc(id)
          .delete();
    } on FirebaseException catch (e, st) {
      throw Exception("Failed to delete the RecipeIngredient entry");
    } catch (e, st) {
      throw Exception(
        "Unexpected error while deleting the RecipeIngredient entry",
      );
    }
  }

  Future<void> deleteByRecipeId(String recipeId, WriteBatch batch) async {
    // 1) Get all related ingredients
    final querySnapshot = await FirebaseFirestore.instance
        .collection("RecipeIngredient")
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

    final newRecipeIngredientRef = await FirebaseFirestore.instance
        .collection("RecipeIngredient")
        .add({
          "ingredientId": newItem.ingredientId,
          "recipeId": newItem.recipeId,
          "quantity": newItem.quantity,
          "unitMeasurement": newItem.unitMeasurement,
        });

    return newRecipeIngredientRef.id;
  }

  @override
  Future<String> getId(RecipeIngredient item) {
    // TODO: implement getId
    throw UnimplementedError();
  }

  Future<List<RecipeIngredient>> getRecipeIngredientsByRecipeId(
    String recipeId,
  ) async {
    if (recipeId.isEmpty) throw ArgumentError("Invalid input.");

    final querySnapshot = await FirebaseFirestore.instance
        .collection("RecipeIngredient")
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
