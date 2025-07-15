import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Widgets/DottedButtonWidget.dart';
import 'package:tasty_recipe/Widgets/IngredientFormField.dart';

class EditIngredientsScreen extends StatefulWidget {
  static const String route = "/editRecipeIngredients";

  const EditIngredientsScreen({super.key});

  @override
  State<EditIngredientsScreen> createState() => _EditIngredientsScreenState();
}

class _EditIngredientsScreenState extends State<EditIngredientsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  final List<Ingredient> _allIngredients = [
    Ingredient(0, "Chocolate"),
    Ingredient(1, "Milk"),
    Ingredient(2, "Wheat"),
    Ingredient(3, "Lime"),
  ];

  final List<Ingredient> _ingredientNames = [
    Ingredient(0, "Chocolate"),
    Ingredient(1, "Milk"),
    Ingredient(2, "Wheat"),
    Ingredient(3, "Lime"),
  ];
  final List<RecipeIngredient> _recipeIngredients = [
    RecipeIngredient(0, 0, 500, "gr"),
    RecipeIngredient(0, 1, 2, "cup"),
    RecipeIngredient(0, 2, 1000, "gr"),
    RecipeIngredient(0, 3, 1, "gr"),
  ];

  int _numIngredients = 1;
  List<int> _idList = [];

  @override
  void initState() {
    super.initState();
    _numIngredients = _recipeIngredients.length;
    _idList = List.generate(_recipeIngredients.length, (index) => index);
  }

  Widget _generateIngredientField(int index) {
    return Dismissible(
      key: ValueKey<int>(_idList[index]),
      background: const DecoratedBox(
        decoration: BoxDecoration(color: Colors.red),
        child: Align(
          alignment: Alignment(-0.9, 00),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        setState(() {
          _numIngredients -= 1;
          if (index <= _recipeIngredients.length - 1) {
            // Remove ingredient from recipe ingredient list
            _recipeIngredients.removeAt(index);
            _ingredientNames.removeAt(index);
          }

          // Remove its corresponding ID
          _idList.removeAt(index);
        });

        // Clear the form state
        _formKey.currentState!.removeInternalFieldValue("ingredientUnit$index");
        _formKey.currentState!.removeInternalFieldValue(
          "ingredientQuantity$index",
        );
      },
      child: (index <= _recipeIngredients.length - 1)
          ? IngredientFormField(
              ingredientNumber: index,
              ingredientList: _allIngredients,
              ingredientName: _ingredientNames[index].name,
              recipeIngredient: _recipeIngredients[index],
            )
          : IngredientFormField(
              ingredientNumber: index,
              ingredientList: _allIngredients,
              ingredientName: null,
              recipeIngredient: null,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          title: const Text("Tasty Recipe"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: const Text(
                  "Edit ingredients",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),

              FormBuilder(
                key: _formKey,
                child: Column(
                  children: List.generate(
                    _numIngredients,
                    (index) => _generateIngredientField(index),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: DottedButtonWidget(
                  onTap: () {
                    setState(() {
                      _numIngredients += 1;
                      _idList.add(DateTime.now().millisecondsSinceEpoch);
                    });
                  },
                  child: Column(
                    children: const <Widget>[
                      Icon(Icons.add, color: Colors.blueAccent),
                      Text(
                        "Add another ingredient",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_numIngredients > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        final formFields = _formKey.currentState!.value;

                        for (int i = 0; i < _numIngredients; i++) {
                          var app = {
                            "name": formFields["ingredient_$i"],
                            "unit": formFields["ingredientUnit_$i"],
                            "quantity": formFields["ingredientQuantity_$i"],
                          };

                          print(app);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.black,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    child: const Text("Save"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
