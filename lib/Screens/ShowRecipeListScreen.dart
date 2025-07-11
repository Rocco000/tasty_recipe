import 'package:flutter/material.dart';
import 'package:tasty_recipe/Widgets/RecipeCardWidget.dart';

class ShowRecipeListScreen extends StatefulWidget {
  final String route = "/showRecipeList";

  const ShowRecipeListScreen({super.key});

  @override
  State<ShowRecipeListScreen> createState() {
    return _ShowRecipeListScreenState();
  }
}

class _ShowRecipeListScreenState extends State<ShowRecipeListScreen> {
  int _showedRecipe = 0;
  final PageController _pageController = PageController(viewportFraction: 0.95);

  Widget _generateRecipeCard(int index) {
    return RecipeCardWidget(
      recipeImage: Icon(Icons.abc),
      recipeName: "Torta al cioccolato tfgrbhn  $index",
      recipeDuration: 20,
      recipeDifficulty: 3,
      recipeServing: 10,
      recipeCategory: "Snack",
      recipeTags: ["Vegan", "Fit", "Lactose Free"],
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

  Widget _showLeftArrow(){
    return (_showedRecipe > 0) ?
      IconButton(
        onPressed: () => _scrollToPage(_showedRecipe - 1),
        icon: Icon(Icons.arrow_back_ios_new_rounded),
      )
      :
        SizedBox(width:50.0);
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
        body: 
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Text("Your recipes", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                  Text("- First Course", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
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
                    onPressed:
                        () {
                          print(_showedRecipe);
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

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        elevation: 2,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorite Recipes",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      ),
    );
  }
}
