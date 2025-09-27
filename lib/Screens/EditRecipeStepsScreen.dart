import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Services/RecipeEditController.dart';
import 'package:tasty_recipe/Widgets/DottedButtonWidget.dart';
import 'package:tasty_recipe/Widgets/RecipeStepFormField.dart';

class EditRecipeStepsScreen extends StatefulWidget {
  static const String route = "/editRecipeSteps";

  const EditRecipeStepsScreen({super.key});

  @override
  State<EditRecipeStepsScreen> createState() => _EditRecipeStepsScreenState();
}

class _EditRecipeStepsScreenState extends State<EditRecipeStepsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  late RecipeEditController _controller;
  late Recipe _recipe;
  late List<RecipeStep> _currentRecipeSteps;

  late int _numStepFields;
  late List<int> _stepIds;
  late int _formFieldIdGenerator;
  late List<int> _formFieldIds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<RecipeEditController>(context, listen: false);

    // Get old recipe steps version
    _recipe = _controller.oldRecipe;
    List<RecipeStep> controllerRecipeStep = _controller.oldRecipeSteps;
    _currentRecipeSteps = List.generate(
      controllerRecipeStep.length,
      (index) => controllerRecipeStep[index].clone(),
    );

    // Define Dismissible Widget IDs for existing ingredients
    _numStepFields = _currentRecipeSteps.length;
    _stepIds = List.generate(_numStepFields, (index) => index);

    // Define form field IDs
    _formFieldIdGenerator = _numStepFields - 1;
    _formFieldIds = List.generate(_numStepFields, (index) => index);
  }

  Widget _generateStepField(int index) {
    return (index == 0)
        ? RecipeStepFormField(
            stepOrder: index,
            fieldId: _formFieldIds[index],
            durationErrorMessage: "",
            recipeStep: _currentRecipeSteps[index],
          )
        : Dismissible(
            key: ValueKey<int>(_stepIds[index]),
            background: const DecoratedBox(
              decoration: BoxDecoration(color: Colors.red),
              child: Align(
                alignment: Alignment(-0.9, 0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ),
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) {
              // Remove its corresponding form fields
              _formKey.currentState!.removeInternalFieldValue(
                "stepDescription${_formFieldIds[index]}",
              );
              _formKey.currentState!.removeInternalFieldValue(
                "stepDuration${_formFieldIds[index]}",
              );
              _formKey.currentState!.removeInternalFieldValue(
                "stepDurationUnit${_formFieldIds[index]}",
              );

              setState(() {
                _numStepFields -= 1;
                if (index < _currentRecipeSteps.length) {
                  // Remove the step from recipe step list IF it is not a new step
                  _currentRecipeSteps.removeAt(index);
                }

                // Remove its corresponding Widget ID
                _stepIds.removeAt(index);

                // Remove its corresponding Form Field ID
                _formFieldIds.removeAt(index);
              });
            },
            child: RecipeStepFormField(
              stepOrder: index,
              fieldId: _formFieldIds[index],
              durationErrorMessage: "",
              recipeStep: (index < _currentRecipeSteps.length)
                  ? _currentRecipeSteps[index]
                  : null,
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
              _controller.clearRecipeSteps();
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
                  "Edit steps",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),

              FormBuilder(
                key: _formKey,
                child: Column(
                  children: List.generate(_numStepFields, _generateStepField),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: DottedButtonWidget(
                  onTap: () {
                    setState(() {
                      // Add a new Widget ID
                      _numStepFields += 1;
                      _stepIds.add(DateTime.now().millisecondsSinceEpoch);

                      // Add a new Form Field ID
                      _formFieldIdGenerator++;
                      _formFieldIds.add(_formFieldIdGenerator);
                    });
                  },
                  child: Column(
                    children: const <Widget>[
                      Icon(Icons.add, color: Colors.blueAccent),
                      Text(
                        "Add another step",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_numStepFields > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: (_isSaving)
                        ? null
                        : () async {
                            setState(() {
                              // Disable the save button to prevent multiple submissions
                              _isSaving = true;
                            });

                            if (_formKey.currentState!.saveAndValidate()) {
                              final formFields = _formKey.currentState!.value;
                              List<RecipeStep> newSteps = [];

                              int i = 0;
                              for (int fieldId in _formFieldIds) {
                                String description =
                                    formFields["stepDescription$fieldId"]
                                        as String;
                                description = description.trim();

                                String? unit;
                                double? duration;

                                // Check if the i-th step has a time duration
                                if (formFields.containsKey(
                                      "stepDuration$fieldId",
                                    ) &&
                                    formFields.containsKey(
                                      "stepDurationUnit$fieldId",
                                    )) {
                                  String durationStr =
                                      formFields["stepDuration$fieldId"]
                                          as String;
                                  duration = double.parse(durationStr);
                                  unit =
                                      formFields["stepDurationUnit$fieldId"]
                                          as String;
                                  unit = unit.trim();
                                }

                                print(
                                  "Step $i: duration: $duration; Unit: $unit",
                                );

                                newSteps.add(
                                  RecipeStep(
                                    _recipe.id,
                                    i,
                                    description,
                                    duration,
                                    unit,
                                  ),
                                );

                                i++;
                              }

                              // Store new step list in the Controller class
                              _controller.updateRecipeSteps(newSteps);

                              // Apply changes to the database
                              final (result, msg) = await _controller
                                  .saveChanges();

                              if (!result) {
                                // An ERROR occurred
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(msg),
                                    backgroundColor: Colors.black45,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior
                                        .floating, // Makes it float over the UI
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              } else {
                                // SUCCESS -> Navigate to the RecipeDetailsScreen
                                // Exit from the inner Navigator (with rootNavigator:true) and navigate back to RecipeDetailsScreen
                                Navigator.of(context, rootNavigator: true).pop({
                                  "recipe": _controller.newRecipe,
                                  "recipeIngredients":
                                      _controller.newRecipeIngredientList,
                                  "ingredients": _controller.newIngredients,
                                  "steps": _controller.newRecipeSteps,
                                });
                              }
                            }

                            setState(() {
                              _isSaving = false;
                            });
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
