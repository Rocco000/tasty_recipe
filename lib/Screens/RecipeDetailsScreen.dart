import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Widgets/RecipeIngredientWidget.dart';
import 'package:tasty_recipe/Widgets/RecipeStepWidget.dart';

class RecipeDetailsScreen extends StatefulWidget {
  static const String route = "recipeDetails";

  const RecipeDetailsScreen({super.key});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final Recipe _recipe = Recipe(
    null,
    "1",
    "Chocolate cake",
    2,
    60,
    4,
    "Dessert",
    ["Lactose Free", "Vegan"],
    false,
    "",
  );

  final List<RecipeStep> _recipeSteps = [
    RecipeStep(
      "0",
      0,
      "bacdfgrgt vfrgtrsghbt gvfrfagvfrae gvergh, svfdsgvfd . nuinibn ",
      20.5,
      "minute",
    ),
    RecipeStep(
      "1",
      1,
      "bacdfgrgt vfrgtrsghbt gvfrfagvfrae gvergh, fsdg. fretge",
      null,
      null,
    ),
    RecipeStep("2", 2, "bacdfgrgt vfrgtrsghbt gvfrfagvfrae gvergh", 1, "hour"),
  ];

  final List<RecipeIngredient> _recipeIngredients = [
    RecipeIngredient("1", "1", 250, "gr"),
    RecipeIngredient("1", "2", 100, "gr"),
    RecipeIngredient("1", "3", 1, "cup"),
  ];

  final List<Ingredient> _ingredients = [
    Ingredient("0", "Chocolate"),
    Ingredient("0", "Milk"),
    Ingredient("0", "Cacao"),
  ];

  Widget _generateIngredients(
    RecipeIngredient ingredient,
    String ingredientName,
  ) {
    return RecipeIngredientWidget(
      ingredient: ingredient,
      ingredientName: ingredientName,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Added to cart!"),
            backgroundColor: Colors.black45,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating, // Makes it float over the UI
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  Widget _generateRecipeStepCard(int index) {
    return RecipeStepWidget(
      step: _recipeSteps[index],
      onPressedNextStep: null,
      onPressedStartTimer: null,
      lastStep: false,
      showButtons: false,
    );
  }

  Widget _generateSection(String sectionTitle, void Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            sectionTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: onPressed,
            tooltip: "Edit",
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
    );
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

        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // RECIPE IMAGE + NAME + Edit
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.25,
                child: Stack(
                  // All the available space
                  fit: StackFit.expand,
                  children: <Widget>[
                    // RECIPE IMG
                    Image.network(
                      "https://t3.gstatic.com/licensed-image?q=tbn:ANd9GcSVzpnv_EMpNYb9WrblxuxMR0zaeSA6M7uGtBU40PfQm32zlHBQys-3WO3xAtEX5bXDyxydNiq4lr7h9Kud",
                      fit: BoxFit.cover,
                    ),

                    // RECIPE NAME
                    Positioned(
                      left: 0,
                      bottom: 0,
                      right: 0,
                      child: ColoredBox(
                        //black-transparent background
                        color: Colors.black45,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            spacing: 12,
                            children: <Widget>[
                              Text(
                                _recipe.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),

                              Text(
                                "(${_recipe.category})",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // FAVORITE BUTTON
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        child: IconButton(
                          color: (_recipe.isFavorite)
                              ? Colors.red
                              : Colors.black,
                          tooltip: (_recipe.isFavorite)
                              ? "Remove from favorite"
                              : "Add to favorite!",
                          onPressed: () {
                            setState(() {
                              _recipe.changeFavoriteState();
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Added to favorite!"),
                                backgroundColor: Colors.black45,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior
                                    .floating, // Makes it float over the UI
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          icon: (_recipe.isFavorite)
                              ? const Icon(Icons.favorite)
                              : const Icon(Icons.favorite_border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _generateSection("General Info:", () {}),

              // DURATION
              Card(
                color: Colors.white,
                shadowColor: Colors.orange[100],
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 10.0,
                ),
                clipBehavior: Clip.hardEdge,
                child: ListTile(
                  title: const Text(
                    "Duration:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: <Widget>[
                      Text(
                        _recipe.duration.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Icon(Icons.timer_outlined),
                    ],
                  ),
                ),
              ),

              // SERVINGS
              Card(
                color: Colors.white,
                shadowColor: Colors.orange[100],
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 10.0,
                ),
                clipBehavior: Clip.hardEdge,
                child: ListTile(
                  title: const Text(
                    "Servings:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: <Widget>[
                      Text(
                        _recipe.servings.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Icon(Icons.people_alt_rounded),
                    ],
                  ),
                ),
              ),

              // DIFFICULTY
              Card(
                color: Colors.white,
                shadowColor: Colors.orange[100],
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 10.0,
                ),
                clipBehavior: Clip.hardEdge,
                child: ListTile(
                  title: const Text(
                    "Difficulty:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: <Widget>[
                      Text(
                        _recipe.difficulty.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      Image.asset(
                        "content/images/chefHat.png",
                        color: Colors.amber[700],
                        width: 30,
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                color: Colors.white,
                shadowColor: Colors.orange[100],
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 10.0,
                ),
                clipBehavior: Clip.hardEdge,
                child: ListTile(
                  title: const Text(
                    "Tags:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: <Widget>[
                      ...List.generate(_recipe.tags.length, (index) {
                        return Recipe.getTagIcon(_recipe.tags[index]);
                      }),
                    ],
                  ),
                ),
              ),

              // INGREDIENTS
              _generateSection("Ingredients:", () {}),

              ...List.generate(_recipeIngredients.length, (index) {
                return _generateIngredients(
                  _recipeIngredients[index],
                  _ingredients[index].name,
                );
              }),

              // STEPS
              _generateSection("Steps:", () {}),

              ...List.generate(_recipeSteps.length, (index) {
                return _generateRecipeStepCard(index);
              }),

              // BUTTON
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade300,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.black,
                        elevation: 2.0,
                      ),
                      child: Row(
                        spacing: 5,
                        children: const <Widget>[
                          Icon(Icons.play_arrow_rounded),
                          Text(
                            "Start!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade300,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.black,
                        elevation: 2.0,
                      ),
                      child: Row(
                        spacing: 5,
                        children: const <Widget>[
                          Icon(Icons.edit_rounded),
                          Text(
                            "Edit",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          tooltip: "Start",
          onPressed: () {},
          child: const Icon(Icons.play_arrow_rounded),
        ),
      ),
    );
  }
}
