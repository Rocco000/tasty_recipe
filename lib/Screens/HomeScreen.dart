import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/MyUser.dart';
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

    return Center(
      child: CategoryCardWidget(
        label: category,
        background: _backgroundImgs[category]!,
        onTap: () {},
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
