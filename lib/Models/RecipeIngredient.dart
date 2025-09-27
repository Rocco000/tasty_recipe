import 'package:tasty_recipe/Models/Entity.dart';

class RecipeIngredient implements Entity {
  String _recipeId;
  String _ingredientId;
  double _quantity;
  String _unitMeasurement;

  static final List<String> units = [
    "gr",
    "mg",
    "l",
    "cl",
    "ml",
    "oz",
    "teaspoons",
    "tablespoons",
    "cup",
  ];

  RecipeIngredient(
    this._recipeId,
    this._ingredientId,
    this._quantity,
    this._unitMeasurement,
  );

  /// Factory method to build an entity from Firestore JSON
  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      json["recipeId"] as String,
      json["ingredientId"] as String,
      json["quantiy"] as double,
      json["unitMeasurement"] as String,
    );
  }

  String get recipeId => _recipeId;

  set recipeId(String newRecipeId) => _recipeId = newRecipeId;

  String get ingredientId => _ingredientId;

  set ingredientId(String newIngredientId) => _ingredientId = newIngredientId;

  double get quantity => _quantity;

  set quantity(double newQuantity) => _quantity = newQuantity;

  String get unitMeasurement => _unitMeasurement;

  set unitMeasurement(String newUnit) => _unitMeasurement = newUnit;

  @override
  Map<String, dynamic> toJson() {
    return {
      "recipeId": recipeId,
      "ingredientId": ingredientId,
      "quantity": quantity,
      "unitMeasurement": unitMeasurement,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeIngredient &&
          recipeId == other.recipeId &&
          ingredientId == other.ingredientId &&
          quantity == other.quantity &&
          unitMeasurement == other.unitMeasurement;

  @override
  int get hashCode =>
      recipeId.hashCode ^
      ingredientId.hashCode ^
      quantity.hashCode ^
      unitMeasurement.hashCode;

  RecipeIngredient clone() =>
      RecipeIngredient(_recipeId, _ingredientId, _quantity, _unitMeasurement);
}
