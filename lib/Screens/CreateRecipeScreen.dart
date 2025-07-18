import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Screens/AddRecipeIngredientsScreen.dart';
import 'package:tasty_recipe/Services/RecipeCreationController.dart';
import 'package:tasty_recipe/Widgets/MyBottomNavigationBar.dart';
import 'package:tasty_recipe/Widgets/RecipeGeneralInfoForm.dart';

class CreateRecipeScreen extends StatefulWidget {
  static const String route = "/createRecipe";
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  File? _pickedImg;
  int _selectedChefHat = 0;

  final List<bool> _selectedTags = [false, false, false, false];
  final List<String> _selectedTagNames = [];

  Future _pickImageFromGallery() async {
    // source: indicate where it should pick the image
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        _pickedImg = File(img.path);
      });
    }
  }

  void _onContinuePressed() {
    if (_formKey.currentState!.saveAndValidate()) {
      final formFields = _formKey.currentState!.value;

      // Get controller instance
      final RecipeCreationController controller =
          Provider.of<RecipeCreationController>(context, listen: false);

      // Temporarly store the recipe general info
      controller.setGeneralInfo(
        formFields["recipeName"],
        int.parse(formFields["recipeDuration"]),
        _selectedChefHat,
        int.parse(formFields["recipeServing"]),
        formFields["recipeCategory"],
        _selectedTagNames,
      );

      // Navigate to the next screen
      Navigator.pushNamed(context, AddRecipeIngredientsScreen.route);
    }
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
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
                    const Text(
                      "Create a new recipe!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // Recipe Form
              RecipeGeneralInfoForm(
                existingRecipe: null,
                formKey: _formKey,
                recipeImg: _pickedImg,
                onImageUploaded: _pickImageFromGallery,
                difficultyLevel: _selectedChefHat,
                onDifficultyChanged: (difficulty) {
                  setState(() {
                    _selectedChefHat = difficulty;
                  });
                },
                selectedTags: _selectedTags,
                onTagChanged: (tagName, selection) {
                  setState(() {
                    _selectedTags[Recipe.recipeTags.indexOf(tagName)] =
                        selection;
                    if (_selectedTagNames.contains(tagName)) {
                      _selectedTagNames.remove(tagName);
                    } else {
                      _selectedTagNames.add(tagName);
                    }
                  });
                },
              ),

              ElevatedButton(
                onPressed: () => _onContinuePressed(),
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

        bottomNavigationBar: MyBottomNavigationBar(2),
      ),
    );
  }
}
