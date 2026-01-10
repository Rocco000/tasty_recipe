import 'package:tasty_recipe/Models/Entity.dart';

class Ingredient implements Entity {
  String _id;
  String _name;

  Ingredient(this._id, this._name);

  /// Factory method to build an entity from Firestore JSON
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(json["id"] as String, json["name"] as String);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"name": _name};
  }

  String get id => _id;

  set id(String newId) => _id = newId;

  String get name => _name;

  set name(String newName) => _name = name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  Ingredient clone() => Ingredient(_id, _name);
}
