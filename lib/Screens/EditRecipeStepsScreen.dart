import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
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

  final List<RecipeStep> _recipeSteps = [
    RecipeStep(
      0,
      0,
      "ncvsdbvujfbsovabf vsdjnviobfdis v vsfojnbgvrsfjn",
      null,
      null,
    ),
    RecipeStep(
      0,
      1,
      "ncvsdbvujfbsovabf vsdjnviobfdis v vsfojnbgvrsfjn rgvedrtsgv tg rtedsg esrtd bers dg",
      20,
      "minute",
    ),
    RecipeStep(
      0,
      2,
      "ncvsdbvujfbsovabf vsdjnviobfdis v vsfojnbgvrsfjn rfg vdfg bd gvrde ",
      1,
      "hour",
    ),
    RecipeStep(
      0,
      3,
      "ncvsdbvujfbsovabf vsdjnviobfdis v vsfojnbgvrsfjn rfg vdfg bd gvrde ",
      null,
      null,
    ),
  ];

  int _numStepFields = 1;
  List<int> _stepIds = [];

  @override
  void initState() {
    super.initState();
    _numStepFields = _recipeSteps.length;
    _stepIds = List.generate(_recipeSteps.length, (index) => index);
  }

  Widget _generateStepField(int index) {
    return (index == 0)
        ? RecipeStepFormField(stepOrder: index, recipeStep: _recipeSteps[index])
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
              setState(() {
                _numStepFields -= 1;
                if (index <= _recipeSteps.length - 1) {
                  // Remove the step from recipe step list
                  _recipeSteps.removeAt(index);
                }

                // Remove its corresponding id
                _stepIds.removeAt(index);
              });

              _formKey.currentState!.removeInternalFieldValue("step$index");
              _formKey.currentState!.removeInternalFieldValue(
                "stepTimer$index",
              );
              _formKey.currentState!.removeInternalFieldValue("timeUnit$index");
            },
            child: RecipeStepFormField(
              stepOrder: index,
              recipeStep: (index <= _recipeSteps.length - 1)
                  ? _recipeSteps[index]
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

              if (_numStepFields > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        final formFields = _formKey.currentState!.value;

                        for (int i = 0; i < _numStepFields; i++) {
                          var app = {
                            "name": formFields["step$i"],
                            "timer": formFields["stepTimer$i"],
                            "timerUnit": formFields["timeUnit$i"],
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
