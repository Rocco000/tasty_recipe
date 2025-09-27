import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Screens/EditRecipeStepsScreen.dart';
import 'package:tasty_recipe/Services/RecipeEditController.dart';
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

  late RecipeEditController _controller;

  late Recipe _recipe;
  late List<Ingredient> _oldIngredients;
  late List<RecipeIngredient> _oldRecipeIngredients;

  int _numIngredients = 1;
  late List<int> _idList;

  @override
  void initState() {
    super.initState();
    // Get controller instance
    _controller = Provider.of<RecipeEditController>(context, listen: false);

    // Get old recipe ingredient version
    _recipe = _controller.oldRecipe;
    List<RecipeIngredient> controllerRecipeIngredient =
        _controller.oldRecipeIngredientList;
    List<Ingredient> controllerIngredient = _controller.oldIngredients;

    _oldRecipeIngredients = List.generate(
      controllerRecipeIngredient.length,
      (index) => controllerRecipeIngredient[index].clone(),
    );
    _oldIngredients = List.generate(
      controllerIngredient.length,
      (index) => controllerIngredient[index].clone(),
    );

    _numIngredients = _oldRecipeIngredients.length;

    // Define Dismissible Widget IDs for existing ingredients
    _idList = List.generate(_numIngredients, (index) => index);
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
          if (index < _oldRecipeIngredients.length) {
            // Remove ingredient from recipe ingredient list IF it is not a new ingredient
            _oldRecipeIngredients.removeAt(index);
            _oldIngredients.removeAt(index);
          }

          // Remove its corresponding ID
          _idList.removeAt(index);
        });

        // Clear the form state
        _formKey.currentState!.removeInternalFieldValue("ingredientName$index");
        _formKey.currentState!.removeInternalFieldValue("ingredientUnit$index");
        _formKey.currentState!.removeInternalFieldValue(
          "ingredientQuantity$index",
        );

        if (_formKey.currentState!.fields.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "The recipe must have at least one ingredient!",
              ),
              backgroundColor: Colors.black45,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating, // Makes it float over the UI
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: (index <= _oldRecipeIngredients.length - 1)
          ? IngredientFormField(
              ingredientNumber: index,
              ingredientList: _oldIngredients,
              ingredientName: _oldIngredients[index].name,
              recipeIngredient: _oldRecipeIngredients[index],
            )
          : IngredientFormField(
              ingredientNumber: index,
              ingredientList: _oldIngredients,
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
          leading: IconButton(
            onPressed: () {
              // Clear temporary data stored in the Controller object before going back to the previous screen
              _controller.clearIngredients();
              _controller.clearRecipeIngredientList();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
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
                        List<RecipeIngredient> newRecipeIngredientList = [];
                        List<Ingredient> newIngredients = [];

                        for (int i = 0; i < _numIngredients; i++) {
                          String quantity =
                              formFields["ingredientQuantity$i"] as String;

                          if (i < _oldRecipeIngredients.length) {
                            newRecipeIngredientList.add(
                              RecipeIngredient(
                                _recipe.id,
                                _oldRecipeIngredients[i].ingredientId,
                                double.parse(quantity),
                                formFields["ingredientUnit$i"] as String,
                              ),
                            );

                            newIngredients.add(_oldIngredients[i]);
                          } else {
                            final String newIngredientName =
                                formFields["ingredientName$i"] as String;
                            newRecipeIngredientList.add(
                              RecipeIngredient(
                                _recipe.id,
                                "tempID$i",
                                double.parse(quantity),
                                formFields["ingredientUnit$i"] as String,
                              ),
                            );
                            newIngredients.add(
                              Ingredient(
                                "tempID$i",
                                newIngredientName.trim().toLowerCase(),
                              ),
                            );
                          }
                        }

                        _controller.updateIngredients(newIngredients);
                        _controller.updateRecipeIngredient(
                          newRecipeIngredientList,
                        );
                        Navigator.pushNamed(
                          context,
                          EditRecipeStepsScreen.route,
                        );
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
                    child: const Text("Continue"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
