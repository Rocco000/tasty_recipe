import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Services/DAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';
import 'package:tasty_recipe/Utils/DatabaseOperationException.dart';
import 'package:tasty_recipe/Utils/UnknownDatabaseException.dart';

class RecipeDAO extends DAO<Recipe> {
  final _collection = FirebaseFirestore.instance.collection("Recipe");

  /// New document reference
  DocumentReference newRef() {
    return _collection.doc(); // auto-generates ID
  }

  Future<Recipe> getRecipeById(String id) async {
    if (id.isEmpty) {
      throw ArgumentError("Invalid input.");
    }

    final querySnapshot = await _collection.doc(id).get();

    if (querySnapshot.exists) {
      final docData = querySnapshot.data();

      if (docData != null) {
        return Recipe(
          null,
          querySnapshot.id,
          docData["name"] as String,
          docData["difficulty"] as int,
          docData["duration"] as int,
          docData["servings"] as int,
          docData["category"] as String,
          List<String>.from(docData["tags"] ?? []),
          docData["favorite"] as bool,
          docData["userId"] as String,
        );
      } else {
        throw Exception("Something went wrong!");
      }
    } else {
      throw DataNotFoundException("Recipe not found!", StackTrace.current);
    }
  }

  @override
  Future<void> delete(Recipe item) async {
    try {
      await _collection.doc(item.id).delete();
    } on FirebaseException catch (e, st) {
      if (e.code == "not-found") {
        throw DataNotFoundException("Recipe doesn't exist", st);
      }

      throw Exception("Failed to delete the recipe");
    } catch (e, st) {
      throw Exception("Unexpected error while deleting the recipe");
    }
  }

  Future<void> deleteByRecipeId(String recipeId, WriteBatch batch) async {
    //1) Get document reference
    final docRef = _collection.doc(recipeId);

    //2) Add delete operation to the transaction
    batch.delete(docRef);
  }

  @override
  Future<List<Recipe>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  Future<List<Recipe>> getRecipeByCategory(String categoryName) async {
    if (categoryName.isEmpty)
      throw ArgumentError("Invalid input. The parameter can't be null");

    final querySnapshot = await _collection
        .where("category", isEqualTo: categoryName)
        .get();

    return querySnapshot.docs.map((doc) {
      final itemData = doc.data();
      return Recipe(
        null,
        doc.id,
        itemData["name"],
        itemData["difficulty"],
        itemData["duration"],
        itemData["servings"],
        itemData["category"],
        List<String>.from(itemData["tags"] ?? []),
        itemData["favorite"],
        itemData["userId"],
      );
    }).toList();
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("Recipe")
        .where("favorite", isEqualTo: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final itemData = doc.data();
      return Recipe(
        null,
        doc.id,
        itemData["name"] as String,
        itemData["difficulty"] as int,
        itemData["duration"] as int,
        itemData["servings"] as int,
        itemData["category"] as String,
        List<String>.from(itemData["tags"] ?? []),
        itemData["favorite"] as bool,
        itemData["userId"] as String,
      );
    }).toList();
  }

  @override
  Future<Recipe> retrieve(Recipe item) {
    // TODO: implement retrieve
    throw UnimplementedError();
  }

  @override
  Future<String> save(Recipe newItem) async {
    if (newItem == null)
      throw ArgumentError("Invalid input. The parameter can't be null");

    try {
      final newRecipeRef = await FirebaseFirestore.instance
          .collection("Recipe")
          .add({
            "name": newItem.name,
            "difficulty": newItem.difficulty,
            "duration": newItem.duration,
            "servings": newItem.servings,
            "category": newItem.category,
            "tags": newItem.tags,
            "favorite": false,
            "userId": "prova", //FirebaseAuth.instance.currentUser!.uid
          });

      return newRecipeRef.id;
    } on FirebaseException catch (e, st) {
      throw DatabaseOperationException("Failed to create a new recipe", st);
    } catch (e, st) {
      throw UnknownDatabaseException(
        "Unexpected error while saving new recipe",
        st,
      );
    }
  }

  void saveWithBatch(DocumentReference ref, Recipe newItem, WriteBatch batch) {
    batch.set(ref, newItem.toJson());
  }

  @override
  Future<String> getId(Recipe item) {
    // TODO: implement getId
    throw UnimplementedError();
  }

  @override
  Future<bool> exists(Recipe item) {
    // TODO: implement exists
    throw UnimplementedError();
  }

  Future<void> updateFavoriteState(Recipe recipe, bool newFavoriteState) async {
    try {
      await FirebaseFirestore.instance
          .collection("Recipe")
          .doc(recipe.id)
          .update({"favorite": newFavoriteState});
    } on FirebaseException catch (e, st) {
      if (e.code == "not-found") {
        throw DataNotFoundException("Recipe doesn't exist", st);
      }

      throw DatabaseOperationException("Failed to update favorite state", st);
    } catch (e, st) {
      throw UnknownDatabaseException(
        "Unexpected error while updating favorite state",
        st,
      );
    }
  }
}
