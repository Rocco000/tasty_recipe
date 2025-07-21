import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Services/DAO.dart';

class RecipeDAO extends DAO<Recipe> {
  @override
  Future<void> delete(Recipe item) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<Recipe>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
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

    final newRecipeRef = await FirebaseFirestore.instance
        .collection("Recipe")
        .add({
          "name": newItem.name,
          "difficulty": newItem.difficulty,
          "duration": newItem.duration,
          "servings": newItem.servings,
          "category": newItem.category,
          "tags": newItem.tags,
          "userId": "prova", //FirebaseAuth.instance.currentUser!.uid
        });

    return newRecipeRef.id;
  }

  @override
  Future<String> getId(Recipe item) {
    // TODO: implement getId
    throw UnimplementedError();
  }
}
