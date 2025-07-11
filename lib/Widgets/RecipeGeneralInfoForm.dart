import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Widgets/ChefHatWidget.dart';
import 'package:tasty_recipe/Widgets/DottedUploadImageButton.dart';
import 'package:tasty_recipe/Widgets/RecipeTagWidget.dart';

class RecipeGeneralInfoForm extends StatelessWidget {
  final Recipe? existingRecipe;
  final GlobalKey<FormBuilderState> formKey;
  final File? recipeImg;
  final void Function() onImageUploaded;
  final int? difficultyLevel;
  final void Function(int difficulty) onDifficultyChanged;
  final List<bool>? selectedTags;
  final void Function(String tagName, bool selection) onTagChanged;

  const RecipeGeneralInfoForm({
    required this.existingRecipe,
    required this.formKey,
    required this.recipeImg,
    required this.onImageUploaded,
    required this.difficultyLevel,
    required this.selectedTags,
    required this.onDifficultyChanged,
    required this.onTagChanged,
    super.key,
  });

  DropdownMenuItem<String> _generateDropdownRecipeCategoryItem(int index) {
    return DropdownMenuItem<String>(
      value: Recipe.categoryList[index],
      child: Row(
        children: [
          Recipe.mealIcons[index],
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(Recipe.categoryList[index]),
          ),
        ],
      ),
    );
  }

  Widget _generateRecipeTagWidget(int index) {
    return RecipeTagWidget(
      text: Recipe.recipeTags[index],
      isSelected: (existingRecipe != null)
          ? existingRecipe!.tags.contains(Recipe.recipeTags[index])
          : selectedTags![index],
      trailing: Recipe.recipeTagIcons[index],
      onSelectionFunction: (selection) {
        onTagChanged(Recipe.recipeTags[index], selection);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> formFields = [
      // IMAGE BUTTON
      DottedUploadImageButton(
        onTap: onImageUploaded,
        image: (existingRecipe != null) ? existingRecipe!.image : recipeImg,
      ),

      // RECIPE NAME
      FormBuilderTextField(
        name: "recipeName",
        initialValue: (existingRecipe != null)
            ? existingRecipe!.name
            : "", // optionally initial value
        validator: FormBuilderValidators.required(errorText: "Required"),
        decoration: InputDecoration(
          icon: Icon(Icons.flatware_rounded),
          labelText: "Recipe name",
        ),
      ),

      // RECIPE DURATION
      FormBuilderTextField(
        name: "recipeDuration",
        initialValue: (existingRecipe != null)
            ? existingRecipe!.duration.toString()
            : "", // optionally initial value
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(errorText: "Required"),
          FormBuilderValidators.numeric(errorText: "Insert a number"),
        ]),
        decoration: InputDecoration(
          icon: Icon(Icons.timer_outlined),
          labelText: "Recipe duration (min)",
        ),
        // To show a digit keyboard
        keyboardType: TextInputType.number,
        //To get only digit
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),

      // RECIPE DIFFICULTY
      Row(
        spacing: 5,
        children: <Widget>[
          const Text(
            "Difficulty:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          ChefHatWidget(
            onPressed: onDifficultyChanged,
            chefHat: (existingRecipe != null)
                ? existingRecipe!.difficulty
                : difficultyLevel!,
          ),
        ],
      ),

      // RECIPE SERVINGS
      FormBuilderTextField(
        name: "recipeServing",
        initialValue: (existingRecipe != null)
            ? existingRecipe!.servings.toString()
            : "",
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(errorText: "Required"),
          FormBuilderValidators.numeric(errorText: "Insert a number"),
        ]),
        decoration: InputDecoration(
          icon: Icon(Icons.people_alt_rounded),
          labelText: "Recipe serving",
        ),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),

      // RECIPE CATEGORY
      FormBuilderDropdown<String>(
        name: "recipeCategory",
        initialValue: (existingRecipe != null)
            ? existingRecipe!.category
            : null,
        hint: Text("Select category"),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(errorText: "Required"),
          (value) {
            return (!Recipe.categoryList.contains(value))
                ? "Invalid input"
                : null;
          },
        ]),
        items: List.generate(Recipe.categoryList.length, (index) {
          return _generateDropdownRecipeCategoryItem(index);
        }),
      ),

      // TAGS
      Container(
        alignment: Alignment.centerLeft,
        child: const Text(
          "Tags:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: List.generate(Recipe.recipeTags.length, (index) {
          return _generateRecipeTagWidget(index);
        }),
      ),
    ];

    return FormBuilder(
      key: formKey,
      child: Column(
        children: formFields.map(
          (field) => Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: field,
          ),
        )
        .toList(),
      ),
    );
  }
}
