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
      throw DataNotFoundException("No steps found for that recipe!", StackTrace.current);
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
  Future<void> delete(RecipeStep item) {
    // TODO: implement delete
    throw UnimplementedError();
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
}
