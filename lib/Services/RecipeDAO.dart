import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Services/DAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';

class RecipeDAO extends DAO<Recipe> {

  Future<Recipe> getRecipeById(String id) async{
    if (id.isEmpty) {
      throw ArgumentError("Invalid input.");
    }

    final querySnapshot = await FirebaseFirestore.instance.collection("Recipe").doc(id).get();

    if (querySnapshot.exists){
      final docData = querySnapshot.data();

      if (docData != null){
        return Recipe(
          null, 
          querySnapshot.id,
          docData["name"] as String,
          docData["difficulty"] as  int,
          docData["duration"] as int,
          docData["servings"] as int,
          docData["category"] as String,
          List<String>.from(docData["tags"] ?? []),
          docData["favorite"] as bool,
          docData["userId"] as String,
        );
      }
      else{
        throw Exception("Something went wrong!");
      }
    }
    else{
      throw DataNotFoundException("Recipe not found!", StackTrace.current);
    }
  }

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

  Future<List<Recipe>> getRecipeByCategory(String categoryName) async {
    if (categoryName.isEmpty)
      throw ArgumentError("Invalid input. The parameter can't be null");

    final querySnapshot = await FirebaseFirestore.instance
        .collection("Recipe")
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

  Future<List<Recipe>> getFavoriteRecipes() async{
    final querySnapshot = await FirebaseFirestore.instance.collection("Recipe").where("favorite", isEqualTo: true).get();

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
  }

  @override
  Future<String> getId(Recipe item) {
    // TODO: implement getId
    throw UnimplementedError();
  }
}
