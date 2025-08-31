import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:tasty_recipe/Screens/HomeScreen.dart';
import 'package:tasty_recipe/Services/RecipeCreationController.dart';
import 'package:tasty_recipe/Utils/InvalidFieldException.dart';
import 'package:tasty_recipe/Widgets/DottedButtonWidget.dart';
import 'package:tasty_recipe/Widgets/RecipeStepFormField.dart';

class AddRecipeStepsScreen extends StatefulWidget {
  static const route = "/insertRecipeStep";

  const AddRecipeStepsScreen({super.key});

  @override
  State<AddRecipeStepsScreen> createState() => _AddRecipeStepsScreenState();
}

class _AddRecipeStepsScreenState extends State<AddRecipeStepsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<int> _stepIds = [0];
  bool _durationErrorFlag = false;
  bool _isSaving = false;

  int _numStepFields = 1;

  Widget _generateRecipeStepFields(int index, int id) {
    return (index == 0)
        ? RecipeStepFormField(
            stepOrder: index,
            durationErrorMessage: (_durationErrorFlag)
                ? "Mismatch with total recipe duration"
                : "",
          )
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
                _numStepFields -= 1;
                _stepIds.remove(id);
              });

              // Clear the form state
              _formKey.currentState!.removeInternalFieldValue(
                "stepDescription$index",
              );

              if (_formKey.currentState!.fields.keys.contains(
                "stepDuration$index",
              )) {
                // Clear optional fields
                _formKey.currentState!.removeInternalFieldValue(
                  "stepDuration$index",
                );
                _formKey.currentState!.removeInternalFieldValue(
                  "stepDurationUnit$index",
                );
              }
            },
            child: RecipeStepFormField(
              stepOrder: index,
              durationErrorMessage: (_durationErrorFlag)
                  ? "Mismatch with total recipe duration"
                  : "",
            ),
          );
  }

  Future<void> _onSavePressed(RecipeCreationController controller) async {
    if (_formKey.currentState!.saveAndValidate()) {
      // Disable save button
      setState(() {
        _isSaving = !_isSaving;
        _durationErrorFlag = false;
      });

      // Get form state
      final formFields = _formKey.currentState!.value;

      for (int i = 0; i < _numStepFields; i++) {
        if (formFields["stepDuration$i"] == null) {
          // Store step WITHOUT TIMER
          try {
            controller.addStep(i, formFields["stepDescription$i"]);
          } on InvalidFieldException catch (e) {
            _formKey.currentState!.fields["stepDescription$i"]!.invalidate(
              "Required",
            );

            return;
          }
        } else {
          // Store step WITH TIMER
          try {
            controller.addStep(
              i,
              formFields["stepDescription$i"],
              stepDuration: double.parse(formFields["stepDuration$i"]),
              stepDurationUnit: formFields["stepDurationUnit$i"],
            );
          } on InvalidFieldException catch (e) {
            // Highlight with a red border the invalid field
            if (e.fieldName == "stepDescription") {
              _formKey.currentState!.fields["stepDescription$i"]!.invalidate(
                "Required",
              );
            } else if (e.fieldName == "stepDuration") {
              _formKey.currentState!.fields["stepDuration$i"]!.invalidate(
                "Invalid input",
              );
            } else {
              _formKey.currentState!.fields["stepDurationUnit$i"]!.invalidate(
                "Invalid input",
              );
            }

            return;
          }
        }
      }

      // Store data
      final (result, msg) = await controller.createNewRecipe();

      if (result) {
        // Get the root Navigator instance and move on HomeScreen
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          HomeScreen.route,
          (route) => false,
          arguments: {"msg": msg},
        );
      } else {
        setState(() {
          if (!msg.contains("Something")) {
            // Highlight the time field if the error is not a DB Exception
            _durationErrorFlag = true;
          }

          // Active save button
          _isSaving = !_isSaving;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.black45,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating, // Makes it float over the UI
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RecipeCreationController>(
      context,
      listen: false,
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          title: const Text("Recipe App"),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              controller.clearIngredients();
              controller.clearSteps();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // Logo + Text
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          "content/images/bake.png",
                          width: 100,
                          height: 100,
                        ),
                        const Text(
                          "Write steps!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Step Description + Timer
                ...List.generate(_numStepFields, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _generateRecipeStepFields(index, _stepIds[index]),
                  );
                }),

                // BUTTON TO ADD STEPS
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DottedButtonWidget(
                    onTap: () {
                      if (!_isSaving) {
                        setState(() {
                          _numStepFields += 1;
                          _stepIds.add(DateTime.now().millisecondsSinceEpoch);
                        });
                      }
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

                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: (_isSaving)
                        ? null
                        : () => _onSavePressed(controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.black,
                      elevation: 2.0,
                      //fixedSize: Size(5, 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    child: const Text("Save Recipe!"),
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
