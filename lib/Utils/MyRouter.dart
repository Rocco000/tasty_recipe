import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Screens/CartScreen.dart';
import 'package:tasty_recipe/Screens/HomeScreen.dart';
import 'package:tasty_recipe/Screens/LoginScreen.dart';
import 'package:tasty_recipe/Screens/PrepareRecipeScreen.dart';
import 'package:tasty_recipe/Screens/ProfileScreen.dart';
import 'package:tasty_recipe/Screens/RecipeDetailsScreen.dart';
import 'package:tasty_recipe/Screens/RecipeListScreen.dart';
import 'package:tasty_recipe/Screens/SingInScreen.dart';
import 'package:tasty_recipe/Services/CartController.dart';
import 'package:tasty_recipe/Services/RecipeDetailsController.dart';
import 'package:tasty_recipe/Services/RecipeListController.dart';
import 'package:tasty_recipe/Utils/RecipeCreationFlow.dart';
import 'package:tasty_recipe/Utils/RecipeEditFlow.dart';

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
          case RecipeEditFlow.route:
            return RecipeEditFlow();
          case RecipeDetailsScreen.route:
            final Recipe recipe = settings.arguments as Recipe;
            return RecipeDetailsScreen(RecipeDetailsController(recipe));
          case PrepareRecipeScreen.route:
            return PrepareRecipeScreen();
          case RecipeListScreen.route:
            final controller = settings.arguments as RecipeListController;
            return RecipeListScreen(controller: controller);
          case CartScreen.route:
            return CartScreen(CartController());
          default:
            return HomeScreen();
        }
      },
    );
  }
}
