import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Screens/EditIngredientsScreen.dart';
import 'package:tasty_recipe/Screens/EditRecipeScreen.dart';
import 'package:tasty_recipe/Screens/EditRecipeStepsScreen.dart';
import 'package:tasty_recipe/Services/RecipeEditController.dart';

class RecipeEditFlow extends StatelessWidget {
  static const String route = "/recipeEditFlow";

  @override
  Widget build(BuildContext context) {
    // Get data from arguments
    final arguments =
        (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{})
            as Map<String, dynamic>;

    if (arguments.isEmpty ||
        !arguments.containsKey("recipe") ||
        !arguments.containsKey("recipeIngredients") ||
        !arguments.containsKey("ingredients") ||
        !arguments.containsKey("steps")) {
      // If there is no data in the arguments --> NAVIGATE BACK
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No recipe provided")));
      });

      return const SizedBox.shrink();
    }

    final Recipe recipe = arguments["recipe"] as Recipe;
    final List<RecipeIngredient> recipeIngredientList =
        arguments["recipeIngredients"] as List<RecipeIngredient>;
    final List<Ingredient> ingredientList =
        arguments["ingredients"] as List<Ingredient>;
    final List<RecipeStep> stepList = arguments["steps"] as List<RecipeStep>;

    return ChangeNotifierProvider(
      create: (context) => RecipeEditController(
        recipe,
        recipeIngredientList,
        ingredientList,
        stepList,
      ),
      child: Navigator(
        initialRoute: EditRecipeScreen.route,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case EditRecipeScreen.route:
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => EditRecipeScreen(),
              );
            case EditIngredientsScreen.route:
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => EditIngredientsScreen(),
              );
            case EditRecipeStepsScreen.route:
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => EditRecipeStepsScreen(),
              );
          }
        },
      ),
    );
  }
}
