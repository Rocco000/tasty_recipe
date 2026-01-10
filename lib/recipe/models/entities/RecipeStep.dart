import 'package:tasty_recipe/Models/Entity.dart';

class RecipeStep implements Entity {
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

  /// Factory method to build an entity from Firestore JSON
  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      json["recipeId"] as String,
      json["stepOrder"] as int,
      json["description"] as String,
      json["duration"] as double,
      json["durationUnit"] as String,
    );
  }

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

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonObject = {
      "recipeId": recipeId,
      "stepOrder": stepOrder,
      "description": description,
    };

    if (duration != null) {
      jsonObject["duration"] = duration!;
      jsonObject["durationUnit"] = durationUnit!;
    }

    return jsonObject;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeStep &&
          runtimeType == other.runtimeType &&
          recipeId == other.recipeId &&
          stepOrder == other.stepOrder &&
          description == other.description &&
          duration == other.duration &&
          durationUnit == other.durationUnit;

  @override
  int get hashCode =>
      recipeId.hashCode ^
      stepOrder.hashCode ^
      description.hashCode ^
      duration.hashCode ^
      durationUnit.hashCode;

  RecipeStep clone() =>
      RecipeStep(_recipeId, _stepOrder, _description, _duration, _durationUnit);
}
