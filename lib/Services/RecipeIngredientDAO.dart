import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Services/DAO.dart';

class RecipeIngredientDAO extends DAO<RecipeIngredient> {
  @override
  Future<void> delete(RecipeIngredient item) {
    // TODO: implement delete
    throw UnimplementedError();
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
}
