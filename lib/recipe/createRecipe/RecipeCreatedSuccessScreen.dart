import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tasty_recipe/Screens/HomeScreen.dart';
import 'package:tasty_recipe/recipe/createRecipe/RecipeCreationController.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeAggregate.dart';
import 'package:tasty_recipe/recipe/viewRecipe/RecipeDetailsScreen.dart';

class RecipeCreatedSuccessScreen extends StatelessWidget {
  static const String route = "/createRecipeSuccess";

  const RecipeCreatedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Stack(
        fit: StackFit.expand, // To fill al the screen
        children: <Widget>[
          // SUCCESS MESSAGE + NAV BUTTONS
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: <Widget>[
                Lottie.asset(
                  "content/animations/onboardingCooking.json",
                  repeat: false,
                  height: deviceSize.height * 0.4,
                  width: deviceSize.width * 0.8,
                ),
                Text(
                  "Recipe created successfully!",
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                Text(
                  "Your new recipe has been saved.",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32.0),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Get created recipe from controller
                      final RecipeAggregate data =
                          Provider.of<RecipeCreationController>(
                            context,
                            listen: false,
                          ).createdRecipe;

                      // Navigate to the recipe page without any other database requests
                      context.go(RecipeDetailsScreen.route, extra: data);
                    },
                    child: const Text("View recipe"),
                  ),
                ),

                const SizedBox(height: 16.0),

                TextButton(
                  onPressed: () => context.go(HomeScreen.route),
                  child: const Text("Go to home"),
                ),
              ],
            ),
          ),

          // CONFETTI
          // Positioned.fill() To cover the entire screen
          Positioned.fill(
            child: IgnorePointer(
              // IgnorePointer to allow taps to pass through the widgets under that animation. So that animation doesn't track any taps
              child: Lottie.asset(
                "content/animations/confetti.json",
                repeat: false,
                width: deviceSize.width,
                height: deviceSize.height,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
