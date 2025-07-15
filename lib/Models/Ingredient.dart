class Ingredient {
  String _id;
  String _name;

  Ingredient(this._id, this._name);

  String get id => _id;

  set id(String newId) => _id = newId;

  String get name => _name;

  set name(String newName) => _name = name;
}
