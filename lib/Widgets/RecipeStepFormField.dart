import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';

class RecipeStepFormField extends StatefulWidget {
  final int stepOrder;
  final int fieldId;
  final RecipeStep? recipeStep;
  String durationErrorMessage;

  RecipeStepFormField({
    required this.stepOrder,
    required this.fieldId,
    required this.durationErrorMessage,
    this.recipeStep,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _RecipeStepFormFieldState();
  }
}

class _RecipeStepFormFieldState extends State<RecipeStepFormField> {
  bool _hasTimer = false;

  @override
  void initState() {
    super.initState();
    _hasTimer =
        (widget.recipeStep != null && widget.recipeStep!.duration != null)
        ? true
        : false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.orange[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // TEXT
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Step ${widget.stepOrder + 1}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // DESCRIPTION
            Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: FormBuilderTextField(
                name: "stepDescription${widget.fieldId}",
                maxLines: 5,
                minLines: 2,
                initialValue: (widget.recipeStep != null)
                    ? widget.recipeStep!.description
                    : "",
                validator: FormBuilderValidators.required(
                  errorText: "Required",
                ),
                decoration: InputDecoration(
                  icon: Image.asset(
                    "content/images/chefUtensil.png",
                    width: 50,
                    height: 50,
                  ),
                  labelText: "Description",
                ),
              ),
            ),

            // TIMER CHECK BOX
            Row(
              children: [
                Checkbox(
                  activeColor: Colors.lightBlue,
                  checkColor: Colors.white,
                  value: _hasTimer,
                  onChanged: (value) {
                    setState(() {
                      _hasTimer = !_hasTimer;

                      if (!_hasTimer) {
                        // Remove the timer information from the RecipeStep object if it exists
                        widget.recipeStep?.duration = null;
                        widget.recipeStep?.durationUnit = null;

                        // Clear duration and unit fields from FormBuilder
                        final formState = FormBuilder.of(context);
                        formState!.removeInternalFieldValue(
                          "stepDuration${widget.fieldId}",
                        );
                        formState!.removeInternalFieldValue(
                          "stepDurationUnit${widget.fieldId}",
                        );
                      }
                    });
                  },
                ),
                const Text("Add a timer for this step"),
              ],
            ),

            if (_hasTimer)
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    // TIME
                    Expanded(
                      child: FormBuilderTextField(
                        name: "stepDuration${widget.fieldId}",
                        initialValue:
                            (widget.recipeStep != null &&
                                widget.recipeStep!.duration != null)
                            ? widget.recipeStep!.duration.toString()
                            : "",
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: "Required"),
                          FormBuilderValidators.numeric(
                            errorText: "Insert a number",
                          ),
                        ]),
                        onChanged: (value) => setState(() {
                          widget.durationErrorMessage = "";
                        }),
                        decoration: InputDecoration(
                          icon: Icon(Icons.timer_outlined),
                          labelText: "Time",
                          errorText: (widget.durationErrorMessage.isEmpty)
                              ? null
                              : widget.durationErrorMessage,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),

                    SizedBox(width: 12),

                    // TIME UNIT
                    Expanded(
                      child: FormBuilderDropdown<String>(
                        name: "stepDurationUnit${widget.fieldId}",
                        initialValue:
                            (widget.recipeStep != null &&
                                widget.recipeStep!.durationUnit != null)
                            ? widget.recipeStep!.durationUnit
                            : "",
                        hint: Text("Time unit"),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: "Required"),
                          (value) {
                            return (!RecipeStep.timeUnits.contains(value))
                                ? "Invalid input"
                                : null;
                          },
                        ]),
                        items: [
                          DropdownMenuItem<String>(
                            value: "second",
                            child: const Text("second(s)"),
                          ),
                          DropdownMenuItem<String>(
                            value: "minute",
                            child: const Text("minute(s)"),
                          ),
                          DropdownMenuItem<String>(
                            value: "hour",
                            child: const Text("hour(s)"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
