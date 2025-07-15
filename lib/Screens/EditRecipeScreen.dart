import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
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

  Recipe _existingRecipe = Recipe(
    File("A55 di Rocco/Internal storage/DCIM/Camera/20240727_114539.jpg"),
    "0",
    "Cake",
    3,
    30,
    2,
    "First Course",
    ["Vegan"],
    false,
    "",
  );

  Future _pickImageFromGallery() async {
    // source: indicate where it should pick the image
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);

    // WHY???
    if (img != null) {
      setState(() {
        _existingRecipe.image = File(img.path);
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
                      "Edit recipe: ${_existingRecipe.name}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              RecipeGeneralInfoForm(
                existingRecipe: _existingRecipe,
                formKey: _formKey,
                recipeImg: null,
                onImageUploaded: _pickImageFromGallery,
                difficultyLevel: null,
                selectedTags: null,
                onDifficultyChanged: (difficulty) {
                  setState(() {
                    _existingRecipe.difficulty = difficulty;
                  });
                },
                onTagChanged: (tagName, selection) {
                  if (_existingRecipe.tags.contains(tagName)) {
                    setState(() {
                      _existingRecipe.tags.remove(tagName);
                    });
                  } else {
                    setState(() {
                      _existingRecipe.tags.add(tagName);
                    });
                  }
                },
              ),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.saveAndValidate()) {
                    final formFields = _formKey.currentState!.value;
                    var app = {
                      "name": formFields["recipeName"],
                      "duration": formFields["recipeDuration"],
                      "difficulty": _existingRecipe.difficulty,
                      "servings": formFields["recipeServing"],
                      "category": formFields["recipeCategory"],
                      "tags": _existingRecipe.tags,
                    };
                    print(app);
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
