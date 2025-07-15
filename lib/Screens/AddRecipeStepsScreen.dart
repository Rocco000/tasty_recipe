import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Screens/HomeScreen.dart';
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

  int _numStepFields = 1;

  Widget _generateRecipeStepFields(int index, int id) {
    return (index == 0)
        ? RecipeStepFormField(stepOrder: index)
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
            },
            child: RecipeStepFormField(stepOrder: index),
          );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          title: const Text("Recipe App"),
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
                      setState(() {
                        _numStepFields += 1;
                        _stepIds.add(DateTime.now().millisecondsSinceEpoch);
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

                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        final formFields = _formKey.currentState!.value;
                        List<RecipeStep> recipeSteps = [];

                        for (int i = 0; i < _numStepFields; i++) {
                          var app = {
                            "description": formFields["step$i"],
                            "timer": formFields["stepTimer$i"],
                            "timerUnit": formFields["timeUnit$i"],
                          };

                          print(app);
                          recipeSteps.add(
                            RecipeStep(
                              0,
                              i,
                              formFields["step$i"],
                              formFields["stepTimer$i"],
                              formFields["timeUnit$i"],
                            ),
                          );
                        }

                        Navigator.pushNamed(context, HomeScreen.route);
                      }
                    },
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
