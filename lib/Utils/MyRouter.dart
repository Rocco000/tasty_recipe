import 'package:flutter/material.dart';
import 'package:tasty_recipe/Screens/CartScreen.dart';
import 'package:tasty_recipe/Screens/EditIngredientsScreen.dart';
import 'package:tasty_recipe/Screens/EditRecipeScreen.dart';
import 'package:tasty_recipe/Screens/EditRecipeStepsScreen.dart';
import 'package:tasty_recipe/Screens/HomeScreen.dart';
import 'package:tasty_recipe/Screens/LoginScreen.dart';
import 'package:tasty_recipe/Screens/PrepareRecipeScreen.dart';
import 'package:tasty_recipe/Screens/ProfileScreen.dart';
import 'package:tasty_recipe/Screens/RecipeDetailsScreen.dart';
import 'package:tasty_recipe/Screens/ShowRecipeListScreen.dart';
import 'package:tasty_recipe/Screens/SingInScreen.dart';
import 'package:tasty_recipe/Utils/RecipeCreationFlow.dart';

abstract class MyRouter {
  static Route<dynamic> generateRoute(
    BuildContext context,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        switch (settings.name) {
          case HomeScreen.route:
            return HomeScreen();
          case LoginScreen.route:
            return LoginScreen();
          case SignInScreen.route:
            return SignInScreen();
          case ProfileScreen.route:
            return ProfileScreen();
          case RecipeCreationFlow.route:
            return RecipeCreationFlow();
          case EditRecipeScreen.route:
            return EditRecipeScreen();
          case EditIngredientsScreen.route:
            return EditIngredientsScreen();
          case EditRecipeStepsScreen.route:
            return EditRecipeStepsScreen();
          case RecipeDetailsScreen.route:
            return RecipeDetailsScreen();
          case PrepareRecipeScreen.route:
            return PrepareRecipeScreen();
          case ShowRecipeListScreen.route:
            return ShowRecipeListScreen();
          case CartScreen.route:
            return CartScreen();
          default:
            return HomeScreen();
        }
      },
    );
  }
}
