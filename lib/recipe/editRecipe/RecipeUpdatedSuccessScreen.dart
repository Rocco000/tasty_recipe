import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tasty_recipe/Screens/HomeScreen.dart';
import 'package:tasty_recipe/recipe/editRecipe/RecipeEditController.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeAggregate.dart';
import 'package:tasty_recipe/recipe/viewRecipe/RecipeDetailsScreen.dart';

class RecipeUpdatedSuccessScreen extends StatelessWidget {
  static const String route = "/editRecipeSuccess";

  const RecipeUpdatedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            Lottie.asset(
              "content/animations/recipeSuccess.json",
              repeat: false,
              height: deviceSize.height * 0.4,
              width: deviceSize.width * 0.8,
            ),
            Text(
              "Recipe updated successfully!",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              "Your changes have been saved.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32.0),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Get updated recipe from controller
                  final RecipeAggregate data =
                      Provider.of<RecipeEditController>(
                        context,
                        listen: false,
                      ).updatedRecipe;

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
    );
  }
}
