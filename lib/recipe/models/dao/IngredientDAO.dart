import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_recipe/recipe/models/entities/Ingredient.dart';
import 'package:tasty_recipe/Services/DAO.dart';
import 'package:tasty_recipe/Utils/DataNotFoundException.dart';
import 'package:tasty_recipe/Utils/DatabaseOperationException.dart';

class IngredientDAO extends DAO<Ingredient> {
  final _collection = FirebaseFirestore.instance.collection("Ingredient");

  /// New document reference
  DocumentReference newRef() {
    return _collection.doc(); // auto-generates ID
  }

  /// Return the Ingredient with the given [id]
  /// - [id] the ingrediet ID
  ///
  /// Throw:
  /// - [ArgumentError] if the input [id] is empty.
  /// - [DataNotFoundException] if there is no ingredient with the given [id].
  /// - [DatabaseOperationException] if the document exists but contains no data.
  Future<Ingredient> getIngredientById(String id) async {
    if (id.isEmpty) {
      throw ArgumentError("Invalid input. The ingredient ID can't be empty.");
    }

    final querySnapshot = await _collection.doc(id).get();

    if (!querySnapshot.exists) {
      throw DataNotFoundException("Ingredient not found", StackTrace.current);
    }

    final docData = querySnapshot.data();

    if (docData == null) {
      throw DatabaseOperationException(
        "An error occurred while fetching the ingredient. Get empty document.",
        StackTrace.current,
      );
    }

    return Ingredient(querySnapshot.id, docData["name"]);
  }

  @override
  Future<bool> exists(Ingredient item) async {
    if (item == null) {
      throw ArgumentError("Invalid input.");
    }

    final querySnapshot = await _collection.doc(item.id).get();

    return querySnapshot.exists;
  }

  Future<bool> existsByName(Ingredient item) async {
    if (item == null) {
      throw ArgumentError("Invalid input. The input ingredient is null.");
    }

    final querySnapshot = await _collection
        .where("name", isEqualTo: item.name)
        .get();

    return querySnapshot.docs.isNotEmpty;
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
