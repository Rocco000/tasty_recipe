class RecipeIngredient {
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

  String get recipeId => _recipeId;

  set recipeId(String newRecipeId) => _recipeId = newRecipeId;

  String get ingredientId => _ingredientId;

  set ingredientId(String newIngredientId) => _ingredientId = newIngredientId;

  double get quantity => _quantity;

  set quantity(double newQuantity) => _quantity = newQuantity;

  String get unitMeasurement => _unitMeasurement;

  set unitMeasurement(String newUnit) => _unitMeasurement = newUnit;
}
