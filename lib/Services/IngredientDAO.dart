import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Services/DAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';

class IngredientDAO extends DAO<Ingredient> {
  final _collection = FirebaseFirestore.instance.collection("Ingredient");

  /// New document reference
  DocumentReference newRef() {
    return _collection.doc(); // auto-generates ID
  }

  Future<Ingredient> getIngredientById(String id) async {
    if (id.isEmpty) {
      throw ArgumentError("Invalid input.");
    }

    final querySnapshot = await _collection.doc(id).get();

    if (querySnapshot.exists) {
      final docData = querySnapshot.data();

      if (docData != null) {
        return Ingredient(querySnapshot.id, docData["name"]);
      } else {
        throw Exception("Something went wrong!");
      }
    } else {
      throw DataNotFoundException("Ingredient not found", StackTrace.current);
    }
  }

  @override
  Future<bool> exists(Ingredient item) async {
    if (item == null) {
      throw ArgumentError("Invalid input.");
    }

    final querySnapshot = await _collection.doc(item.id).get();

    return querySnapshot.exists;
  }

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

    final newIngredientRef = await _collection.add({"name": newItem.name});
    return newIngredientRef.id;
  }

  void saveWithBatch(
    DocumentReference ref,
    Ingredient newIngredient,
    WriteBatch batch,
  ) {
    batch.set(ref, newIngredient.toJson());
  }

  @override
  Future<String> getId(Ingredient item) async {
    if (item == null)
      throw ArgumentError("Invalid input. The parameter can't be null.");

    final querySnapshot = await _collection
        .where("name", isEqualTo: item.name)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw DataNotFoundException("Ingredient not found", StackTrace.current);
    }

    return querySnapshot.docs.first.id;
  }
}
