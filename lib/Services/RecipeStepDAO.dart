import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Services/DAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';

class RecipeStepDAO extends DAO<RecipeStep> {
  final _collection = FirebaseFirestore.instance.collection("RecipeStep");

  /// New document reference
  DocumentReference newRef() {
    return _collection.doc(); // auto-generates ID
  }

  Future<DocumentReference> getRef(RecipeStep item) async {
    if (item == null) {
      throw ArgumentError("Invalid input. The input item is null.");
    }

    String id = await getId(item);

    return _collection.doc(id);
  }

  Future<List<RecipeStep>> getAllRecipeStepById(String recipeId) async {
    if (recipeId.isEmpty) {
      throw ArgumentError("Invalid input.");
    }

    final querySnapshot = await _collection
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
    final querySnapshot = await _collection
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

      await _collection.doc(id).delete();
    } on FirebaseException catch (e, st) {
      throw Exception("Failed to delete the input step");
    } catch (e, st) {
      throw Exception("Unexpected error while deleting the input step");
    }
  }

  Future<void> deleteByRecipeId(String recipeId, WriteBatch batch) async {
    // 1) Get all related steps
    final querySnapshot = await _collection
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

  /// Add a delete operation of the input RecipeStep in the input batch.
  /// [itemRef] the DocumentReference of the RecipeStep item to be deleted.
  /// [batch] a WriteBatch to add the delete operation.
  void deleteWithBatch(DocumentReference itemRef, WriteBatch batch) {
    batch.delete(itemRef);
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

    final newRecipeStepRef = await _collection.add({
      "recipeId": newItem.recipeId,
      "stepOrder": newItem.stepOrder,
      "description": newItem.description,
      "duration": newItem.duration,
      "durationUnit": newItem.durationUnit,
    });

    return newRecipeStepRef.id;
  }

  void saveWithBatch(
    DocumentReference ref,
    RecipeStep newStep,
    WriteBatch batch,
  ) {
    batch.set(ref, newStep.toJson());
  }

  @override
  Future<String> getId(RecipeStep item) async {
    if (item == null) {
      throw ArgumentError("Invalid input. The input item is null.");
    }

    final querySnapshot = await _collection
        .where("recipeId", isEqualTo: item.recipeId)
        .where("stepOrder", isEqualTo: item.stepOrder)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException(
        "The input RecipeStep doesn't exist.",
        StackTrace.current,
      );
    }

    return querySnapshot.docs.first.id;
  }

  @override
  Future<bool> exists(RecipeStep item) {
    // TODO: implement exists
    throw UnimplementedError();
  }

  /// Update the input RecipeStep item using the input batch
  /// [item] the RecipeStep object to be updated
  /// [itemRef] the DocumentReference of the input item
  /// [batch] a WriteBatch
  void updateWithBatch(
    RecipeStep item,
    DocumentReference itemRef,
    WriteBatch batch,
  ) {
    if (item == null || itemRef == null) {
      throw ArgumentError("Invalid input.");
    }

    batch.update(itemRef, {
      "stepOrder": item.stepOrder,
      "description": item.description,
      "duration": item.duration,
      "durationUnit": item.durationUnit,
    });
  }
}
