import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasty_recipe/Screens/AddRecipeIngredientsScreen.dart';
import 'package:tasty_recipe/Screens/AddRecipeStepsScreen.dart';
import 'package:tasty_recipe/Screens/CreateRecipeScreen.dart';
import 'package:tasty_recipe/Services/RecipeCreationController.dart';

class RecipeCreationFlow extends StatelessWidget {
  static const String route = "/recipeCretionFlow";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecipeCreationController(),
      child: Navigator(
        initialRoute: CreateRecipeScreen.route,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case CreateRecipeScreen.route:
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => CreateRecipeScreen(),
              );
            case AddRecipeIngredientsScreen.route:
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => AddRecipeIngredientsScreen(),
              );
            case AddRecipeStepsScreen.route:
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => AddRecipeStepsScreen(),
              );
          }
        },
      ),
    );
  }
}
