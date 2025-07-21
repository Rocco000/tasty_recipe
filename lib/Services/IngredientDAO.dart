import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Services/DAO.dart';

class IngredientDAO extends DAO<Ingredient> {
  @override
  Future<void> delete(Ingredient item) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<Ingredient>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<Ingredient> retrieve(Ingredient item) {
    // TODO: implement retrieve
    throw UnimplementedError();
  }

  @override
  Future<String> save(Ingredient newItem) async {
    if (newItem == null) throw ArgumentError("Invalid input");

    final newIngredientRef = await FirebaseFirestore.instance
        .collection("Ingredient")
        .add({"name": newItem.name});
    return newIngredientRef.id;
  }

  @override
  Future<String> getId(Ingredient item) async {
    if (item == null)
      throw ArgumentError("Invalid input. The parameter can't be null.");

    final querySnapshot = await FirebaseFirestore.instance
        .collection("Ingredient")
        .where("name", isEqualTo: item.name)
        .get();

    if (querySnapshot.docs.isEmpty) throw Exception("Ingredient not found");

    return querySnapshot.docs.first.id;
  }
}
