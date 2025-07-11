import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';

class RecipeStepWidget extends StatelessWidget {
  final RecipeStep step;
  final void Function()? onPressedNextStep;
  final void Function()? onPressedStartTimer;
  final bool lastStep;
  final bool showButtons;

  const RecipeStepWidget({required this.step, required this.onPressedNextStep, required this.onPressedStartTimer, required this.lastStep, required this.showButtons, super.key});

  Widget _generateStepTitle(){
    return (step.duration == null) ?
      ListTile(title: Text("Step ${step.stepOrder+1}:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),))
      :
      ListTile(
        // TITLE
        title: Text("Step ${step.stepOrder+1}:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: <Widget>[
            // DURATION
            Text(
              "${(step.duration!%1 == 0) ? step.duration!.toInt() : step.duration} ${RecipeStep.getUnitMeasurementSymbol(step.durationUnit!)}",
              style: const TextStyle(fontSize: 18),
            ),
            const Icon(Icons.timer_outlined),
          ],
        ),
      );
  }

  Widget _generateStepDescription(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(step.description, style: const TextStyle(fontSize: 18, color: Colors.black),)
    );
  }

  List<Widget> _generateCardContentWithoutButton(){
    return [
      _generateStepTitle(),
      _generateStepDescription(),
    ];
  }


  List<Widget> _generateCardContentWithButton(){
    Widget cardHeader, cardBody;
    List<Widget>? cardFooter = null;

    cardHeader = _generateStepTitle();
    cardBody = _generateStepDescription();

    if (lastStep && step.duration == null) // Last step without timer
      return [cardHeader, cardBody];

    cardFooter = [];

    // NEXT STEP BUTTON
    if (!lastStep){
      cardFooter.add(
        ElevatedButton.icon(
          onPressed: onPressedNextStep, 
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade300,
            foregroundColor: Colors.white,
            shadowColor: Colors.black,
            elevation: 2.0,
          ),
          icon: const Icon(Icons.arrow_forward_outlined),
          label: const Text("Next Step")
        )
      );
    }

    // START TIMER BUTTON
    if (step.duration != null){
      cardFooter.add(
        ElevatedButton.icon(
          onPressed: onPressedStartTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade300,
            foregroundColor: Colors.white,
            shadowColor: Colors.black,
            elevation: 2.0,
          ),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text("Start timer!")
        )
      );
    }

    return [
      cardHeader,
      cardBody,
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 5,
        children: cardFooter,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.orange[100],
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 10,
          children: <Widget>[
            if(showButtons) 
              ..._generateCardContentWithButton()
            else
              ..._generateCardContentWithoutButton(),
          ],
        ),
      ),
    );
  }
}