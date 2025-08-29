import 'package:tasty_recipe/Models/Entity.dart';

class CartItem implements Entity {
  String _userMail;
  String _ingredientId;
  bool _checked;

  CartItem(this._userMail, this._ingredientId, this._checked);

  /// Factory method to build an entity from Firestore JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      json["userId"] as String,
      json["ingredientId"] as String,
      false,
    );
  }

  String get userMail => _userMail;

  String get ingredientId => _ingredientId;

  bool get isChecked => _checked;

  set checkStatus(bool newValue) => _checked = newValue;

  @override
  Map<String, dynamic> toJson() {
    return {"userId": userMail, "ingredientId": ingredientId};
  }
}
