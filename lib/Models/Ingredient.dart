class Ingredient {
  int _id;
  String _name;

  Ingredient(this._id, this._name);

  int get id => _id;

  set id(int newId) => _id = newId;

  String get name => _name;

  set name(String newName) => _name = name;
}
