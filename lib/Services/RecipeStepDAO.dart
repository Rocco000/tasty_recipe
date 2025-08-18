import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Services/DAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';

class RecipeStepDAO extends DAO<RecipeStep> {
  Future<List<RecipeStep>> getAllRecipeStepById(String recipeId) async {
    if (recipeId.isEmpty) {
      throw ArgumentError("Invalid input.");
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection("RecipeStep")
        .where("recipeId", isEqualTo: recipeId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException(
        "No steps found for that recipe!",
        StackTrace.current,
      );
    } else {
      return querySnapshot.docs.map((doc) {
        final docData = doc.data();
        return RecipeStep(
          docData["recipeId"],
          docData["stepOrder"],
          docData["description"],
          docData["duration"],
          docData["durationUnit"],
        );
      }).toList();
    }
  }

  @override
  Future<void> delete(RecipeStep item) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("RecipeStep")
        .where("recipeId", isEqualTo: item.recipeId)
        .where("stepOrder", isEqualTo: item.stepOrder)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException(
        "The input step doesn't exist",
        StackTrace.current,
      );
    }

    try {
      final String id = querySnapshot.docs.first.id;

      await FirebaseFirestore.instance
          .collection("RecipeStep")
          .doc(id)
          .delete();
    } on FirebaseException catch (e, st) {
      throw Exception("Failed to delete the input step");
    } catch (e, st) {
      throw Exception("Unexpected error while deleting the input step");
    }
  }

  Future<void> deleteByRecipeId(String recipeId, WriteBatch batch) async {
    // 1) Get all related steps
    final querySnapshot = await FirebaseFirestore.instance
        .collection("RecipeStep")
        .where("recipeId", isEqualTo: recipeId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException(
        "No steps found for this recipe ID",
        StackTrace.current,
      );
    }

    // 2) Add delete operations to the transaction
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    return;
  }

  @override
  Future<List<RecipeStep>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<RecipeStep> retrieve(RecipeStep item) {
    // TODO: implement retrieve
    throw UnimplementedError();
  }

  @override
  Future<String> save(RecipeStep newItem) async {
    if (newItem == null) throw ArgumentError("Invalid input");

    final newRecipeStepRef = await FirebaseFirestore.instance
        .collection("RecipeStep")
        .add({
          "recipeId": newItem.recipeId,
          "stepOrder": newItem.stepOrder,
          "description": newItem.description,
          "duration": newItem.duration,
          "durationUnit": newItem.durationUnit,
        });

    return newRecipeStepRef.id;
  }

  @override
  Future<String> getId(RecipeStep item) {
    // TODO: implement getId
    throw UnimplementedError();
  }

  @override
  Future<bool> exists(RecipeStep item) {
    // TODO: implement exists
    throw UnimplementedError();
  }
}
