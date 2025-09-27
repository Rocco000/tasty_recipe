import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Screens/EditIngredientsScreen.dart';
import 'package:tasty_recipe/Services/RecipeEditController.dart';
import 'package:tasty_recipe/Widgets/RecipeGeneralInfoForm.dart';

class EditRecipeScreen extends StatefulWidget {
  static const String route = "/editRecipe";

  const EditRecipeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EditRecipeScreenState();
  }
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  late RecipeEditController _controller;
  late Recipe _oldRecipe;
  late Recipe _newRecipe;

  @override
  void initState() {
    super.initState();
    // Get controller instance
    _controller = Provider.of<RecipeEditController>(context, listen: false);

    // Get old recipe version
    _oldRecipe = _controller.oldRecipe;
    _newRecipe = _oldRecipe.clone();
  }

  Future _pickImageFromGallery() async {
    // source: indicate where it should pick the image
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        _newRecipe.image = File(img.path);
      });
    }
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
              // LOGO + TEXT
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  children: [
                    Image.asset(
                      "content/images/cooking.png",
                      width: 100,
                      height: 100,
                    ),
                    Text(
                      "Edit recipe: ${_oldRecipe!.name}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              RecipeGeneralInfoForm(
                existingRecipe: _newRecipe,
                formKey: _formKey,
                recipeImg: null,
                onImageUploaded: _pickImageFromGallery,
                difficultyLevel: null,
                selectedTags: null,
                onDifficultyChanged: (difficulty) {
                  setState(() {
                    _newRecipe.difficulty = difficulty;
                  });
                },
                onTagChanged: (tagName, selection) {
                  if (_newRecipe.tags.contains(tagName)) {
                    setState(() {
                      _newRecipe.tags.remove(tagName);
                    });
                  } else {
                    setState(() {
                      _newRecipe.tags.add(tagName);
                    });
                  }
                },
              ),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.saveAndValidate()) {
                    final formFields = _formKey.currentState!.value;
                    // Save changes
                    final String newRecipeName =
                        formFields["recipeName"] as String;
                    final String duration =
                        formFields["recipeDuration"] as String;
                    final String servings =
                        formFields["recipeServing"] as String;

                    _newRecipe.name = newRecipeName.trim();
                    _newRecipe.duration = int.parse(duration);
                    _newRecipe.servings = int.parse(servings);
                    _newRecipe.category =
                        formFields["recipeCategory"] as String;

                    _controller.updateGeneralInfo(_newRecipe);

                    // Go to the next screen
                    Navigator.pushNamed(context, EditIngredientsScreen.route);
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
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
