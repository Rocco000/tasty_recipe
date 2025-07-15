class RecipeStep {
  String _recipeId;
  int _stepOrder;
  String _description;
  double? _duration;
  String? _durationUnit;

  static final timeUnits = ["second", "minute", "hour"];

  RecipeStep(
    this._recipeId,
    this._stepOrder,
    this._description,
    this._duration,
    this._durationUnit,
  );

  static String getUnitMeasurementSymbol(String unit) {
    if (!timeUnits.contains(unit)) throw Exception("Invalid input!");

    return (unit == "hour")
        ? "h"
        : (unit == "minute")
        ? "m"
        : "s";
  }

  String get recipeId => _recipeId;

  set recipeId(String newRecipeId) => _recipeId = newRecipeId;

  int get stepOrder => _stepOrder;

  set stepOrder(int newStepOrder) => _stepOrder = newStepOrder;

  String get description => _description;

  set description(String newDescription) => _description = newDescription;

  double? get duration => _duration;

  set duration(double? newDuration) => _duration = newDuration;

  String? get durationUnit => _durationUnit;

  set durationUnit(String? newDurationUnit) => _durationUnit = newDurationUnit;
}
