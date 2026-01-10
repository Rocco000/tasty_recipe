import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tasty_recipe/recipe/models/entities/Ingredient.dart';
import 'package:tasty_recipe/recipe/models/entities/Recipe.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeIngredient.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeStep.dart';
import 'package:tasty_recipe/recipe/editRecipe/RecipeEditController.dart';

/// A class to store the parameters (recipe info) from RecipeDetailsScreen.
/// This class wraps the edit screens with a provider.
class RecipeEditFlow extends StatefulWidget {
  final Recipe? recipe;
  final List<RecipeIngredient> recipeIngredientList;
  final List<Ingredient> ingredientList;
  final List<RecipeStep> stepList;

  // An edit screen
  final Widget child;

  const RecipeEditFlow({
    super.key,
    required this.recipe,
    required this.recipeIngredientList,
    required this.ingredientList,
    required this.stepList,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _RecipeEditFlowState();
}

class _RecipeEditFlowState extends State<RecipeEditFlow> {
  late final RecipeEditController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RecipeEditController(
      widget.recipe!,
      widget.recipeIngredientList,
      widget.ingredientList,
      widget.stepList,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A ChangeNotifierProvider to share the controller object between the edit screens
    return ChangeNotifierProvider<RecipeEditController>.value(
      value: _controller,
      child: widget.child,
    );
  }
}
