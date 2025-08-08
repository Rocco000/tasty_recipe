import 'package:flutter/material.dart';
import 'package:tasty_recipe/Screens/CartScreen.dart';
import 'package:tasty_recipe/Screens/HomeScreen.dart';
import 'package:tasty_recipe/Screens/ProfileScreen.dart';
import 'package:tasty_recipe/Screens/RecipeListScreen.dart';
import 'package:tasty_recipe/Services/RecipeListController.dart';
import 'package:tasty_recipe/Utils/RecipeCreationFlow.dart';
import 'package:tasty_recipe/Utils/RecipeFilter.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final int index;

  const MyBottomNavigationBar(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      elevation: 2,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      onTap: (value) {
        switch (value) {
          case 0:
            Navigator.pushNamed(context, HomeScreen.route);
          case 1:
            Navigator.pushNamed(context, CartScreen.route);
          case 2:
            Navigator.pushNamed(context, RecipeCreationFlow.route);
          case 3:
            final controller = RecipeListController(RecipeFilter.favorites());
            Navigator.pushNamed(context, RecipeListScreen.route, arguments: controller);
          case 4:
            Navigator.pushNamed(context, ProfileScreen.route);
          default:
            Navigator.pushNamed(context, HomeScreen.route);
        }
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_filled),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_cart_sharp),
          label: "Shopping list",
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.add_box_rounded),
          label: "Create Recipe",
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite),
          label: "Favorite Recipes",
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}
