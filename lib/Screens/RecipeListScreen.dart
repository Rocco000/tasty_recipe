import 'package:animated_item/animated_item.dart';
import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Screens/RecipeDetailsScreen.dart';
import 'package:tasty_recipe/Services/RecipeListController.dart';
import 'package:tasty_recipe/Utils/RecipeListResult.dart';
import 'package:tasty_recipe/Widgets/MyBottomNavigationBar.dart';
import 'package:tasty_recipe/Widgets/RecipeCardWidget.dart';

class RecipeListScreen extends StatefulWidget {
  static const String route = "/showRecipeList";
  final RecipeListController controller;

  const RecipeListScreen({required this.controller, super.key});

  @override
  State<RecipeListScreen> createState() {
    return _RecipeListScreenState();
  }
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  int _showedRecipe = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  late Future<RecipeListResult> _futureResult;

  @override
  void initState() {
    super.initState();

    _futureResult = widget.controller.getRecipes();
  }

  Widget _generateRecipeCard(Recipe recipe) {
    return RecipeCardWidget(
      recipeImage: Icon(Icons.abc),
      recipeName: recipe.name,
      recipeDuration: recipe.duration,
      recipeDifficulty: recipe.difficulty,
      recipeServing: recipe.servings,
      recipeCategory: recipe.category,
      recipeTags: recipe.tags,
      onTap: () => Navigator.pushNamed(
        context,
        RecipeDetailsScreen.route,
        arguments: recipe,
      ),
    );
  }

  void _scrollToPage(int pageNumber) {
    if (pageNumber >= 0 && pageNumber <= 2) {
      setState(() {
        _showedRecipe = pageNumber;
      });

      // Page animation
      _pageController.animateToPage(
        pageNumber,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutCirc,
      );
    }
  }

  Widget _showLeftArrow() {
    return (_showedRecipe > 0)
        ? IconButton(
            onPressed: () => _scrollToPage(_showedRecipe - 1),
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          )
        : SizedBox(width: 50.0);
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          title: const Text("Tasty Recipe"),
        ),
        backgroundColor: const Color(0xFFFFF9F4),
        body: FutureBuilder<RecipeListResult>(
          future: _futureResult,
          builder: (context, snapshot) {
            // Show loading spinner while waiting
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                alignment: Alignment.center,
                color: Colors.white,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: const CircularProgressIndicator(color: Colors.orange),
                ),
              );
            }

            // Show error message if something went wrong
            if (snapshot.hasError || !snapshot.hasData) {
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
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 48,
                          color: Color(0xFFE63946),
                        ),
                        Text(
                          "Something went wrong. Try again.",
                          style: TextStyle(
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

            final result = snapshot.data!;

            // Show error message (handled errors)
            if (result is RecipeListError) {
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
                          result.message,
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

            // Get data
            final RecipeListSuccess output = result as RecipeListSuccess;
            final List<Recipe> recipes = output.recipeList;

            // No data available for that filter
            if (recipes.isEmpty) {
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
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 48,
                          color: Color(0xFFFFD93D),
                        ),
                        Text(
                          "There are no recipes for this filter!",
                          style: TextStyle(
                            color: Color(0xFF2E2E2E),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Your recipe",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      height: MediaQuery.of(context).size.height * 0.75,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          return AnimatedPage(
                            controller: _pageController,
                            index: index,
                            effect: const FadeEffect(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: _generateRecipeCard(recipes[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),

        // Bottom Navigation Bar
        bottomNavigationBar: MyBottomNavigationBar(3),
      ),
    );
  }
}

/*

SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Text(
                    "Your recipes",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "- First Course",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // LEFT ARROW
                  _showLeftArrow(),

                  Expanded(
                    child: SizedBox(
                      height: 600,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _showedRecipe = index;
                          });
                        },
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Transform.scale(
                            scale: index == _showedRecipe ? 1.0 : 0.9,
                            child: _generateRecipeCard(index),
                          );
                        },
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      if (_showedRecipe < 2)
                        _scrollToPage(_showedRecipe + 1);
                      else
                        _scrollToPage(0);
                    },
                    icon: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),

*/
