import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tasty_recipe/recipe/createRecipe/AddRecipeStepsScreen.dart';
import 'package:tasty_recipe/recipe/createRecipe/RecipeCreationController.dart';
import 'package:tasty_recipe/Utils/InvalidFieldException.dart';
import 'package:tasty_recipe/Widgets/IngredientFormField.dart';
import 'package:tasty_recipe/Widgets/DottedButtonWidget.dart';

class AddRecipeIngredientsScreen extends StatefulWidget {
  static const route = "/addRecipeIngredients";

  const AddRecipeIngredientsScreen({super.key});

  @override
  State<AddRecipeIngredientsScreen> createState() {
    return _AddRecipeIngredientsState();
  }
}

class _AddRecipeIngredientsState extends State<AddRecipeIngredientsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  final List<int> _ingredientIds = [0];
  int _numIngredients = 1;

  Widget _generateIngredientField(int index, int id) {
    return (index == 0)
        ? IngredientFormField(ingredientNumber: index)
        : Dismissible(
            key: ValueKey<int>(id),
            background: DecoratedBox(
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
                _ingredientIds.remove(id);
              });

              // Clear the form state
              _formKey.currentState!.removeInternalFieldValue(
                "ingredientName$index",
              );
              _formKey.currentState!.removeInternalFieldValue(
                "ingredientUnit$index",
              );
              _formKey.currentState!.removeInternalFieldValue(
                "ingredientQuantity$index",
              );
            },
            child: IngredientFormField(ingredientNumber: index),
          );
  }

  void _onContinuePressed(RecipeCreationController controller) {
    if (_formKey.currentState!.saveAndValidate()) {
      final formFields = _formKey.currentState!.value;

      for (int i = 0; i < _numIngredients; i++) {
        try {
          controller.addIngredient(
            formFields["ingredientName$i"] as String,
            double.parse(formFields["ingredientQuantity$i"]),
            formFields["ingredientUnit$i"] as String,
          );
        } on InvalidFieldException catch (e) {
          // Highlight with a red border the correct invalid field
          if (e.fieldName == "ingredientName") {
            _formKey.currentState!.fields["ingredientName$i"]!.invalidate("");
          } else if (e.fieldName == "ingredientQuantity") {
            _formKey.currentState!.fields["ingredientQuantity$i"]!.invalidate(
              "",
            );
          } else {
            _formKey.currentState!.fields["ingredientUnit$i"]!.invalidate("");
          }
          print(e.message);
          return;
        }
      }

      // Move to the next screen
      context.push(AddRecipeStepsScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final RecipeCreationController controller =
        Provider.of<RecipeCreationController>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Recipe App"),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              // Navigate back and clear the ingredient list
              controller.clearIngredients();
              context.pop();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // LOGO + TEXT
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          "content/images/foodIngredient.png",
                          width: 100,
                          height: 100,
                        ),
                        const Text(
                          "Add ingredients!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Unpack the list items -> INGREDIENT FIELDS
                ...List.generate(_numIngredients, (index) {
                  // DISMISSABLE FORM FIELD
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _generateIngredientField(
                      index,
                      _ingredientIds[index],
                    ),
                  );
                }),

                // BUTTON TO ADD INGREDIENTS
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DottedButtonWidget(
                    onTap: () {
                      setState(() {
                        _numIngredients += 1;
                        _ingredientIds.add(
                          DateTime.now().millisecondsSinceEpoch,
                        );
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

                // CONTINUE BUTTON
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () => _onContinuePressed(controller),
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
      ),
    );
  }
}
