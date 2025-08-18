import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Screens/EditRecipeScreen.dart';
import 'package:tasty_recipe/Screens/HomeScreen.dart';
import 'package:tasty_recipe/Services/RecipeDetailsController.dart';
import 'package:tasty_recipe/Widgets/RecipeIngredientWidget.dart';
import 'package:tasty_recipe/Widgets/RecipeStepWidget.dart';

class RecipeDetailsScreen extends StatefulWidget {
  static const String route = "recipeDetails";
  final String _recipeId;
  final RecipeDetailsController _controller;

  const RecipeDetailsScreen(this._recipeId, this._controller, {super.key});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late Recipe _recipe;

  late final Future<
    (Recipe, List<RecipeIngredient>, List<Ingredient>, List<RecipeStep>)
  >
  _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = widget._controller.loadFullRecipe(widget._recipeId);
  }

  Widget _generateIngredients(
    RecipeIngredient recipeIngredient,
    Ingredient ingredient,
  ) {
    return RecipeIngredientWidget(
      ingredient: recipeIngredient,
      ingredientName: ingredient.name,
      onPressed: () async {
        final bool result = await widget._controller.addIngredientToCart(
          ingredient,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: (result)
                ? Text("${ingredient.name} added to cart!")
                : Text("${ingredient.name} already added to the cart."),
            backgroundColor: (result) ? Colors.black45 : Color(0xFFE63946),
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

  Widget _generateRecipeStepCard(RecipeStep recipeStep) {
    return RecipeStepWidget(
      step: recipeStep,
      onPressedNextStep: null,
      onPressedStartTimer: null,
      lastStep: false,
      showButtons: false,
    );
  }

  Widget _generateSectionHeader(
    String sectionTitle,
    void Function() onPressed,
  ) {
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

  List<Widget> _showRecipeGeneralInfo(Recipe recipe) {
    return <Widget>[
      // RECIPE NAME + CATEGORY + IMG
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
                        recipe.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      Text(
                        "(${recipe.category})",
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
                  color: (recipe.isFavorite) ? Colors.red : Colors.black,
                  tooltip: (recipe.isFavorite)
                      ? "Remove from favorite"
                      : "Add to favorite!",
                  onPressed: () async {
                    final bool result = await widget._controller
                        .updateRecipeFavoriteState(recipe);

                    if (result) {
                      setState(() {
                        _recipe.changeFavoriteState();
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: (_recipe.isFavorite)
                              ? Text("Added to favorite!")
                              : Text("Removed from favorite!"),
                          backgroundColor: Colors.black45,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior
                              .floating, // Makes it float over the UI
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Something went wrong. Try again.",
                          ),
                          backgroundColor: const Color(0xFFE63946),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior
                              .floating, // Makes it float over the UI
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  icon: (recipe.isFavorite)
                      ? const Icon(Icons.favorite)
                      : const Icon(Icons.favorite_border),
                ),
              ),
            ),
          ],
        ),
      ),

      _generateSectionHeader("General Info:", () {}),

      // DURATION
      Card(
        color: Colors.white,
        shadowColor: Colors.orange[100],
        elevation: 10.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
                recipe.duration.toString(),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
                recipe.servings.toString(),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
                recipe.difficulty.toString(),
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

      // TAGS
      Card(
        color: Colors.white,
        shadowColor: Colors.orange[100],
        elevation: 10.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
              ...List.generate(recipe.tags.length, (index) {
                return Recipe.getTagIcon(recipe.tags[index]);
              }),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _showIngredients(
    List<RecipeIngredient> recipeIngredientList,
    List<Ingredient> ingredientList,
  ) {
    return <Widget>[
      _generateSectionHeader("Ingredients:", () {}),

      ...List.generate(recipeIngredientList.length, (index) {
        return _generateIngredients(
          recipeIngredientList[index],
          ingredientList[index],
        );
      }),
    ];
  }

  List<Widget> _showSteps(List<RecipeStep> stepList) {
    return <Widget>[
      _generateSectionHeader("Steps:", () {}),

      ...List.generate(stepList.length, (index) {
        return _generateRecipeStepCard(stepList[index]);
      }),
    ];
  }

  Widget _generateErrorMessage(Object error) {
    String msg = error.toString();
    final index = msg.indexOf(":");
    if (index != -1 && index < msg.length - 1) {
      msg = msg.substring(index + 1).trim();
    } else {
      msg = "Something went wrong. Try again";
    }

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Card(
          color: const Color(
            0xFFFFF9F4,
          ), // const Color.fromRGBO(230, 57, 70, 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Color(0xFFE63946),
              ),
              Text(
                msg,
                style: const TextStyle(
                  color: Color(0xFFE63946),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
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
          child:
              FutureBuilder<
                (
                  Recipe,
                  List<RecipeIngredient>,
                  List<Ingredient>,
                  List<RecipeStep>,
                )
              >(
                future: _futureData,
                builder: (context, snapshot) {
                  print("Recipe id: ${widget._recipeId}");

                  // Show loading spinner while waiting
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: const CircularProgressIndicator(
                          color: Colors.orange,
                        ),
                      ),
                    );
                  }

                  // Show error message if something went wrong
                  if (snapshot.hasError) {
                    return _generateErrorMessage(snapshot.error!);
                  }

                  if (!snapshot.hasData) {
                    // Something wrong, unusual
                    return _generateErrorMessage(
                      "Something went wrong. Try again.",
                    );
                  }

                  // Show data when data is ready
                  final (
                    recipe,
                    recipeIngredientList,
                    ingredientList,
                    stepList,
                  ) = snapshot.data!;

                  _recipe = recipe;

                  return Column(
                    children: <Widget>[
                      // RECIPE GENERAL INFO
                      ..._showRecipeGeneralInfo(_recipe),

                      // INGREDIENTS
                      ..._showIngredients(recipeIngredientList, ingredientList),

                      // STEPS
                      ..._showSteps(stepList),

                      // BUTTONS
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 10,
                          children: <Widget>[
                            // DELETE BUTTON
                            ElevatedButton.icon(
                              onPressed: () async {
                                final bool result = await widget._controller
                                    .deleteRecipe(_recipe);

                                if (!result) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        "Something went wrong. Try again",
                                      ),
                                      backgroundColor: const Color(0xFFE63946),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior
                                          .floating, // Makes it float over the UI
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pushNamedAndRemoveUntil(
                                  HomeScreen.route,
                                  (route) => false,
                                  arguments: "Successfully deleted the recipe!",
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE63946),
                                foregroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text("Delete"),
                            ),

                            // EDIT BUTTON
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  EditRecipeScreen.route,
                                );
                              },
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
                  );
                },
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
