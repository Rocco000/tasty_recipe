class CartItem {
  String _userMail;
  String _ingredientId;
  double _quantity;
  String _quantityUnit;
  bool _checked;

  CartItem(
    this._userMail,
    this._ingredientId,
    this._quantity,
    this._quantityUnit,
    this._checked,
  );

  String get userMail => _userMail;

  String get ingredientId => _ingredientId;

  double get quantity => _quantity;

  String get quantityUnit => _quantityUnit;

  bool get isChecked => _checked;

  set checkStatus(bool newValue) => _checked = newValue;
}
