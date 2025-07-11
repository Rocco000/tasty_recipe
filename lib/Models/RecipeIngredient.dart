class RecipeIngredient {
  int _recipeId;
  int _ingredientId;
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

  RecipeIngredient(this._recipeId, this._ingredientId, this._quantity, this._unitMeasurement);

  int get recipeId => _recipeId;

  set recipeId(int newRecipeId) => _recipeId = newRecipeId;

  int get ingredientId => _ingredientId;

  set ingredientId(int newIngredientId) => _ingredientId = newIngredientId;

  double get quantity => _quantity;

  set quantity(double newQuantity) => _quantity = newQuantity;

  String get unitMeasurement => _unitMeasurement;

  set unitMeasurement(String newUnit) => _unitMeasurement = newUnit;
}
