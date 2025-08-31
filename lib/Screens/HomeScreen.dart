import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/MyUser.dart';
import 'package:tasty_recipe/Screens/RecipeListScreen.dart';
import 'package:tasty_recipe/Services/RecipeListController.dart';
import 'package:tasty_recipe/Utils/RecipeFilter.dart';
import 'package:tasty_recipe/Widgets/CategoryCardWidget.dart';
import 'package:tasty_recipe/Widgets/MyBottomNavigationBar.dart';

class HomeScreen extends StatefulWidget {
  static const String route = "/homepage";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MyUser _user = MyUser("foo.mail@.com", "Abcd3fg!00", "Jhon");

  final Map<String, String> _backgroundImgs = {
    "Breakfast": "content/images/breakfastBackground.jpeg",
    "First course": "content/images/firstCourseBackground.jpg",
    "Second course": "content/images/secondCourseBackground.jpg",
    "Snack": "content/images/snackBackground.jpg",
    "Dessert": "content/images/dessertBackground.jpg",
  };

  Widget _generateCategoryCard(int index) {
    String category = _backgroundImgs.keys.elementAt(index);
    late final RecipeListController controller;
    switch (category) {
      case "Breakfast":
        controller = RecipeListController(RecipeFilter.breakfast());
      case "First course":
        controller = RecipeListController(RecipeFilter.firstCourse());
      case "Second course":
        controller = RecipeListController(RecipeFilter.secondCourse());
      case "Snack":
        controller = RecipeListController(RecipeFilter.snack());
      case "Dessert":
        controller = RecipeListController(RecipeFilter.dessert());
    }

    return Center(
      child: CategoryCardWidget(
        label: category,
        background: _backgroundImgs[category]!,
        onTap: () {
          Navigator.pushNamed(
            context,
            RecipeListScreen.route,
            arguments: controller,
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    // runs after initState, and whenever a dependency changes
    super.didChangeDependencies();
    final arguments =
        (ModalRoute.of(context)?.settings.arguments ?? <String, String>{})
            as Map<String, String>;

    // Show a SnackBar if a message is available
    if (arguments.isNotEmpty && arguments["msg"] != null) {
      // That callback is scheduled to run after the current build frame is fully completed
      WidgetsBinding.instance.addPostFrameCallback((duration) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(arguments["msg"]!),
            backgroundColor: Colors.black45,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating, // Makes it float over the UI
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      });
    }
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
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  "Welcome ${_user.username}!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                ...List.generate(5, _generateCategoryCard),
              ],
            ),
          ),
        ),

        // Bottom Navigation Bar
        bottomNavigationBar: MyBottomNavigationBar(0),
      ),
    );
  }
}
